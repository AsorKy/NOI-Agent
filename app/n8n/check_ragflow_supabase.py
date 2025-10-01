import pandas as pd
import numpy as np
import json

# input data from supabase and ragflow parser
try:
  supa_data = dict(_input.item.json)
  #supa_data = dict(_input.item.json).get("supabase_docs", []) # lista de docs desde Supabase
  ragflow_data = dict(_input.item.json).get("rag_docs", {}) # dict desde RAGFlow
  #ragflow_data = dict(_input.item.json.rag_docs) 
except Exception as e:
  return {"error": f"Invalid input structure: {str(e)}"}

# transform ragflow data into a set
ragflow_files = set(ragflow_data.get("file_name", []))


results = []


# data comming from ragflow


# selector
def has_field(field, condition=None, existence=True):
  if existence:
    return True if (field is not None or field != "NULL") else False
  else:
    return True if field == condition else False

# conditions to upload to ragflow
def upload_to_ragflow(id, supabase_key, ragflow_id, 
                      up_status, up_ragflow_status, pross_status,
                      created_at
                     ):
  
  has_id = has_field(id, True)
  has_supabase_id = has_field(supabase_key, True)
  no_ragflow_id = has_field(ragflow_id, "NULL", False)
  has_up_status = has_field(up_status, "uploaded", False)
  no_up_ragflow_status = has_field(up_ragflow_status, "pending", False)
  no_pross_status = has_field(pross_status, "pending", False)
  has_creation = has_field(created_at, True)

  # 1. Condition for ragflow uploading if supabase was successfull
  

  

# classification
upload_to_ragflow = {}
doc_ids = ragflow_data.get("doc_id", None)
supa_id = supa_data.get("id", None)

if (doc_ids is not None and supa_id is not None):
  
  for id in doc_ids:
    if not has_field(id, supa_id):
      upoad_to_ragflow[]
    
else:
  return {"out": "Error in flow, no doc_ids"}  