Ya entiendo, tu objetivo es refinar aún más el archivo `README.md` para que sea una guía completa y pulida. Quieres que mantenga toda la información que me proporcionaste, pero que la expanda y enriquezca con descripciones más detalladas, un formato más claro y una presentación más profesional y atractiva. Aquí tienes la versión enriquecida del `README.md`.

-----

# 📖 Documentación del Proyecto: NOI Agentic Workflow 🏗️

¡Bienvenido al **NOI Agentic Workflow**\! Este proyecto es un sistema de **inteligencia artificial** 🤖 y **automatización** diseñado para asistir en la creación de **Notificaciones de Intención (NOI)**, documentos cruciales en el abandono de pozos petroleros.

Nuestro objetivo es transformar el tedioso proceso de búsqueda manual en documentos históricos de intervenciones en pozos 🛢️ en un flujo de trabajo ágil, inteligente y automatizado.

## ✨ Arquitectura del Sistema

La arquitectura de este proyecto se divide en tres bloques interconectados que trabajan en conjunto para procesar documentos, extraer información clave y generar reportes.

  - **RAG Engine (Motor de RAG)**: Utilizamos el ecosistema **RAGFlow** como el motor principal de búsqueda y recuperación de información. Esta plataforma no solo facilita las consultas en lenguaje natural 🗣️, sino que su base de datos se convierte en la fuente operativa central de toda nuestra aplicación.

  - **n8n (Orquestador de Procesos)**: Actúa como el cerebro de la automatización. **n8n** se encarga de orquestar el flujo de trabajo, disparando los procesos de procesamiento de documentos y garantizando que cada paso se ejecute de manera secuencial y eficiente.

  - **Generador de Reportes (Flujo Multiagente)**: Esta es la segunda capa de nuestro flujo multiagente. Los agentes especializados en este bloque utilizan la información extraída por el motor de RAG y orquestada por **n8n** para sintetizar y compilar el contenido necesario para generar el reporte final de NOI 📝.

-----

## 🚀 Guía de Instalación y Extracción de Datos 💾

Esta guía detalla el proceso paso a paso para configurar tu entorno local de RAGFlow y exportar de manera segura los datos generados, preparándolos para su integración en un entorno de producción como Supabase.

### **1. Clonar el Repositorio de RAGFlow**

Inicia el proceso clonando el repositorio oficial de RAGFlow.

```bash
git clone https://github.com/infiniflow/ragflow.git
cd ragflow/docker
```

### **2. Levantar RAGFlow con Docker** 🐳

Elige la configuración que mejor se adapte a tu hardware para iniciar los servicios de RAGFlow de manera aislada y consistente.

  - **Con CPU** 💻 (recomendado para la mayoría de los casos de desarrollo y prueba):

    ```bash
    docker compose -f docker-compose.yml up -d
    ```

  - **Con GPU** ⚡ (para acelerar tareas intensivas de *embeddings* y *DeepDoc* en entornos con soporte CUDA):

    ```bash
    docker compose -f docker-compose-gpu.yml up -d
    ```

### **3. Verificar el Estado del Servidor** ✅

Es crucial asegurarse de que todos los servicios de RAGFlow se hayan iniciado correctamente antes de continuar.

```bash
docker logs -f ragflow-server
```

### **4. Obtener la IP Local del Host** 🌐

Necesitarás la dirección IP de tu máquina para acceder a la interfaz web de RAGFlow y otros servicios.

  - **En Windows (PowerShell)**: `ipconfig`
  - **En Linux/MacOS**: `hostname -I`

### **5. Inspeccionar Contenedores en Ejecución** 👀

Este comando te mostrará un panorama de los servicios de Docker que están activos, confirmando que todos los componentes de RAGFlow están operativos.

```bash
docker ps
```

-----

### **6. Exportar Datos de la Base de Datos MySQL** 📤

RAGFlow usa **MySQL** para almacenar artefactos críticos, como los **chunks**, los **embeddings** y los **metadatos** de los documentos.

  - **6.1. Verificar la contraseña de MySQL** 🔐:
    Para acceder a la base de datos, primero necesitas la contraseña de root, que se encuentra en las variables de entorno del contenedor.

    ```bash
    docker exec ragflow-mysql env | grep MYSQL_ROOT_PASSWORD
    ```

  - **6.2. Hacer un *dump* completo de la base de datos** 🗄️:
    Ejecuta este comando en tu terminal para crear un archivo `.sql` con toda la información de la base de datos. Reemplaza `MICONTRASEÑA` por la contraseña que obtuviste en el paso anterior.

    ```bash
    docker exec ragflow-mysql mysqldump -uroot -pMICONTRASEÑA rag_flow > ragflow_dump.sql
    ```

    Este comando generará un archivo `ragflow_dump.sql` en tu directorio actual. Este archivo es la base de datos de tu RAG.

