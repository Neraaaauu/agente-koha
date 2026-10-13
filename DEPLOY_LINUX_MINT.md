# Guía de Despliegue en Docker (Linux Mint / Servidores Linux)

Esta guía explica cómo levantar el **Agente Inteligente de Biblioteca Central UABC** en tu PC secundaria con Linux Mint o cualquier servidor Linux universitario.

---

## 1. Requisitos Previos en Linux Mint

Abre una terminal en Linux Mint e instala Docker y Docker Compose:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```
*(Si es la primera vez que agregas tu usuario al grupo docker, cierra sesión y vuelve a entrar o reinicia).*

---

## 2. Copiar los archivos a Linux Mint

Pasa la carpeta del proyecto a tu otra PC (por memoria USB o por red). Asegúrate de que incluya:
* El archivo del modelo: `models/qwen_entrenado_koha.gguf` (397 MB).
* Los archivos: `Dockerfile`, `docker-compose.yml`, `Program.cs`, etc.

---

## 3. Construir y Levantar el Contenedor

Dentro de la carpeta del proyecto en Linux Mint, ejecuta:

```bash
docker-compose up -d --build
```

Docker descargará el SDK de .NET 10, compilará la aplicación con optimizaciones de Release, instalará las librerías nativas (`libgomp1` para OpenMP) y levantará el servicio.

---

## 4. Verificar que esté Corriendo

Para ver los registros en tiempo real:
```bash
docker logs -f koha_agent_uabc
```

Para probarlo localmente en Linux Mint:
* Abre el navegador en: `http://localhost:5000`
* O la presentación en: `http://localhost:5000/presentacion.html`

Para acceder desde tu laptop por la red local (mismo WiFi):
* Averigua la IP de tu PC Linux Mint con `hostname -I` (ej. `192.168.1.45`).
* En tu laptop Windows navega a: `http://192.168.1.45:5000`

Para acceder desde cualquier lugar por Internet con Cloudflare Tunnel:
* Ejecuta:
  ```bash
  docker logs koha_tunnel 2>&1 | grep -o 'https://.*\.trycloudflare\.com'
  ```
* Te devolverá un enlace público HTTPS seguro (ej. `https://random-name.trycloudflare.com`).
* ¡Puedes abrir ese enlace desde tu laptop Windows, celular o compartirlo en la presentación sin configurar nada en el módem!

---

## 5. Detener el Contenedor

Cuando termines tus pruebas:
```bash
docker-compose down
```
