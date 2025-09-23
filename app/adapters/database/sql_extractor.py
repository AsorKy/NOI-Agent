##############################################################################################
#------------------------- RAGFlow database extractor: SQL metadata -------------------------#
##############################################################################################


##########################
# ---- Dependencies ---- #
##########################

import os
import sys
import ast
import subprocess 
from dotenv import load_dotenv
from datetime import datetime

from core.load_env import EnvLoader

sys.path.append(os.path.abspath(os.path.join("..", "src")))


###################################
# ---- SQL metadata extractor ----#
###################################

# ---- Configuration ----
BACKUP_DIR = os.path.join("database", "sql")
os.makedirs(BACKUP_DIR, exist_ok=True)
env_vars = EnvLoader().get_all()


# ---- Environment variables load ----
CONTAINER = env_vars.get("RAGFLOW_SQL_CONTAINER", None)
DB_NAME = env_vars.get("RAGFLOW_SQL_DATABASE_METADATA", None)
DB_USER = env_vars.get("RAGFLOW_SQL_ROOT_USER", None)
DB_PASS = env_vars.get("RAGFLOW_SQL_ROOT_PASS", None)

# ---- Output file with timestamp ----
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
dump_file = os.path.join(BACKUP_DIR, f"{DB_NAME}_backup_{timestamp}.sql")

print(f"📦 Creando backup de MySQL -> {dump_file} ....")

# ---- mysqldump excecution in container and redirection redirection to local ----
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