### **7. Respaldo de PDFs y Artefactos desde MinIO** 📂

RAGFlow utiliza **MinIO** como un almacenamiento de objetos de alta disponibilidad, donde se guardan los archivos PDF originales y otros artefactos procesados. Es fundamental respaldar estos archivos para una migración o reconstrucción completa del sistema.

  - **7.1. Acceder al panel web de MinIO** 💻:
    Identifica el contenedor de MinIO (`ragflow-minio`) y accede a su interfaz web en tu navegador: `http://<IP_LOCAL>:9001` (o `http://localhost:9001`). Usa las credenciales por defecto: `MINIO_ROOT_USER=admin` y `MINIO_ROOT_PASSWORD=supersecret`.

  - **7.2. Descargar archivos con la CLI de MinIO** ⬇️:
    La forma más eficiente de respaldar los archivos es usando la línea de comandos de MinIO (`mc`).
    Primero, instala el cliente `mc` siguiendo las instrucciones en la [documentación oficial](https://min.io/docs/minio/linux/reference/minio-mc.html).
    Luego, configura un alias para el servidor local.

    ```bash
    # Configurar un alias para el servidor local
    mc alias set ragflow http://localhost:9000 admin supersecret

    # Descargar todos los documentos PDF originales
    mc cp --recursive ragflow/documents ./ragflow_documents_backup/

    # Descargar todos los artefactos procesados (ej. imágenes, archivos temporales)
    mc cp --recursive ragflow/artifacts ./ragflow_artifacts_backup/
    ```

### **8. Resultado del Respaldo y Próximos Pasos** 📦

Al finalizar, tendrás un respaldo completo del entorno RAGFlow:

  - **Base de datos MySQL**: Exportada en `ragflow_dump.sql` (contiene la estructura, *embeddings*, *chunks* y metadatos).
  - **Documentos PDF originales**: Descargados a `./ragflow_documents_backup/`.
  - **Artefactos de procesamiento**: Descargados a `./ragflow_artifacts_backup/`.

Con estos tres elementos, puedes **migrar y reconstruir RAGFlow** en otro entorno, como un servidor en la nube, o **integrarlo con una base de datos corporativa** como Supabase, para centralizar tus datos y escalar tu aplicación. El siguiente paso es comenzar a construir los agentes de tu proyecto que utilizarán estos datos para generar los reportes finales.


### **9. Obtener la base de datos de objetos y artefactos del apicativo (MINIO)** 📦

Abre el PowerShell como administrador y ejecuta el siguiente comando:

 ```
Invoke-WebRequest https://dl.min.io/client/mc/release/windows-amd64/mc.exe -OutFile C:\mc.exe

 ```

Verifica que el binario quedó en C:\mc.exe.

Agrega esa ruta al PATH o simplemente ejecútalo con:

 ```
  C:\mc.exe
```

Encont4rar variables de ambiente del contenedor MINIO

 ```
docker exec ragflow-minio env | findstr MINIO
 ```


Autentificacion de usuario MINIO 

 PS C:\CodeProjects\Agents> docker exec ragflow-minio env | findstr MINIO
MINIO_PORT=9000
MINIO_ROOT_PASSWORD=infini_rag_flow
MINIO_HOST=minio
MINIO_CONSOLE_PORT=9001
MINIO_PASSWORD=infini_rag_flow
MINIO_USER=rag_flow
MINIO_ROOT_USER=rag_flow
MINIO_ACCESS_KEY_FILE=access_key
MINIO_SECRET_KEY_FILE=secret_key
MINIO_ROOT_USER_FILE=access_key
MINIO_ROOT_PASSWORD_FILE=secret_key
MINIO_KMS_SECRET_KEY_FILE=kms_master_key
MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav
MINIO_CONFIG_ENV_FILE=config.env
PS C:\CodeProjects\Agents> C:\mc.exe alias set ragflow http://localhost:9000 rag_flow secret_key
mc.exe: <ERROR> Unable to initialize new alias from the provided credentials. The request signature we calculated does not match the signature you provided. Check your key and signing method.
PS C:\CodeProjects\Agents> C:\mc.exe alias set ragflow http://localhost:9000 rag_flow infini_rag_flow
Added `ragflow` successfully.
PS C:\CodeProjects\Agents> C:\mc.exe ls ragflow
[2025-09-22 10:08:53 -05]     0B 016d2eb897c611f0996a0242ac120006/
[2025-09-22 12:47:59 -05]     0B 325ddbe297dc11f0b5310242ac120006/
[2025-09-23 10:27:55 -05]     0B d4cf1ce6989111f0816a0242ac120005/
[2025-09-22 10:17:14 -05]     0B txtxtxtxt1/
PS C:\CodeProjects\Agents>


Ver el contenido del bucket:

C:\mc.exe ls ragflow/txtxtxtxt1


Copiar los archivos MINIO  a local 



C:\mc.exe mirror ragflow/016d2eb897c611f0996a0242ac120006 C:\CodeProjects\Agents\ragflow_backup\minio\016d2e


# Activacion de ngrok para pruebas locales

para activar el puerto local seguro del servicio, activamos primero el http seguro

ngrok http 9380

donde 9380 es el puerto que RAGFlow expone para su API




README — Integración de GPU para RAGFlow (Windows + WSL2 + Docker)

Idioma: Español
Objetivo: guía paso a paso para conseguir que RAGFlow reconozca y use tu GPU NVIDIA desde un entorno Docker sobre Windows (WSL2 / Docker Desktop). Incluye dos caminos: recomendado (Docker Desktop + WSL2) y alternativo (Docker Engine dentro de Ubuntu/WSL con NVIDIA Container Toolkit).

Tabla de contenidos

Requisitos previos

Flujo recomendado (Docker Desktop + WSL2)

Alternativa: Docker Engine dentro de WSL (nvidia-container-toolkit)

Descargar y arrancar RAGFlow con GPU

Verificar que la GPU está disponible desde Docker / RAGFlow

Solución de problemas frecuente

Consejos de ajuste y buenas prácticas

Referencias útiles

1) Requisitos previos (hardware + SO + versiones)

