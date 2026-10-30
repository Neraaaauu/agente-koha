# Agente Inteligente - Biblioteca Central UABC (Koha API + SLM Local)

Prototipo funcional (MVP) de un agente conversacional para la Biblioteca Central de la Universidad Autónoma de Baja California (Campus Mexicali), desarrollado en el marco del trabajo terminal de maestría (MTAO, FCITEC - UABC).

El sistema permite a los estudiantes consultar material bibliográfico, existencias, estanterías físicas y reglamentos institucionales mediante lenguaje natural coloquial, interactuando de forma desacoplada con la API REST del sistema de gestión bibliotecaria **KOHA**.

---

## Características Principales

* **Inferencia Local en CPU (Sin Costos de Nube):** Utiliza un Small Language Model (**Qwen 2.5 0.5B Instruct**) cuantizado a 4 bits (**GGUF Q4_K_M, 397 MB**) mediante LLamaSharp. Opera de forma 100% on-premise en procesadores convencionales con un consumo menor a **380 MB de memoria RAM**, garantizando privacidad de datos sin pagos por token a APIs externas.
* **Fine-Tuning Especializado:** Ajustado con **LoRA** ($r=32, \alpha=64$) a lo largo de 1,200 pasos sobre un dataset supervisado de **10,000 pares conversacionales** en formato ChatML adaptados a materias de la UABC y jerga estudiantil cimarrona.
* **Preprocesamiento y Control de Precisión:** Normalización de siglas (*IA, BD, POO, SO*), filtrado de muletillas coloquiales, algoritmos de *stem matching* en español y supresión de falsos positivos en el catálogo.
* **Arquitectura Desacoplada (IKohaService):** Cuenta con un entorno **Mock Sandbox** de 750 libros canónicos que reproduce fielmente el estándar OpenAPI de Koha REST v1 (`/api/v1/biblios`). La conmutación al cliente de producción (`KohaApiClient.cs`) se realiza mediante una variable de configuración (`UseMock=false`) en cuanto TI provee las credenciales OAuth2.
* **Despliegue Contenedorizado:** Totalmente empaquetado con **Docker** y **Docker Compose** para ejecución aislada en servidores Linux compartidos sin alterar otros sistemas.

---

## 📥 Descarga del Modelo Entrenado (GGUF)

Debido al límite de tamaño de archivos de GitHub (100 MB), los pesos cuantizados del modelo maestro (~397 MB) se encuentran alojados en Google Drive:

👉 **[Descargar qwen_entrenado_koha.gguf desde Google Drive](https://drive.google.com/file/d/12S3ppYByCx_Gpxml4yGP-B8VU0RwXh_C/view?usp=sharing)**

Una vez descargado, colócalo en la carpeta `Models/` del proyecto:
```bash
mkdir -p Models
# Colocar qwen_entrenado_koha.gguf dentro de Models/
```

---

## Estructura del Proyecto

```text
koha_agent_mvp/
├── Models/                 # Entidades del dominio y directorio para qwen_entrenado_koha.gguf
├── Services/
│   ├── AgentService.cs     # Orquestador del agente, reglas de negocio y formateo
│   ├── LocalLlmService.cs  # Inferencia local en CPU con LLamaSharp
│   ├── IKohaService.cs     # Interfaz abstracta del catálogo
│   ├── KohaMockService.cs  # Sandbox RFC con acervo representativo de Mexicali (750 libros)
│   └── KohaApiClient.cs    # Cliente oficial Koha REST API v1 (OAuth 2.0)
├── training/               # Cuadernos de Colab, generadores y datasets ChatML (10,000 muestras)
├── wwwroot/                # Interfaz web del chat (SPA) y diapositivas interactivas
├── catalog_mock.json       # Acervo representativo con 750 registros MARC21
├── Dockerfile              # Construcción multi-etapa en .NET 10
├── docker-compose.yml      # Definición del servicio y túnel de pruebas
├── MANUAL_INSTALACION_SERVIDOR.md  # Guía para administradores de sistemas
└── Program.cs              # Punto de entrada y Minimal APIs de ASP.NET Core
```

---

## Despliegue Rápido en Servidor

Para detalles completos sobre instalación en servidores institucionales y actualización continua, consultar el [Manual de Instalación en Servidor](MANUAL_INSTALACION_SERVIDOR.md).

### 1. Requisitos
* Docker y Docker Compose
* Git

### 2. Arranque con Docker
```bash
# 1. Clonar el repositorio
git clone https://github.com/Neraaaauu/agente-koha.git
cd agente-koha

# 2. Descargar el modelo y colocarlo en Models/
# Enlace: https://drive.google.com/file/d/12S3ppYByCx_Gpxml4yGP-B8VU0RwXh_C/view?usp=sharing
mkdir -p Models
# Mover qwen_entrenado_koha.gguf a Models/

# 3. Construir y levantar contenedor
docker compose up -d --build
```

El servicio estará disponible en `http://localhost:5000` (o en la IP del servidor).

### 3. Actualización de Versiones
Para aplicar cambios futuros publicados en el repositorio:
```bash
git pull origin main
docker compose up -d --build
```

---

## Ejecución Local en Desarrollo (Windows / Linux)

Requisitos: **.NET 10 SDK**.

```bash
# Restaurar y compilar
dotnet build

# Ejecutar
dotnet run
```
Abrir el navegador en `http://localhost:5000` para el chat interactivo, o `http://localhost:5000/presentacion.html` para la presentación del proyecto.
