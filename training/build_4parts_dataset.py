# -*- coding: utf-8 -*-
"""
Script de generación de Dataset en 4 Partes para Fine-Tuning de Qwen (Koha UABC)
Basado en el acervo oficial de la Biblioteca Central Mexicali (114,817 registros).
Genera 4 archivos JSONL de exactamente 2,500 muestras cada uno (10,000 muestras totales)
en formato ChatML compatible con Unsloth, HuggingFace y LocalLlmService (.NET).
"""

import csv
import json
import os
import re
import random
import urllib.parse

# Fijar semilla para reproducibilidad
random.seed(42)

CSV_PATH = r"C:\Users\Nera\Downloads\DIB-ACERVO-BIBLIOTECA CENTRAL MEXICALI.csv"
TRAINING_DIR = r"C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\training"
DESKTOP_DIR = r"C:\Users\Nera\Desktop"

SYSTEM_PROMPT = (
    "Eres el asistente inteligente de la Biblioteca Central Campus Mexicali (UABC). "
    "Tu función es analizar la consulta del usuario en lenguaje natural y extraer la intención "
    "y parámetros de búsqueda para la API de KOHA en formato JSON."
)

DOMAIN_DEFS = {
    "parte1_ingenieria": {
        "name": "Parte 1: Ingeniería, Tecnología y Computación",
        "filename": "dataset_koha_parte1_ingenieria.jsonl",
        "prefixes": {'QA', 'TK', 'TA', 'TJ', 'T', 'TS', 'TH', 'TP', 'TN', 'TL', 'TR', 'TC', 'TD', 'TE'},
        "topics": [
            "inteligencia artificial", "machine learning", "deep learning", "redes neuronales",
            "aprendizaje profundo", "procesamiento de lenguaje natural", "visión por computadora",
            "robótica", "mecatrónica", "automatización industrial", "control automático",
            "sistemas de control", "sensores y actuadores", "microcontroladores", "arduino",
            "programación en python", "programación en c++", "programación orientada a objetos",
            "estructuras de datos", "análisis de algoritmos", "sistemas operativos",
            "bases de datos relacionales", "sql", "nosql", "ciberseguridad", "seguridad informática",
            "criptografía", "redes de computadoras", "telecomunicaciones", "antenas",
            "circuitos eléctricos", "electrónica digital", "microelectrónica", "sistemas embebidos",
            "cálculo diferencial", "cálculo integral", "cálculo multivariable", "álgebra lineal",
            "ecuaciones diferenciales", "métodos numéricos", "probabilidad y estadística para ingenieros",
            "física para ingeniería", "estática", "dinámica", "mecánica de materiales",
            "resistencia de materiales", "termodinámica", "mecánica de fluidos", "transferencia de calor",
            "ingeniería civil", "estructuras de concreto", "análisis estructural", "geotecnia",
            "mecánica de suelos", "topografía", "hidráulica", "ingeniería ambiental",
            "ingeniería química", "balance de materia y energía", "cinética química", "reactores químicos",
            "operaciones unitarias", "ingeniería industrial", "investigación de operaciones",
            "control estadístico de la calidad", "manufactura esbelta", "lean manufacturing", "six sigma",
            "ergonomía", "seguridad e higiene industrial", "diseño asistido por computadora", "autocad",
            "solidworks", "simulación de sistemas", "redes neuronales convolucionales", "minería de datos",
            "big data", "cloud computing", "arquitectura de computadoras", "sistemas distribuidos"
        ]
    },
    "parte2_derecho_humanidades": {
        "name": "Parte 2: Ciencias Sociales, Derecho y Humanidades",
        "filename": "dataset_koha_parte2_ciencias_sociales_derecho.jsonl",
        "prefixes": {'KGF', 'K', 'KG', 'KD', 'KF', 'F', 'PQ', 'PN', 'PS', 'P', 'LB', 'L', 'B', 'BF', 'JL', 'JC', 'J', 'GE', 'GV'},
        "topics": [
            "derecho constitucional mexicano", "garantías individuales", "derechos humanos",
            "juicio de amparo", "derecho penal", "teoría del delito", "criminología", "criminalística",
            "derecho civil", "obligaciones y contratos", "bienes y sucesiones", "derecho de familia",
            "derecho mercantil", "sociedades mercantiles", "títulos y operaciones de crédito",
            "derecho laboral", "ley federal del trabajo", "seguridad social", "derecho procesal laboral",
            "derecho administrativo", "derecho fiscal", "código fiscal de la federación", "amparo fiscal",
            "derecho internacional público", "derecho internacional privado", "tratados internacionales",
            "juicios orales", "sistema penal acusatorio", "medios alternos de solución de conflictos",
            "argumentación jurídica", "filosofía del derecho", "sociología jurídica",
            "historia de méxico", "revolución mexicana", "independencia de méxico", "méxico contemporáneo",
            "historia de baja california", "historia de mexicali", "frontera norte de méxico",
            "literatura mexicana", "literatura latinoamericana", "narrativa hispanoamericana", "poesía mexicana",
            "redacción avanzada", "expresión oral y escrita", "gramática y ortografía", "lingüística",
            "metodología de la investigación", "técnicas de investigación documental", "epistemología",
            "pedagogía", "didáctica general", "diseño curricular", "evaluación del aprendizaje",
            "educación superior", "docencia universitaria", "tecnología educativa",
            "filosofía clásica", "ética profesional", "bioética", "lógica formal",
            "psicología general", "psicología cognitiva", "psicología del desarrollo", "psicoterapia",
            "psicología social", "psicometría", "pruebas psicológicas", "neuropsicología",
            "ciencias políticas", "partidos políticos en méxico", "políticas públicas", "comunicación y medios"
        ]
    },
    "parte3_admon_economia": {
        "name": "Parte 3: Administración, Economía, Contabilidad y Negocios",
        "filename": "dataset_koha_parte3_administracion_economia.jsonl",
        "prefixes": {'HD', 'HF', 'HC', 'HB', 'HG', 'HM', 'HJ', 'HE'},
        "topics": [
            "administración de empresas", "administración estratégica", "planeación estratégica",
            "teoría general de la administración", "desarrollo organizacional", "comportamiento organizacional",
            "gestión del talento humano", "recursos humanos", "relaciones laborales", "capacitación de personal",
            "liderazgo y trabajo en equipo", "emprendimiento", "creación de empresas", "plan de negocios",
            "gestión de la calidad", "administración de la producción", "cadena de suministro", "logística internacional",
            "comercio internacional", "negocios internacionales", "aduanas", "t-mec", "aranceles y tratados",
            "mercadotecnia", "marketing digital", "investigación de mercados", "comportamiento del consumidor",
            "estrategias de precios", "publicidad y promoción", "redes sociales para negocios",
            "contabilidad financiera", "contabilidad de costos", "contabilidad administrativa", "normas de información financiera",
            "auditoría de estados financieros", "auditoría interna", "control interno", "contabilidad fiscal",
            "finanzas corporativas", "análisis financiero", "administración financiera", "evaluación de proyectos de inversión",
            "mercado de dinero y capitales", "bolsa de valores", "portafolios de inversión", "ingeniería financiera",
            "microeconomía", "macroeconomía", "teoría económica", "economía mexicana",
            "econometría", "estadística para negocios", "política monetaria", "banco de méxico",
            "inflación y crecimiento económico", "comercio exterior de méxico", "finanzas públicas",
            "presupuestos empresariales", "gestión de inventarios", "toma de decisiones gerenciales"
        ]
    },
    "parte4_salud_ciencias": {
        "name": "Parte 4: Salud, Medicina, Ciencias Básicas y Artes",
        "filename": "dataset_koha_parte4_salud_ciencias_basicas.jsonl",
        "prefixes": {'QC', 'QD', 'QH', 'QK', 'QL', 'QR', 'Q', 'R', 'RA', 'RB', 'RC', 'RD', 'RM', 'RT', 'RJ', 'RK', 'S', 'SB', 'SF', 'NA', 'N', 'NK', 'Z', 'M'},
        "topics": [
            "anatomía humana", "fisiología médica", "histología", "embriología", "patología humana",
            "bioquímica médica", "biología celular y molecular", "genética humana", "microbiología médica",
            "inmunología", "parasitología", "farmacología médica", "farmacología clínica",
            "medicina interna", "semiología clínica", "propedéutica médica", "diagnóstico clínico",
            "cirugía general", "pediatría", "ginecología y obstetricia", "cardiología", "neumología",
            "gastroenterología", "neurología", "dermatología", "urgencias médicas", "traumatología",
            "enfermería médico-quirúrgica", "fundamentos de enfermería", "cuidados intensivos de enfermería",
            "salud pública", "epidemiología", "bioestadística médica", "medicina preventiva",
            "nutrición clínica", "dietoterapia", "bromatología", "nutrición en el deporte",
            "física general", "mecánica clásica", "electromagnetismo", "óptica", "termodinámica física",
            "física moderna", "física cuántica", "física médica",
            "química general", "química inorgánica", "química orgánica", "química analítica",
            "fisicoquímica", "análisis instrumental", "cromatografía", "espectroscopía",
            "biología general", "ecología", "conservación ambiental", "botánica", "zoología",
            "diseño arquitectónico", "historia de la arquitectura", "urbanismo", "teoría de la arquitectura",
            "dibujo arquitectónico", "instalaciones en edificaciones", "arquitectura bioclimática",
            "historia del arte", "diseño gráfico", "teoría del color", "composición visual",
            "agronomía", "edafología", "riego y drenaje", "parasitología agrícola", "veterinaria y zootecnia"
        ]
    }
}