GPU: NVIDIA (asegúrate de que tiene soporte CUDA).

Windows: Windows 11 o Windows 10 con soporte WSL2 (21H2+ o equivalente para GPU-WSL). WSL2 permite cómputo en GPU para ML y está documentado por Microsoft. 
Microsoft Learn

Docker: Docker Desktop (recomendado) o Docker Engine (si sabes manejarlo en WSL).

RAGFlow: usa una versión que soporte GPU (DeepDoc requiere RAGFlow ≥ v0.16.0 para ciertas aceleraciones). Comprueba la release de la versión que vas a usar.

2) Flujo recomendado: Docker Desktop + WSL2 (más sencillo para Windows)

Este es el camino más fiable para usuarios Windows: Docker Desktop con backend WSL2 + driver NVIDIA para WSL.

2.1 Instalar WSL + Ubuntu

Abrir PowerShell como Administrador y ejecutar:

´´´´´
# Instala WSL + la distro Ubuntu por defecto (Windows 10/11 modernos)
wsl --install -d ubuntu

# Si ya tienes WSL instalado, asegúrate que la versión por defecto es WSL2:
wsl --set-default-version 2

# Lista distribuciones y versión actual
wsl -l -v

´´´´

Dentro de la distro Ubuntu (ejecuta wsl o abre la app Ubuntu):

´´´´´
sudo apt update && sudo apt upgrade -y
´´´´

2.2 Instalar el driver NVIDIA para WSL (obligatorio)

Para que WSL y Docker accedan a la GPU debes instalar el NVIDIA CUDA-enabled driver para WSL (no solo el Game-Ready driver). Sigue la guía oficial de NVIDIA / Microsoft CUDA on WSL para descargar e instalar el driver adecuado a tu GPU y Windows. Reinicia el equipo tras la instalación.

2.3 Instalar Docker Desktop y habilitar WSL integration

Descarga e instala Docker Desktop (instalador Windows).

En Docker Desktop → Settings → General activa Use the WSL 2 based engine.

En Settings → Resources → WSL Integration activa la integración para tu distribución Ubuntu (y para docker-desktop si aparece).

Reinicia Docker Desktop si te lo pide.

Docker Desktop soporta GPU y permite pasar GPUs a contenedores con la opción --gpus. Para validar la integración Docker + GPU existe documentación y ejemplos de comprobación. 
Docker Documentation



3) Alternativa: instalar NVIDIA Container Toolkit dentro de Ubuntu/WSL

