##############################################################################################
#------------------------- RAGFlow database extractor: MinIO artefacts ----------------------#
##############################################################################################

##########################
# ---- Dependencies ---- #
##########################

import os
import sys
import subprocess
from app.core.load_env import EnvLoader

# Asegurar path correcto (aunque aquí parece innecesario)
sys.path.append(os.path.abspath(os.path.join("..", "src")))

###################################
# ---- MinIO artefacts extractor --#
###################################

# ---- Configuration ----
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__),"..", ".."))
BACKUP_DIR = os.path.join(PROJECT_ROOT,"database", "data", "minio")
os.makedirs(BACKUP_DIR, exist_ok=True)
env_vars = EnvLoader().get_all()

# ---- Environment variables load ----
MC_PATH = os.path.normpath(env_vars.get("MINIO_MC_PATH"))
ALIAS = env_vars.get("MINIO_ALIAS")
ENDPOINT = env_vars.get("MINIO_ENDPOINT")
ACCESS_KEY = env_vars.get("MINIO_ACCESS_KEY")
SECRET_KEY = env_vars.get("MINIO_SECRET_KEY")

def minio_reagflow_extractor():
    # Validación mínima
    if not all([MC_PATH, ALIAS, ENDPOINT, ACCESS_KEY, SECRET_KEY]):
        raise ValueError("⚠️ Faltan variables de entorno requeridas para MinIO.")

    # 1. Configurar alias
    print("🔗 Configurando alias de MinIO...")
    subprocess.run([MC_PATH, "alias", "set", ALIAS, ENDPOINT, ACCESS_KEY, SECRET_KEY], check=True)

    # 2. Obtener lista de buckets
    print("📂 Listando buckets...")
    buckets = subprocess.check_output([MC_PATH, "ls", ALIAS], text=True).splitlines()
    bucket_names = [b.split()[-1].strip("/") for b in buckets if b]

    # 3. Descargar cada bucket
    for bucket in bucket_names:
        target_dir = os.path.join(BACKUP_DIR, bucket)
        os.makedirs(target_dir, exist_ok=True)
        print(f"⬇️ Copiando bucket {bucket} -> {target_dir}")
        subprocess.run([MC_PATH, "mirror", f"{ALIAS}/{bucket}", target_dir], check=True)

    print("✅ Backup MinIO completado.")