FAQ_SAMPLES = [
    ("¿Cuál es el horario de la biblioteca central de mexicali?", "informacion_biblioteca", "horarios"),
    ("¿A qué hora abren y cierran entre semana?", "informacion_biblioteca", "horarios"),
    ("horarios de atencion", "informacion_biblioteca", "horarios"),
    ("¿Abren los sábados?", "informacion_biblioteca", "horarios"),
    ("¿Cuál es el horario del sábado?", "informacion_biblioteca", "horarios"),
    ("¿Cómo saco mi credencial de la biblioteca?", "informacion_biblioteca", "credencial"),
    ("requisitos para tramitar credencial de biblioteca uabc", "informacion_biblioteca", "credencial"),
    ("perdi mi credencial como la repongo?", "informacion_biblioteca", "credencial"),
    ("¿Cuántos libros puedo pedir prestados a domicilio?", "informacion_biblioteca", "prestamo a domicilio"),
    ("¿Por cuántos días te prestan los libros?", "informacion_biblioteca", "prestamo a domicilio"),
    ("reglamento de prestamo a domicilio", "informacion_biblioteca", "prestamo a domicilio"),
    ("¿Cómo renuevo un libro que ya tengo prestado?", "informacion_biblioteca", "renovacion de prestamo"),
    ("¿Cuántas veces puedo renovar un libro?", "informacion_biblioteca", "renovacion de prestamo"),
    ("¿Cuánto cobran de multa si entrego tarde?", "informacion_biblioteca", "multas"),
    ("sanciones por entrega tardia de libros", "informacion_biblioteca", "multas"),
    ("¿Cómo aparto un cubículo de estudio grupal?", "informacion_biblioteca", "cubiculos de estudio"),
    ("prestamo de cubiculos", "informacion_biblioteca", "cubiculos de estudio"),
    ("¿Tienen red wifi para estudiantes?", "informacion_biblioteca", "servicios wifi"),
    ("¿Hay computadoras disponibles para consulta?", "informacion_biblioteca", "equipo de computo"),
    ("¿Tienen servicio de copias e impresiones?", "informacion_biblioteca", "fotocopiado e impresion"),
    ("¿Dónde se devuelven los libros prestados?", "informacion_biblioteca", "devolucion de libros"),
    ("Hola, buenas tardes", "saludo", None),
    ("Hola qué tal", "saludo", None),
    ("Buenas tardes", "saludo", None),
    ("Buenos días", "saludo", None),
    ("¿Qué onda bro?", "saludo", None),
    ("Qué onda pa, ocupo ayuda con unos libros", "saludo", None),
    ("Oye carnal, una duda", "saludo", None),
    ("Hola bibliobot", "saludo", None),
    ("Qué onda", "saludo", None),
    ("Muchísimas gracias por la ayuda", "saludo", None),
    ("Gracias compa", "saludo", None),
    ("Sale pues, muchas gracias", "saludo", None)
]