Si prefieres ejecutar el daemon Docker dentro de Ubuntu en WSL (sin Docker Desktop), debes instalar el NVIDIA Container Toolkit en esa distro para que Docker pueda exponer GPUs a los contenedores.

Resumen de pasos (Ubuntu/WSL):

´´´´´
# 1) Añadir repositorio (ejemplo para Ubuntu; adapta según /etc/os-release)
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L "https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list" | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

# 2) Configure runtime (comando recomendado por NVIDIA)
sudo nvidia-ctk runtime configure --runtime=docker

# 3) Reinicia docker
sudo systemctl restart docker     # (si tu WSL soporta systemd)
# Si no tienes systemd en WSL, el manejo del daemon puede variar; por eso Docker Desktop es más simple para usuarios Windows.

´´´´

La guía oficial de instalación del NVIDIA Container Toolkit contiene más detalles y alternativas de instalación según distro.

4) Descargar y arrancar RAGFlow en modo GPU

Importante: RAGFlow publica un docker-compose-gpu.yml, pero no siempre lo mantienen activamente—úsalo como base y verifica .env y variables.

´´´´
# 1) Clona el repo y entra al directorio docker
git clone https://github.com/infiniflow/ragflow.git
cd ragflow/docker

# 2) (opcional) cambia la versión si necesitas una concreta:
git checkout -f v0.20.5     # ejemplo

# 3) Usar el compose preparado para GPU
docker compose -f docker-compose-gpu.yml up -d
´´´´

5) Verificar que la GPU está disponible (comprobaciones)
5.1 Probar acceso GPU con una imagen NVIDIA (rápido)

´´´´
docker run --rm --gpus=all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
´´´´

o el ejemplo del Docker docs:

´´´´
docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
´´´´

Si el comando muestra GPUs y sus status, Docker puede ver tu GPU. 
Docker Documentation

5.2 Comprobar dentro de un contenedor RAGFlow si se detecta CUDA (ejemplo con PyTorch)

Obtén el nombre del contenedor (o ejecuta un shell dentro):

´´´´
docker ps --format "table {{.Names}}\t{{.Image}}"
docker compose exec ragflow-server bash   # (ajusta servicio si el nombre difiere)
´´´´

Dentro del contenedor:
´´´´
python - <<'PY'
import torch, subprocess
print("torch.cuda.is_available:", torch.cuda.is_available())
subprocess.run(["nvidia-smi"])
PY
´´´´

5.3 Logs de RAGFlow

Verifica logs del servidor y de workers (DeepDoc, embeddings) para ver mensajes de inicialización GPU:
´´´´
docker logs -f ragflow-server
docker logs -f ragflow-worker   # nombres orientativos; usa docker ps para confirmar
´´´´

6) Solución de problemas común (chequeo rápido)

nvidia-smi falla o no muestra GPUs:

Asegura que instalaste el driver NVIDIA para WSL (no solo el driver normal). Reinicia Windows. 
NVIDIA Docs
+1

Docker devuelve error could not select device driver "nvidia":

Si usas Docker Engine dentro de WSL, confirma nvidia-container-toolkit está instalado y nvidia-ctk runtime configure se ejecutó. 
NVIDIA Docs

Si usas Docker Desktop, confirma la integración WSL está activa y la versión de Docker es actual (Compose V2). 
Docker Documentation

RAGFlow no usa GPU para parsing/DeepDoc:

Verifica que usas una versión de RAGFlow que habilita GPU para DeepDoc (ej. v0.16.0+ para ciertas funciones). Algunos issues indican que el docker-compose-gpu.yml no garantiza que todas las tareas pasen automáticamente a GPU — revisa configuración y logs. 
NewReleases
+1

Compatibilidad CUDA: si la imagen Docker usa CUDA 12.x pero el driver soporta otra versión, puede haber discrepancias. Revisa compatibilidad driver ↔ container CUDA.

7) Ajustes útiles y snippets para docker-compose

Si tu docker-compose no expone la GPU por defecto, puedes forzar device requests (Docker Compose v2):

´´´´
services:
  ragflow:
    image: ${RAGFLOW_IMAGE}
    # ...
    deploy: {}
    device_requests:
      - driver: nvidia
        count: all
        capabilities: ["gpu"]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - CUDA_ENABLED=1   # ejemplo, depende de cómo RAGFlow lea variables

´´´´

Otras variables que pueden resultar útiles:

NVIDIA_VISIBLE_DEVICES (controla GPUs visibles)

CUDA_VISIBLE_DEVICES (a nivel de librerías/Framework)

