##############################################################################################
#------------------------ RAGFlow database laoder: MINIO data loader ------------------------#
##############################################################################################


##########################
# ---- Dependencies ---- #
##########################

import os
import sys
import json
import sqlite3
from pathlib import Path
from dotenv import load_dotenv
from datetime import datetime

sys.path.append(os.path.abspath(os.path.join("..", "src")))


###################################
# ---- Minio artifacts loader ----#
###################################

# ---- Configuration ----


# ---- Minio loader ----
def ragflow_dataloader_local(sqlite_path, chunk_dir, limit=5):
    # --- 1. Leer SQL local (ya restaurado en sqlite) ---
    conn = sqlite3.connect(sqlite_path)
    cur = conn.cursor()
    cur.execute("SELECT id, file_id, page_number, content, embedding  FROM document_chunks LIMIT ?;", (limit,))
    rows = cur.fetchall()
    conn.close()

    # --- 2. Leer archivos tipo File desde carpeta local ---
    documents = []
    for row in rows:
        chunk_id, file_id, page_number, content, embedding = row
        file_path = Path(chunk_dir) / f"{file_id}.json"
        if file_path.exists():
            with open(file_path, "r", encoding="utf-8") as f:
                file_content = json.load(f)
        else:
            file_content = None

        documents.append({
            "chunk_id": chunk_id,
            "file_id": file_id,
            "page_number": page_number,
            "chunk_text": content,
            "file_data": file_content,
            "embedding": embedding
        })

    return documents
