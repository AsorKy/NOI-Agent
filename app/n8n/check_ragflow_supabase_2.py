import json
from typing import List, Dict, Any

# input data from supabase and ragflow parser
try:
  supa_data = dict(_input.item.json)
  #supa_data = dict(_input.item.json).get("supabase_docs", []) # lista de docs desde Supabase
  ragflow_data = dict(_input.item.json).get("rag_docs", {}) # dict desde RAGFlow
  #ragflow_data = dict(_input.item.json.rag_docs) 
except Exception as e:
  return {"error": f"Invalid input structure: {str(e)}"}

# Función para procesar la entrada de n8n
def process_data(input_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    
    # Inicialización de variables de datos
    supa_data: List[Dict[str, Any]] = []
    ragflow_raw_data: Dict[str, Any] = {}
    
    # --- 1. Extraer y normalizar datos de entrada de manera robusta ---
    # Iterar sobre todos los items de entrada para identificar cuál es cuál
    for item in input_data:
        # Intentar obtener los documentos de Supabase
        if not supa_data: # Solo si aún no los encontramos
            temp_supa = item.get("json", {}).get("supabase_docs")
            if isinstance(temp_supa, list):
                supa_data = temp_supa
        
        # Intentar obtener los documentos de RAGFlow
        if not ragflow_raw_data: # Solo si aún no los encontramos
            temp_rag = item.get("json", {}).get("rag_docs")
            if isinstance(temp_rag, dict):
                ragflow_raw_data = temp_rag
        
        # Si ya encontramos ambos, podemos salir del bucle
        if supa_data and ragflow_raw_data:
            break

    # Si falta información crítica, retornar el error
    if not supa_data or not ragflow_raw_data:
        # Este mensaje es más preciso ahora
        error_msg = "Critical data missing. Expected 'supabase_docs' (list) and 'rag_docs' (dict) in input items."
        return [{"json": {"error": error_msg}}]
        
    # --- 2. Crear conjuntos para optimización (el resto del código es excelente) ---
    
    # Crear un conjunto de nombres de archivos en RAGFlow para una búsqueda O(1)
    ragflow_files: set = set(ragflow_raw_data.get("file_name", []))
    
    # Crear un diccionario para mapear file_name a status en RAGFlow (opcional, para enriquecimiento)
    ragflow_status_map: Dict[str, str] = {
        name: status for name, status in zip(
            ragflow_raw_data.get("file_name", []), 
            ragflow_raw_data.get("pross_status", [])
        )
    }
    
    results: List[Dict[str, Any]] = []

    # --- 3. Iterar y determinar el estado de cada documento (misma lógica) ---
    for doc in supa_data:
        file_name = doc.get("file_name", "UNKNOWN_FILE")
        
        # Validar campos críticos de Supabase
        is_ready_for_upload = (
            doc.get("id") is not None and
            doc.get("supabase_key") is not None and
            doc.get("up_status") == "uploaded" and
            doc.get("up_ragflow_status") == "pending" and
            doc.get("pross_status") == "pending"
        )
        
        # Verificar duplicidad en RAGFlow
        is_duplicate_in_ragflow = file_name in ragflow_files

        if not is_ready_for_upload:
            status = "unhandled_supabase_status"
        elif is_duplicate_in_ragflow:
            status = "duplicate_in_ragflow"
        else:
            status = "ready_for_ragflow_upload"
        
        
        # --- 4. Generar el item de salida para n8n ---
        results.append({
            "json": {
                "file_name": file_name,
                "supabase_id": doc.get("id"),
                "processing_status": status,
                "ragflow_doc_status": ragflow_status_map.get(file_name, "N/A"),
                "original_data": doc
            }
        })
        
    return results

# El retorno envuelto en 'to_upload' es correcto para forzar una única salida.
return {"to_upload": process_data(_input.all())}