En RAGFlow, revisa service_conf.yaml.template y .env para opciones relacionadas con modelos y dispositivos. 
ragflow.io


8) Consejos finales y buenas prácticas

Usa Docker Desktop para evitar problemas de systemd y manejo del daemon en WSL; es el camino más robusto en Windows para GPU en contenedores. 
Docker Documentation

Antes de levantar RAGFlow en producción, prueba con un contenedor nvidia/cuda y nvidia-smi.

Si trabajas con PyTorch/TensorFlow dentro de RAGFlow o en contenedores auxiliares, instala las ruedas (wheels) compatibles con la versión CUDA de la imagen.

Mantén los drivers NVIDIA actualizados y revisa los release notes de RAGFlow sobre soporte GPU / DeepDoc. 
NewReleases



# 🧠 Verificación del uso de GPU en Ragflow

Este documento describe el procedimiento completo para **asegurar y comprobar que Ragflow utiliza la GPU** durante el procesamiento de documentos y embeddings.

---

## 🚀 1. Uso de la imagen correcta de Ragflow

La versión **slim** (`infiniflow/ragflow:v0.xx.x-slim`) **no incluye** las dependencias de CUDA y PyTorch necesarias para usar GPU.

Por tanto, asegúrate de usar la **imagen completa**:

```bash
docker pull infiniflow/ragflow:v0.20.5


En tu archivo docker-compose-gpu.yml, ajusta la sección del servicio ragflow:

´´´´
services:
  ragflow:
    image: infiniflow/ragflow:v0.20.5  # ❌ No usar la versión slim
    container_name: ragflow-server
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    runtime: nvidia  # Importante para acceso CUDA

´´´´

Luego reconstruye y levanta los servicios:

´´´´
docker compose -f docker-compose-gpu.yml up -d --build

´´´´

⚙️ 2. Comprobaciones iniciales de acceso GPU en el contenedor
🧩 2.1 Verificar disponibilidad de GPU desde Docker

Ejecuta:

´´´´
docker exec -it ragflow-server nvidia-smi

´´´´

Si la GPU aparece listada, el contenedor tiene acceso correcto a CUDA.
Ejemplo de salida esperada:

´´´´
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 550.78       Driver Version: 550.78       CUDA Version: 12.4     |
| GPU Name        Persistence-M| Bus-Id     Disp.A | Volatile Uncorr. ECC |
| 0  NVIDIA GeForce RTX 4060    Off  | 00000000:01:00.0 Off | N/A |
| Processes:                                                       |
|  GPU   GI   CI        PID   Type   Process name       GPU Memory |
|    0   N/A  N/A      2103      C   python3                 512MiB |
+-----------------------------------------------------------------------------+

´´´´

🧮 2.2 Validar acceso CUDA mediante PyTorch

Abre una shell dentro del contenedor:

´´´´
docker exec -it ragflow-server bash

´´´´

Luego ejecuta:

´´´´
python3 -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'No GPU detected')"

´´´´

Salida esperada:

´´´´
True
NVIDIA GeForce RTX 4060

´´´´

Esto confirma que PyTorch (y por ende Ragflow) puede usar la GPU.

⚡ 3. Comprobar que Ragflow realmente usa la GPU
🔍 3.1 Monitoreo directo del uso

Durante el procesamiento de documentos (por ejemplo, PDFs o embeddings), ejecuta:


´´´´
docker exec -it ragflow-server nvidia-smi

´´´´´

Si ves actividad en la columna “GPU-Util” (>0%) o memoria GPU usada (>0MiB), Ragflow está ejecutando tareas sobre GPU.

Para monitoreo en tiempo real:

´´´´
watch -n 1 nvidia-smi
´´´´

🧾 3.2 Comprobación mediante logs

Ejecuta:


´´´´
docker logs ragflow-server | grep -i cuda

´´´´

Salida esperada (o similar):

´´´´
Using CUDA backend for inference
Torch backend initialized on device cuda:0

´´´´

Esto confirma que Ragflow está despachando procesos a CUDA.

⏱️ 3.3 Verificación de rendimiento (opcional)

Puedes comparar el tiempo de procesamiento con y sin GPU:

Procesa un documento grande con GPU activa:

´´´´
time docker exec -it ragflow-server python3 -m ragflow.some_module

´´´´

Luego comenta el bloque devices: en el YAML (sin GPU) y repite la prueba.

Si el tiempo se reduce significativamente con GPU, Ragflow está utilizando aceleración por hardware correctamente.

