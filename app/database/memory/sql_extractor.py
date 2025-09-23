##############################################################################################
#------------------------- RAGFlow database extractor: SQL metadata -------------------------#
##############################################################################################

##########################
# ---- Dependencies ---- #
##########################

import os
import sys
import subprocess 
from datetime import datetime
from app.core.load_env import EnvLoader

# Asegurar path correcto (aunque aquí parece innecesario)
sys.path.append(os.path.abspath(os.path.join("..", "src")))

###################################
# ---- SQL metadata extractor ----#
###################################

# ---- Configuration ----
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BACKUP_DIR = os.path.join(PROJECT_ROOT, "database", "data", "sql")
os.makedirs(BACKUP_DIR, exist_ok=True)
env_vars = EnvLoader().get_all()

# ---- Environment variables load ----
CONTAINER = env_vars.get("RAGFLOW_SQL_CONTAINER")
DB_NAME = env_vars.get("RAGFLOW_SQL_DATABASE_METADATA")
DB_USER = env_vars.get("RAGFLOW_SQL_ROOT_USER")
DB_PASS = env_vars.get("RAGFLOW_SQL_ROOT_PASS")

def sql_ragflow_extractor():
    # Validación mínima
    if not all([CONTAINER, DB_NAME, DB_USER, DB_PASS]):
        raise ValueError("⚠️ Faltan variables de entorno requeridas para la conexión MySQL.")

    # ---- Output file with timestamp ----
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    dump_file = os.path.join(BACKUP_DIR, f"{DB_NAME}_backup_{timestamp}.sql")

    print(f"📦 Creando backup de MySQL -> {dump_file} ....")

    # ---- mysqldump execution ----
    with open(dump_file, "wb") as f:
        subprocess.run(
            [
                "docker", "exec", "-i",
                CONTAINER,
                "mysqldump",
                f"-u{DB_USER}",
                f"-p{DB_PASS}",
                DB_NAME
            ],
            stdout=f,
            check=True
        )

    print("✅ Backup MySQL completed.")

    return {"sql_file_path": dump_file, "exported_at": timestamp }
