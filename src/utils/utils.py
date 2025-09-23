##############################################################################################
#------------------------------------- General Utilities ------------------------------------#
##############################################################################################

##########################
# ---- Dependencies ---- #
##########################

import pathlib
import numpy as np
import matplotlib.pyplot as plt
from dotenv import load_dotenv
from PIL import Image
import tensorflow as tf
import torch


# ---- System-related utilities ----
def check_cuda_availability():
    """
    Verifica si PyTorch y TensorFlow pueden usar una GPU con soporte CUDA.
    """
    print("⚡⚡ Verificando si la GPU está disponible... ⚡⚡\n")

    print("🔹 Verificando GPU en PyTorch 🔹")
    
    is_available = torch.cuda.is_available()
    
    if is_available:
        print("✅ ¡La GPU está disponible! PyTorch puede usar CUDA 🎉🚀")
        # Opcional: muestra el nombre de la GPU que se está utilizando
        print(f"   💻 Nombre de la GPU: {torch.cuda.get_device_name(0)}\n")
    else:
        print("❌ La GPU no está disponible ❌. PyTorch se ejecutará en CPU 🖥️")
        print("   ⚠️ Asegúrate de haber instalado la versión correcta de PyTorch con soporte CUDA.\n")

    print("🔹 Verificando GPU en TensorFlow 🔹")
     
    print(f"📌 TensorFlow version: {tf.__version__}")
    print(f"⚙️ Built with CUDA: {tf.test.is_built_with_cuda()} 🌟")
    print(f"⚙️ Built with cuDNN: {tf.test.is_built_with_gpu_support()} 🌟\n")

    if tf.test.is_built_with_cuda() and tf.test.is_built_with_gpu_support():
        print("🎯 ¡TensorFlow puede usar la GPU con CUDA y cuDNN! 🚀🔥")
    else:
        print("⚠️ TensorFlow no puede usar la GPU. Se ejecutará en CPU 🖥️")

        
# ---- Data-related Utilities ----
def load_images_from_folder(folder_path):
    """
    Carga todas las imágenes de una carpeta en una lista.
    
    Args:
        folder_path (str): La ruta del directorio que contiene las imágenes.

    Returns:
        list: Una lista de objetos de imagen de Pillow.
    """
    # Usar pathlib para manejar la ruta de manera segura
    p = pathlib.Path(folder_path)
    if not p.is_dir():
        print(f"Error: La ruta '{folder_path}' no es un directorio válido.")
        return []

    images = []
    # Usar glob para encontrar todos los archivos con las extensiones de imagen
    for image_path in p.glob('*.[jp][pn]g'):
        try:
            # Abrir y cargar la imagen
            with Image.open(image_path) as img:
                # La función .convert('RGB') asegura que todas las imágenes
                # tengan 3 canales de color, lo cual es útil para el entrenamiento
                # de modelos de deep learning.
                images.append(img.convert('RGB'))
                
        except (IOError, OSError) as e:
            print(f"Error al cargar la imagen {image_path}: {e}")
            continue

    print(f"Se cargaron {len(images)} imágenes desde '{folder_path}'.")
    return images


# ---- Data-related Utilities ----
def pil_to_numpy(pil_img: Image.Image) -> np.ndarray:
    """Convierte una imagen PIL.Image en un array de NumPy."""
    return np.array(pil_img)