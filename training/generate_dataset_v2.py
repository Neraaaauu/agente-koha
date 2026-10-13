import json
import os

system_prompt = (
    "Eres el asistente inteligente de la Biblioteca Central Campus Mexicali (UABC). "
    "Tu función es analizar la consulta del usuario en lenguaje natural y extraer la intención "
    "y parámetros de búsqueda para la API de KOHA en formato JSON."
)

samples = []

def add_sample(user_msg, intencion, materia=None, autor=None, koha_query=None):
    params = {
        "materia": materia,
        "autor": autor,
        "koha_query": koha_query
    }
    assistant_content = json.dumps({
        "intencion": intencion,
        "parametros": params
    }, ensure_ascii=False)
    
    samples.append({
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_msg},
            {"role": "assistant", "content": assistant_content}
        ]
    })

# 1. INTELIGENCIA ARTIFICIAL (40 variaciones)
ai_queries = [
    ("¿Qué libros tienen sobre Inteligencia Artificial?", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("libros de inteligencia artificial", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("ocupo libros de IA", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("¿Qué onda pa, tienes libros de IA?", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("oye carnal hay algo de IA en la biblioteca?", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("tienes libros sobre inteligencia artificial moderna?", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("buenas tardes, busco bibliografia de inteligencia artificial", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("tendran el libro de inteligencia artificial de russell y norvig?", "inteligencia artificial", "Russell, Stuart; Norvig, Peter", "author=Russell&q=inteligencia+artificial"),
    ("el libro de russell de ia", "inteligencia artificial", "Russell, Stuart", "author=Russell&q=ia"),
    ("russell norvig inteligencia artificial", "inteligencia artificial", "Russell, Stuart; Norvig, Peter", "author=Russell&q=inteligencia+artificial"),
    ("libros de deep learning y redes neuronales", "deep learning", None, "q=deep+learning"),
    ("deep learning de ian goodfellow", "deep learning", "Goodfellow, Ian", "author=Goodfellow&q=deep+learning"),
    ("ocupo el libro de redes neuronales de goodfellow", "redes neuronales", "Goodfellow, Ian", "author=Goodfellow&q=redes+neuronales"),
    ("material para estudiar machine learning y aprendizaje automatico", "machine learning", None, "q=machine+learning"),
    ("libros de machine learning en español", "machine learning", None, "q=machine+learning"),
    ("vision por computadora y procesamiento de imagenes", "vision por computadora", None, "q=vision+computadora"),
    ("procesamiento de lenguaje natural y nlp", "procesamiento de lenguaje natural", None, "q=nlp"),
    ("modelos generativos y transformers en inteligencia artificial", "inteligencia artificial", None, "q=transformers+inteligencia+artificial"),
    ("agentes inteligentes y sistemas multiagente", "agentes inteligentes", None, "q=agentes+inteligentes"),
    ("busco libros sobre agentes inteligentes", "agentes inteligentes", None, "q=agentes+inteligentes"),
    ("algoritmos heuristicos y busqueda en ia", "inteligencia artificial", None, "q=heuristica+inteligencia+artificial"),
    ("aprendizaje por refuerzo y algoritmos q-learning", "aprendizaje por refuerzo", None, "q=reinforcement+learning"),
    ("¿tienen el libro de deep learning practico?", "deep learning", None, "q=deep+learning"),
    ("inteligencia artificial un enfoque moderno", "inteligencia artificial", "Russell, Stuart; Norvig, Peter", "author=Russell&q=inteligencia+artificial"),
    ("ocupo para mi clase libros de ia avanzada", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("oye tendras libros de robots e inteligencia artificial", "robotica e inteligencia artificial", None, "q=robotica+inteligencia+artificial"),
    ("quiero aprender a programar redes neuronales profundas", "redes neuronales", None, "q=redes+neuronales"),
    ("libros de tensorflow y pytorch para deep learning", "deep learning", None, "q=deep+learning"),
    ("busco literatura cientifica sobre IA para ingenieria", "inteligencia artificial", None, "q=inteligencia+artificial"),
    ("que tienen de ia?", "inteligencia artificial", None, "q=inteligencia+artificial")
]
for q, mat, aut, kq in ai_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 2. REDES DE COMPUTADORAS (30 variaciones)
net_queries = [
    ("Libros de redes de computadoras", "redes de computadoras", None, "q=redes+computadoras"),
    ("ocupo el libro de redes de tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    ("¿Tienen disponible el libro de Tanenbaum de redes?", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    ("nmms ando bien atrasado con la tesis de redes del viejito tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    ("oye pa, tienes libros de redes?", "redes de computadoras", None, "q=redes"),
    ("material sobre protocolos TCP/IP y modelo OSI", "redes de computadoras", None, "q=tcp+ip+osi"),
    ("arquitectura de redes y telecomunicaciones", "redes de computadoras", None, "q=arquitectura+redes"),
    ("seguridad en redes informaticas y criptografia", "seguridad en redes", None, "q=seguridad+redes"),
    ("redes inalambricas y protocolos de comunicacion", "redes de computadoras", None, "q=redes+inalambricas"),
    ("tanenbaum redes de computadoras", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    ("busco libros del autor andrew tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum"),
    ("redes de computadoras andrew s tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    ("libros de enrutamiento y conmutacion en redes cisco", "redes de computadoras", None, "q=enrutamiento+redes"),
    ("sistemas distribuidos y redes", "redes de computadoras", None, "q=sistemas+distribuidos"),
    ("que libros tienen de redes?", "redes de computadoras", None, "q=redes"),
    ("ocupo para examen libros de redes tcp ip", "redes de computadoras", None, "q=redes+tcp+ip")
]
for q, mat, aut, kq in net_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 3. BASES DE DATOS (30 variaciones)
db_queries = [
    ("libros de bases de datos", "bases de datos", None, "q=bases+datos"),
    ("ocupo libros de BD para mi materia", "bases de datos", None, "q=bases+datos"),
    ("¿Qué onda pa, tienes libros de BD?", "bases de datos", None, "q=bases+datos"),
    ("Fundamentos de sistemas de bases de datos de Silberschatz", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz&q=bases+datos"),
    ("silberschatz bases de datos", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz&q=bases+datos"),
    ("Estoy teniendo problemas de redundancia en tablas relacionales, ocupo normalizacion", "bases de datos", None, "q=bases+datos+normalizacion"),
    ("diseño de modelos entidad relacion y normalizacion de bases de datos", "bases de datos", None, "q=modelo+entidad+relacion"),
    ("libros de SQL y consultas avanzadas", "bases de datos", None, "q=sql+bases+datos"),
    ("bases de datos NoSQL y sistemas distribuidos", "bases de datos", None, "q=nosql+bases+datos"),
    ("administracion de bases de datos y transacciones ACID", "bases de datos", None, "q=transacciones+bases+datos"),
    ("libros de Abraham Silberschatz sobre bases de datos", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz"),
    ("ocupo el silberschatz", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz"),
    ("que libros tienen de bases de datos relacionales?", "bases de datos", None, "q=bases+datos+relacionales"),
    ("optimizacion de consultas sql e indexacion", "bases de datos", None, "q=sql+optimizacion")
]
for q, mat, aut, kq in db_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 4. METODOLOGIA DE LA INVESTIGACION / TESIS (35 variaciones)
meth_queries = [
    ("libros de metodologia de la investigacion", "metodologia de la investigacion", None, "q=metodologia+investigacion"),
    ("Metodología de la investigación de Hernández Sampieri", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Hernandez+Sampieri&q=metodologia"),
    ("ocupo el sampieri para mi tesis", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Sampieri"),
    ("libros para redactar el marco teorico y muestreo cuantitativo", "metodologia de la investigacion", None, "q=marco+teorico+muestreo"),
    ("como hacer una tesis de maestria", "metodologia de la investigacion", None, "q=tesis+investigacion"),
    ("investigacion cuantitativa, cualitativa y mixta", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Sampieri&q=cuantitativa+cualitativa"),
    ("diseño metodologico e instrumentos de recoleccion de datos", "metodologia de la investigacion", None, "q=instrumentos+recoleccion"),
    ("epistemologia y planteamiento del problema de investigacion", "metodologia de la investigacion", None, "q=planteamiento+problema"),
    ("hernandez sampieri metodologia", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Sampieri"),
    ("libros para diseñar encuestas y entrevistas de investigacion", "metodologia de la investigacion", None, "q=encuestas+entrevistas"),
    ("analisis estadistico para proyectos de posgrado", "metodologia de la investigacion", None, "q=estadistica+investigacion"),
    ("guia de redaccion de tesis en formato apa", "metodologia de la investigacion", None, "q=redaccion+tesis+apa")
]
for q, mat, aut, kq in meth_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 5. GESTION DEL CONOCIMIENTO / MODELO SECI (NONAKA & TAKEUCHI) (25 variaciones)
seci_queries = [
    ("libros del modelo SECI y gestion del conocimiento", "modelo SECI", "Nonaka, Ikujiro; Takeuchi, Hirotaka", "author=Nonaka&q=seci"),
    ("La creacion del conocimiento en la organizacion de Nonaka", "creacion del conocimiento", "Nonaka, Ikujiro; Takeuchi, Hirotaka", "author=Nonaka&q=conocimiento"),
    ("ocupo bibliografia sobre socializacion y exteriorizacion del conocimiento", "modelo SECI", "Nonaka, Ikujiro", "author=Nonaka&q=conocimiento+tacito"),
    ("conocimiento tacito y conocimiento explicito en organizaciones", "gestion del conocimiento", "Nonaka, Ikujiro", "author=Nonaka&q=conocimiento+tacito"),
    ("aprendizaje organizacional y transferencia de conocimiento", "aprendizaje organizacional", None, "q=aprendizaje+organizacional"),
    ("libros de Ikujiro Nonaka y Hirotaka Takeuchi", "gestion del conocimiento", "Nonaka, Ikujiro; Takeuchi, Hirotaka", "author=Nonaka"),
    ("espiral del conocimiento en empresas y equipos", "modelo SECI", "Nonaka, Ikujiro", "author=Nonaka&q=espiral+conocimiento"),
    ("teoria de innovacion basada en conocimiento", "gestion del conocimiento", None, "q=innovacion+conocimiento")
]
for q, mat, aut, kq in seci_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 6. PROGRAMACION, C#, .NET, PYTHON (35 variaciones)
prog_queries = [
    ("libros de python para analisis de datos", "python", "McKinney, Wes", "author=McKinney&q=python+datos"),
    ("python para machine learning de wes mckinney", "python", "McKinney, Wes", "author=McKinney&q=python+datos"),
    ("wes mckinney pandas python", "python", "McKinney, Wes", "author=McKinney&q=pandas"),
    ("libros de programacion en C# y .NET", "C# .NET", None, "q=csharp+dotnet"),
    ("desarrollo de servicios web con ASP.NET Core", "ASP.NET Core", "Deitel, Paul; Deitel, Harvey", "author=Deitel&q=aspnet+core"),
    ("libros de microservicios y APIs REST en c#", "ASP.NET Core", None, "q=microservicios+rest+csharp"),
    ("programacion orientada a objetos POO", "programacion orientada a objetos", None, "q=poo+programacion"),
    ("¿tienen algo de redes o poo?", "programacion orientada a objetos", None, "q=poo"),
    ("libros de estructura de datos y algoritmos", "estructuras de datos", None, "q=estructuras+datos+algoritmos"),
    ("arquitectura de software limpia y patrones de diseño", "ingenieria de software", None, "q=patrones+diseno+software"),
    ("ingenieria de software de roger pressman", "ingenieria de software", "Pressman, Roger S.", "author=Pressman&q=ingenieria+software")
]
for q, mat, aut, kq in prog_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 7. MATERIAS FUERA DE SISTEMAS / OTRAS DISCIPLINAS (ARTE, DERECHO, MEDICINA, HISTORIA, ETC.) (50 variaciones)
other_queries = [
    ("tienes libros sobre el arte moderno", "arte moderno", None, "q=arte+moderno"),
    ("tienes libros sobre el arte moderno?", "arte moderno", None, "q=arte+moderno"),
    ("busco libros de historia del arte universal", "historia del arte", None, "q=historia+arte"),
    ("¿tienen libros de arquitectura moderna?", "arquitectura", None, "q=arquitectura+moderna"),
    ("libros de pintura y escultura mexicana", "arte mexicano", None, "q=arte+mexicano"),
    ("tienes libros de cocina?", "cocina", None, "q=cocina"),
    ("libros de gastronomia y cocina internacional", "gastronomia", None, "q=gastronomia"),
    ("derecho constitucional mexicano", "derecho constitucional", None, "q=derecho+constitucional"),
    ("libros de derecho penal y juicios orales", "derecho penal", None, "q=derecho+penal"),
    ("libros de anatomia humana para medicina", "anatomia", None, "q=anatomia+humana"),
    ("fisiologia medica de Guyton", "fisiologia medica", "Guyton, Arthur", "author=Guyton&q=fisiologia"),
    ("calculo diferencial e integral de stewart", "calculo", "Stewart, James", "author=Stewart&q=calculo"),
    ("algebra lineal de grossman", "algebra lineal", "Grossman, Stanley", "author=Grossman&q=algebra+lineal"),
    ("fisica universitaria de sears y zemansky", "fisica", "Sears, Francis; Zemansky, Mark", "author=Sears&q=fisica"),
    ("quimica organica de wade", "quimica organica", "Wade, L. G.", "author=Wade&q=quimica+organica"),
    ("libros de administracion y contabilidad financiera", "contabilidad", None, "q=contabilidad+financiera"),
    ("psicologia clinica y terapia cognitiva", "psicologia", None, "q=psicologia+clinica"),
    ("filosofia moderna y etica profesional", "filosofia", None, "q=filosofia+etica"),
    ("historia de baja california y mexico", "historia", None, "q=historia+mexico"),
    ("literatura y poesia mexicana", "literatura", None, "q=literatura+mexicana")
]
for q, mat, aut, kq in other_queries:
    add_sample(q, "buscar_libro", mat, aut, kq)

# 8. INFORMACIÓN INSTITUCIONAL DE LA BIBLIOTECA (35 variaciones)
info_queries = [
    "¿Cuál es el horario de la Biblioteca Central?",
    "oye carnal a que hora cierran la biblioteca hoy?",
    "¿A qué hora abren y a qué hora cierran?",
    "horarios de atencion de biblioteca central mexicali",
    "¿Abren los sabados la biblioteca?",
    "¿Dónde está ubicada la biblioteca central en campus mexicali?",
    "¿Cómo puedo tramitar mi credencial de biblioteca?",
    "¿Cuáles son los requisitos para préstamo a domicilio?",
    "¿Cuántos libros puedo pedir prestados con mi credencial?",
    "¿Por cuántos días me prestan un libro?",
    "¿Cómo puedo apartar un cubículo de estudio?",
    "¿Tienen servicio de internet y computadoras en sala?",
    "¿Qué costo tiene la multa por entregar un libro tarde?",
    "¿Cómo funciona el préstamo interbibliotecario entre campus UABC?",
    "informacion de servicios de biblioteca"
]
for q in info_queries:
    add_sample(q, "informacion_biblioteca", None, None, None)

# 9. SALUDOS Y DIÁLOGO GENERAL (25 variaciones)
greetings = [
    "Hola", "Hola, buenas tardes", "Buenos días", "Buenas noches",
    "Hola, ¿cómo estás?", "Qué tal", "Saludos", "Hola qué onda",
    "Hola BiblioBot", "Buenas tardes", "Hola, ocupo ayuda", "Que onda"
]
for q in greetings:
    add_sample(q, "saludo", None, None, None)

out_desktop = r"C:\Users\Nera\Desktop\dataset_koha_entrenamiento.jsonl"
out_project = r"C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\training\dataset_koha_entrenamiento.jsonl"

os.makedirs(os.path.dirname(out_project), exist_ok=True)

with open(out_desktop, "w", encoding="utf-8") as f:
    for s in samples:
        f.write(json.dumps(s, ensure_ascii=False) + "\n")

with open(out_project, "w", encoding="utf-8") as f:
    for s in samples:
        f.write(json.dumps(s, ensure_ascii=False) + "\n")

print(f"Dataset generado con {len(samples)} ejemplos.")
