##############################################################################################
#------------------------- RAGFlow database extractor: MinIO artefacts ----------------------#
##############################################################################################

##########################
# ---- Dependencies ---- #
##########################

import os
import sys
import subprocess
import shutil
from app.core.load_env import EnvLoader

# Asegurar path correcto (aunque aquí parece innecesario)
sys.path.append(os.path.abspath(os.path.join("..", "src")))

###################################
# ---- MinIO artefacts extractor --#
###################################

# ---- Configuration ----
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BACKUP_DIR = os.path.join(PROJECT_ROOT, "database", "data", "minio")
os.makedirs(BACKUP_DIR, exist_ok=True)
env_vars = EnvLoader().get_all()

# ---- Environment variables load ----
MC_PATH = os.path.normpath(env_vars.get("MINIO_MC_PATH"))
ALIAS = env_vars.get("MINIO_ALIAS")
ENDPOINT = env_vars.get("MINIO_ENDPOINT")
ACCESS_KEY = env_vars.get("MINIO_ACCESS_KEY")
SECRET_KEY = env_vars.get("MINIO_SECRET_KEY")

def minio_ragflow_extractor():
    # Validación mínima
    if not all([MC_PATH, ALIAS, ENDPOINT, ACCESS_KEY, SECRET_KEY]):
        raise ValueError("⚠️ Faltan variables de entorno requeridas para MinIO.")

    # 1. Configurar alias
    print("🔗 Configurando alias de MinIO...")
    subprocess.run(
        [MC_PATH, "alias", "set", ALIAS, ENDPOINT, ACCESS_KEY, SECRET_KEY],
        check=True
    )

    # 2. Obtener lista de buckets
    print("📂 Listando buckets...")
    buckets = subprocess.check_output([MC_PATH, "ls", ALIAS], text=True).splitlines()
    bucket_names = [b.split()[-1].strip("/") for b in buckets if b]

    # 3. Descargar cada bucket completo (temporalmente)
    for bucket in bucket_names:
        print(f"⬇️ Copiando bucket {bucket} ...")
        bucket_tmp = os.path.join(BACKUP_DIR, f"{bucket}_raw")
        os.makedirs(bucket_tmp, exist_ok=True)

        # Descargar todo el bucket en carpeta temporal
        subprocess.run([MC_PATH, "mirror", f"{ALIAS}/{bucket}", bucket_tmp], check=True)

        # Crear estructura organizada
        bucket_final = os.path.join(BACKUP_DIR, bucket)
        pdf_dir = os.path.join(bucket_final, "pdf")
        chunk_dir = os.path.join(bucket_final, "chunk_data")
        os.makedirs(pdf_dir, exist_ok=True)
        os.makedirs(chunk_dir, exist_ok=True)

        # Clasificar archivos
        for root, _, files in os.walk(bucket_tmp):
            for f in files:
                file_path = os.path.join(root, f)

                # PDF → carpeta pdf
                if f.lower().endswith(".pdf"):
                    shutil.move(file_path, os.path.join(pdf_dir, f))

                # Thumbnails → DESCARTAR
                elif "thumbnail" in f.lower() or f.lower().endswith((".jpg", ".jpeg", ".png")):
                    continue

                # Files (artefactos tipo chunk/metadatos) → carpeta chunk_data
                else:
                    shutil.move(file_path, os.path.join(chunk_dir, f))

        # Eliminar la carpeta temporal
        shutil.rmtree(bucket_tmp, ignore_errors=True)

    print("✅ Backup MinIO completado y organizado.")