def clean_title(title):
    t = re.sub(r'\[.*?\]', '', title)
    t = t.split('/')[0].strip()
    t = t.split('=')[0].strip()
    t = re.sub(r'[:;.,\s]+$', '', t)
    t = re.sub(r'\s+', ' ', t)
    return t.strip()

def clean_author(author):
    a = re.sub(r'\d{4}(-\d{4})?', '', author)
    a = re.sub(r'[,.;\s]+$', '', a)
    a = re.sub(r'\s+', ' ', a)
    return a.strip()

def make_sample(user_msg, intencion, materia=None, autor=None, koha_query=None):
    params = {
        "materia": materia,
        "autor": autor,
        "koha_query": koha_query
    }
    assistant_content = json.dumps({
        "intencion": intencion,
        "parametros": params
    }, ensure_ascii=False)
    
    return {
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_msg},
            {"role": "assistant", "content": assistant_content}
        ]
    }

def build_datasets():
    print("Iniciando lectura y categorización del catálogo oficial...")
    
    domain_books = {k: [] for k in DOMAIN_DEFS}
    seen_titles = {k: set() for k in DOMAIN_DEFS}

    with open(CSV_PATH, mode='r', encoding='utf-8', errors='replace') as f:
        reader = csv.reader(f, delimiter=';')
        next(reader) # Cabecera
        for row in reader:
            if len(row) < 3:
                continue
            clasif = row[0].strip()
            raw_title = row[1].strip()
            raw_author = row[2].strip()
            subject = row[14].strip() if len(row) > 14 else ''
            
            if not raw_title or len(raw_title) < 4:
                continue

            m = re.match(r'^([A-Z]{1,3})', clasif)
            if not m:
                continue
            prefix = m.group(1)

            ct = clean_title(raw_title)
            ca = clean_author(raw_author)
            if not ct or len(ct) < 4:
                continue

            for dom_key, conf in DOMAIN_DEFS.items():
                if prefix in conf["prefixes"]:
                    # Deduplicar por título limpio en ese dominio
                    title_norm = ct.lower()
                    if title_norm not in seen_titles[dom_key]:
                        seen_titles[dom_key].add(title_norm)
                        domain_books[dom_key].append({
                            "title": ct,
                            "author": ca,
                            "clasif": clasif,
                            "subject": subject
                        })
                    break

    for k, books in domain_books.items():
        print(f"  {DOMAIN_DEFS[k]['name']}: {len(books)} títulos únicos extraídos.")

    os.makedirs(TRAINING_DIR, exist_ok=True)
    os.makedirs(DESKTOP_DIR, exist_ok=True)

    for dom_key, conf in DOMAIN_DEFS.items():
        print(f"\nGenerando {conf['name']} (2,500 muestras)...")
        books = domain_books[dom_key]
        random.shuffle(books)
        topics = conf["topics"]
        samples = []

        # 1. TOPIC QUERIES (40% -> ~1,000 muestras)
        topic_templates = [
            ("¿Qué libros tienen sobre {topic}?", "buscar_libro"),
            ("libros de {topic}", "buscar_libro"),
            ("ocupo info sobre {topic}", "buscar_libro"),
            ("¿Qué onda pa, tienes algo de {topic}?", "buscar_libro"),
            ("oye carnal, ¿hay libros sobre {topic}?", "buscar_libro"),
            ("buenas tardes, busco bibliografía para la materia de {topic}", "buscar_libro"),
            ("material de apoyo para estudiar {topic}", "buscar_libro"),
            ("¿Dónde encuentro libros de {topic} en la biblioteca central?", "buscar_libro"),
            ("al chile ocupo pasar mi examen de {topic}, qué me recomiendas?", "buscar_libro"),
            ("paro, recomiéndame libros buenos de {topic}", "buscar_libro"),
            ("temas relacionados con {topic}", "buscar_libro"),
            ("investigación sobre {topic}", "buscar_libro"),
            ("¿Tienen manuales o guías de {topic}?", "buscar_libro"),
            ("ocupo libros de {topic} para mi tesis", "buscar_libro"),
            ("recomiéndame los mejores libros de {topic} que tengan aquí", "buscar_libro"),
            ("¿Cuentan con textos sobre {topic}?", "buscar_libro"),
            ("bibliografía recomendada para {topic}", "buscar_libro"),
            ("consulta de acervo sobre {topic}", "buscar_libro"),
            ("¿Hay ejemplares de {topic} disponibles?", "consultar_disponibilidad"),
            ("ocupo consultar {topic} en sala", "buscar_libro"),
        ]

        while len(samples) < 1000:
            top = random.choice(topics)
            tmpl, intencion = random.choice(topic_templates)
            user_msg = tmpl.format(topic=top)
            kq = f"q={urllib.parse.quote_plus(top)}"
            samples.append(make_sample(user_msg, intencion, materia=top, autor=None, koha_query=kq))

        # 2. TITLE QUERIES (24% -> 600 muestras de libros reales)
        title_templates = [
            ("¿Tienen el libro '{title}'?", "buscar_libro"),
            ("busco el libro {title}", "buscar_libro"),
            ("ocupo el libro '{title}'", "buscar_libro"),
            ("¿Dónde está ubicado el libro {title}?", "buscar_libro"),
            ("tienes disponible '{title}'?", "consultar_disponibilidad"),
            ("¿Puedo pedir '{title}'?", "buscar_libro"),
            ("¿Cuentan con ejemplares de {title}?", "consultar_disponibilidad"),
            ("oye pa, tienes el de {title}?", "buscar_libro"),
            ("Buenas tardes, estoy buscando el libro {title}", "buscar_libro"),
            ("{title}", "buscar_libro"),
            ("libro {title}", "buscar_libro"),
            ("¿Tienen en catálogo '{title}'?", "buscar_libro")
        ]

        book_idx = 0
        while len(samples) < 1600 and book_idx < len(books):
            b = books[book_idx]
            book_idx += 1
            t = b["title"]
            if len(t) > 75:
                t = t[:75].rsplit(' ', 1)[0]
            tmpl, intencion = random.choice(title_templates)
            user_msg = tmpl.format(title=t)
            kq = f"q={urllib.parse.quote_plus(t)}"
            samples.append(make_sample(user_msg, intencion, materia=t, autor=b["author"] if b["author"] else None, koha_query=kq))

        # 3. AUTHOR + TOPIC / AUTHOR ONLY (20% -> 500 muestras de libros y autores reales)
        author_templates = [
            ("libros de {author}", "buscar_libro"),
            ("¿Qué libros tienen de {author}?", "buscar_libro"),
            ("obras de {author}", "buscar_libro"),
            ("el libro de {author} sobre {topic}", "buscar_libro"),
            ("¿Tienen material de {author}?", "buscar_libro"),
            ("busco lo que tengan de {author}", "buscar_libro"),
            ("textos de {author} para {topic}", "buscar_libro"),
            ("ocupo el libro de {author}", "buscar_libro"),
            ("autor {author}", "buscar_libro"),
            ("¿Tienen algo de {author} enfocado en {topic}?", "buscar_libro")
        ]

        while len(samples) < 2100:
            b = books[book_idx % len(books)]
            book_idx += 1
            author = b["author"]
            if not author or len(author) < 4:
                author_cand = ["Baldor", "Stewart, James", "Russell, Stuart", "Goodfellow, Ian", "Chiavenato, Idalberto", "Samuelson, Paul", "Kotler, Philip", "García Márquez, Gabriel", "Hernández Sampieri, Roberto", "Guyton, Arthur", "Robbins, Stephen"]
                author = random.choice(author_cand)
            top = random.choice(topics)
            tmpl, intencion = random.choice(author_templates)
            user_msg = tmpl.format(author=author, topic=top)
            
            # Limpiar nombre del autor para query
            auth_short = author.split(',')[0].strip()
            if "{topic}" in tmpl:
                kq = f"author={urllib.parse.quote_plus(auth_short)}&q={urllib.parse.quote_plus(top)}"
                samples.append(make_sample(user_msg, intencion, materia=top, autor=author, koha_query=kq))
            else:
                kq = f"author={urllib.parse.quote_plus(auth_short)}"
                samples.append(make_sample(user_msg, intencion, materia=None, autor=author, koha_query=kq))

        # 4. AVAILABILITY CHECK (10% -> 250 muestras)
        avail_templates = [
            ("¿Está disponible '{title}' en sala?", "consultar_disponibilidad"),
            ("¿Tienen copias disponibles de {title}?", "consultar_disponibilidad"),
            ("¿Se puede pedir a domicilio el libro '{title}'?", "consultar_disponibilidad"),
            ("¿Tienen en existencia {title}?", "consultar_disponibilidad"),
            ("ocupo checar si el libro '{title}' está prestado o libre", "consultar_disponibilidad"),
            ("¿Hay copias libres de {title} ahorita en biblioteca?", "consultar_disponibilidad"),
            ("¿Se encuentra en estantería {title}?", "consultar_disponibilidad"),
            ("paro, checa si está libre el libro {title}", "consultar_disponibilidad")
        ]

        while len(samples) < 2350:
            b = books[book_idx % len(books)]
            book_idx += 1
            t = b["title"]
            if len(t) > 70:
                t = t[:70].rsplit(' ', 1)[0]
            tmpl, intencion = random.choice(avail_templates)
            user_msg = tmpl.format(title=t)
            kq = f"q={urllib.parse.quote_plus(t)}"
            samples.append(make_sample(user_msg, intencion, materia=t, autor=b["author"] if b["author"] else None, koha_query=kq))

        # 5. REGLAMENTOS / SERVICIOS / FAQS / SALUDOS (6% -> 150 muestras)
        while len(samples) < 2500:
            faq_msg, intencion, mat = random.choice(FAQ_SAMPLES)
            samples.append(make_sample(faq_msg, intencion, materia=mat, autor=None, koha_query=None))

        # Barajar las 2,500 muestras de este archivo
        random.shuffle(samples)

        # Guardar en training/ y en Desktop/
        training_file = os.path.join(TRAINING_DIR, conf["filename"])
        desktop_file = os.path.join(DESKTOP_DIR, conf["filename"])

        for out_path in [training_file, desktop_file]:
            with open(out_path, mode='w', encoding='utf-8') as out_f:
                for s in samples:
                    out_f.write(json.dumps(s, ensure_ascii=False) + "\n")

        print(f"  [OK] Guardado: {training_file} ({len(samples)} muestras)")
        print(f"  [OK] Guardado: {desktop_file} ({len(samples)} muestras)")

    print("\n¡Generación de las 4 partes completada con éxito!")

if __name__ == "__main__":
    build_datasets()
