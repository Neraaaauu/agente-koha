# Manual de Instalación y Mantenimiento en Servidor
## Agente Inteligente para Biblioteca Central UABC

Este manual está diseñado para el personal técnico y administradores de sistemas del servidor de la biblioteca. Explica la arquitectura de aislamiento, los pasos de despliegue inicial y el procedimiento para aplicar actualizaciones futuras de forma segura sin afectar otros sistemas.

---

### 1. Garantía de Aislamiento (No Afectación a Otros Sistemas)

Uno de los principales requisitos es garantizar que este proyecto **no interfiera con los sistemas existentes en el servidor** (como el OPAC de Koha, Apache, MySQL/MariaDB, PHP u otros servicios internos).

* **Aislamiento por Contenedores (Docker):** Toda la aplicación, el runtime de .NET 10 y las librerías nativas corren estrictamente encapsuladas dentro de un contenedor Docker independiente.
* **Cero Modificaciones al Sistema Host:** No es necesario instalar .NET, SDKs ni dependencias globales en el sistema operativo del servidor.
* **Independencia de Puertos:** El servicio escucha en un puerto exclusivo asignable (por defecto `5000`, modificable a cualquier puerto libre como `5050`, `8080`, etc.).
* **Reversibilidad Inmediata:** Si en algún momento se desea pausar o retirar el servicio, basta con ejecutar `docker compose down`, sin dejar residuos ni alterar configuraciones de otros aplicativos.

---

### 2. Requisitos del Servidor

* **Sistema Operativo:** Cualquier distribución Linux moderna (Ubuntu Server, Debian, AlmaLinux, Rocky Linux, CentOS 8+, etc.).
* **Herramientas Base:** `git`, `docker` y `docker compose` (plugin de Docker).
* **Recursos de Hardware:**
  * **RAM:** Mínimo 1 GB libre (el contenedor opera en ~380 MB).
  * **CPU:** 2 núcleos virtuales o físicos (inferencia en CPU pura, sin requerir GPU dedicada).
  * **Disco:** ~1.5 GB de espacio libre (para la imagen base y el archivo del modelo).

---

### 3. Instalación Paso a Paso

#### Paso 3.1: Clonar el Repositorio
En la terminal del servidor, clonar el proyecto en el directorio deseado (por ejemplo, en el home del usuario o en `/opt/`):

```bash
git clone https://github.com/Neraaaauu/agente-koha.git
cd agente-koha
```

#### Paso 3.2: Descargar y Colocar el Modelo de Lenguaje
El modelo cuantizado `qwen_entrenado_koha.gguf` (397 MB) no se aloja directamente en GitHub por límites de almacenamiento. Se encuentra disponible en Google Drive:

👉 **[Descargar qwen_entrenado_koha.gguf desde Google Drive](https://drive.google.com/file/d/12S3ppYByCx_Gpxml4yGP-B8VU0RwXh_C/view?usp=sharing)**

Una vez descargado, crear la carpeta `Models/` y colocar el archivo dentro:

```bash
mkdir -p Models
# Colocar qwen_entrenado_koha.gguf dentro de Models/
```

Verificar que el archivo exista en la ruta correcta:
```bash
ls -lh Models/qwen_entrenado_koha.gguf
```

#### Paso 3.3: Configurar el Puerto (Opcional)
Por defecto, el servicio expone el puerto `5000`. Si el servidor ya tiene ocupado este puerto con otro aplicativo interno, editar el archivo `docker-compose.yml`:

```yaml
ports:
  - "5050:5000"   # Cambiar el primer número al puerto libre deseado en el host
```

#### Paso 3.4: Levantar el Servicio
Ejecutar el comando de construcción y arranque:

```bash
docker compose up -d --build
```

Docker compilará la aplicación dentro del contenedor y la levantará en segundo plano en cuestión de segundos.

#### Paso 3.5: Verificación de Estado
Comprobar que el contenedor esté corriendo:
```bash
docker ps | grep koha_agent_uabc
```

Probar el endpoint de estado:
```bash
curl http://localhost:5000/api/status
```
Debe responder con un JSON indicando `"status": "En línea"`, `"isLlmActive": true` e `"indexedRecords": 750`.

---

### 4. Procedimiento para Subir Actualizaciones Futuras

Cuando se publiquen mejoras, ajustes en el catálogo o cambios en el código en el repositorio de GitHub, el administrador o encargado puede actualizar el servidor en menos de un minuto con solo dos comandos:

```bash
cd ~/agente-koha

# 1. Descargar los últimos cambios del repositorio
git pull origin main

# 2. Reconstruir y reiniciar el contenedor
docker compose up -d --build
```

Docker detectará los archivos modificados, recompilará únicamente las capas necesarias y reiniciará el contenedor con la nueva versión de forma fluida y sin interrumpir los demás servicios del servidor.

---

### 5. Comandos de Operación y Monitoreo

* **Ver los registros en tiempo real:**
  ```bash
  docker compose logs -f koha-agent
  ```

* **Reiniciar el agente:**
  ```bash
  docker compose restart koha-agent
  ```

* **Pausar o detener el servicio:**
  ```bash
  docker compose down
  ```

* **Comprobar consumo de memoria y CPU del contenedor:**
  ```bash
  docker stats koha_agent_uabc --no-stream
  ```
