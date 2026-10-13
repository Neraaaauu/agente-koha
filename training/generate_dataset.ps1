$systemPrompt = "Eres el asistente inteligente de la Biblioteca Central Campus Mexicali (UABC). Tu función es analizar la consulta del usuario en lenguaje natural y extraer la intención y parámetros de búsqueda para la API de KOHA en formato JSON."

$samples = [System.Collections.Generic.List[PSObject]]::new()

function Add-Sample {
    param($userMsg, $intencion, $materia, $autor, $kohaQuery)
    $paramsObj = [ordered]@{
        materia = $materia
        autor = $autor
        koha_query = $kohaQuery
    }
    $assistantContent = [ordered]@{
        intencion = $intencion
        parametros = $paramsObj
    } | ConvertTo-Json -Compress

    $sampleObj = [ordered]@{
        messages = @(
            [ordered]@{ role = "system"; content = $systemPrompt },
            [ordered]@{ role = "user"; content = $userMsg },
            [ordered]@{ role = "assistant"; content = $assistantContent }
        )
    }
    $samples.Add($sampleObj)
}

# 1. INTELIGENCIA ARTIFICIAL
$aiData = @(
    @("¿Qué libros tienen sobre Inteligencia Artificial?", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("libros de inteligencia artificial", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("ocupo libros de IA", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("¿Qué onda pa, tienes libros de IA?", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("oye carnal hay algo de IA en la biblioteca?", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("tienes libros sobre inteligencia artificial moderna?", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("buenas tardes, busco bibliografia de inteligencia artificial", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("tendran el libro de inteligencia artificial de russell y norvig?", "inteligencia artificial", "Russell, Stuart; Norvig, Peter", "author=Russell&q=inteligencia+artificial"),
    @("el libro de russell de ia", "inteligencia artificial", "Russell, Stuart", "author=Russell&q=ia"),
    @("russell norvig inteligencia artificial", "inteligencia artificial", "Russell, Stuart; Norvig, Peter", "author=Russell&q=inteligencia+artificial"),
    @("libros de deep learning y redes neuronales", "deep learning", $null, "q=deep+learning"),
    @("deep learning de ian goodfellow", "deep learning", "Goodfellow, Ian", "author=Goodfellow&q=deep+learning"),
    @("ocupo el libro de redes neuronales de goodfellow", "redes neuronales", "Goodfellow, Ian", "author=Goodfellow&q=redes+neuronales"),
    @("material para estudiar machine learning y aprendizaje automatico", "machine learning", $null, "q=machine+learning"),
    @("libros de machine learning en español", "machine learning", $null, "q=machine+learning"),
    @("vision por computadora y procesamiento de imagenes", "vision por computadora", $null, "q=vision+computadora"),
    @("procesamiento de lenguaje natural y nlp", "procesamiento de lenguaje natural", $null, "q=nlp"),
    @("modelos generativos y transformers en inteligencia artificial", "inteligencia artificial", $null, "q=transformers+inteligencia+artificial"),
    @("agentes inteligentes y sistemas multiagente", "agentes inteligentes", $null, "q=agentes+inteligentes"),
    @("busco libros sobre agentes inteligentes", "agentes inteligentes", $null, "q=agentes+inteligentes"),
    @("algoritmos heuristicos y busqueda en ia", "inteligencia artificial", $null, "q=heuristica+inteligencia+artificial"),
    @("aprendizaje por refuerzo y algoritmos q-learning", "aprendizaje por refuerzo", $null, "q=reinforcement+learning"),
    @("inteligencia artificial un enfoque moderno", "inteligencia artificial", "Russell, Stuart; Norvig, Peter", "author=Russell&q=inteligencia+artificial"),
    @("ocupo para mi clase libros de ia avanzada", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("oye tendras libros de robots e inteligencia artificial", "robotica e inteligencia artificial", $null, "q=robotica+inteligencia+artificial"),
    @("quiero aprender a programar redes neuronales profundas", "redes neuronales", $null, "q=redes+neuronales"),
    @("libros de tensorflow y pytorch para deep learning", "deep learning", $null, "q=deep+learning"),
    @("busco literatura cientifica sobre IA para ingenieria", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("que tienen de ia?", "inteligencia artificial", $null, "q=inteligencia+artificial")
)
foreach ($item in $aiData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 2. REDES DE COMPUTADORAS
$netData = @(
    @("Libros de redes de computadoras", "redes de computadoras", $null, "q=redes+computadoras"),
    @("ocupo el libro de redes de tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("¿Tienen disponible el libro de Tanenbaum de redes?", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("nmms ando bien atrasado con la tesis de redes del viejito tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("oye pa, tienes libros de redes?", "redes de computadoras", $null, "q=redes"),
    @("material sobre protocolos TCP/IP y modelo OSI", "redes de computadoras", $null, "q=tcp+ip+osi"),
    @("arquitectura de redes y telecomunicaciones", "redes de computadoras", $null, "q=arquitectura+redes"),
    @("seguridad en redes informaticas y criptografia", "seguridad en redes", $null, "q=seguridad+redes"),
    @("redes inalambricas y protocolos de comunicacion", "redes de computadoras", $null, "q=redes+inalambricas"),
    @("tanenbaum redes de computadoras", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("busco libros del autor andrew tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum"),
    @("redes de computadoras andrew s tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("libros de enrutamiento y conmutacion en redes cisco", "redes de computadoras", $null, "q=enrutamiento+redes"),
    @("sistemas distribuidos y redes", "redes de computadoras", $null, "q=sistemas+distribuidos"),
    @("que libros tienen de redes?", "redes de computadoras", $null, "q=redes"),
    @("ocupo para examen libros de redes tcp ip", "redes de computadoras", $null, "q=redes+tcp+ip")
)
foreach ($item in $netData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 3. BASES DE DATOS
$dbData = @(
    @("libros de bases de datos", "bases de datos", $null, "q=bases+datos"),
    @("ocupo libros de BD para mi materia", "bases de datos", $null, "q=bases+datos"),
    @("¿Qué onda pa, tienes libros de BD?", "bases de datos", $null, "q=bases+datos"),
    @("Fundamentos de sistemas de bases de datos de Silberschatz", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz&q=bases+datos"),
    @("silberschatz bases de datos", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz&q=bases+datos"),
    @("Estoy teniendo problemas de redundancia en tablas relacionales, ocupo normalizacion", "bases de datos", $null, "q=bases+datos+normalizacion"),
    @("diseño de modelos entidad relacion y normalizacion de bases de datos", "bases de datos", $null, "q=modelo+entidad+relacion"),
    @("libros de SQL y consultas avanzadas", "bases de datos", $null, "q=sql+bases+datos"),
    @("bases de datos NoSQL y sistemas distribuidos", "bases de datos", $null, "q=nosql+bases+datos"),
    @("administracion de bases de datos y transacciones ACID", "bases de datos", $null, "q=transacciones+bases+datos"),
    @("libros de Abraham Silberschatz sobre bases de datos", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz"),
    @("ocupo el silberschatz", "bases de datos", "Silberschatz, Abraham", "author=Silberschatz"),
    @("que libros tienen de bases de datos relacionales?", "bases de datos", $null, "q=bases+datos+relacionales"),
    @("optimizacion de consultas sql e indexacion", "bases de datos", $null, "q=sql+optimizacion")
)
foreach ($item in $dbData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 4. METODOLOGIA DE LA INVESTIGACION / TESIS
$methData = @(
    @("libros de metodologia de la investigacion", "metodologia de la investigacion", $null, "q=metodologia+investigacion"),
    @("Metodología de la investigación de Hernández Sampieri", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Hernandez+Sampieri&q=metodologia"),
    @("ocupo el sampieri para mi tesis", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Sampieri"),
    @("libros para redactar el marco teorico y muestreo cuantitativo", "metodologia de la investigacion", $null, "q=marco+teorico+muestreo"),
    @("como hacer una tesis de maestria", "metodologia de la investigacion", $null, "q=tesis+investigacion"),
    @("investigacion cuantitativa, cualitativa y mixta", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Sampieri&q=cuantitativa+cualitativa"),
    @("diseño metodologico e instrumentos de recoleccion de datos", "metodologia de la investigacion", $null, "q=instrumentos+recoleccion"),
    @("epistemologia y planteamiento del problema de investigacion", "metodologia de la investigacion", $null, "q=planteamiento+problema"),
    @("hernandez sampieri metodologia", "metodologia de la investigacion", "Hernández Sampieri, Roberto", "author=Sampieri"),
    @("libros para diseñar encuestas y entrevistas de investigacion", "metodologia de la investigacion", $null, "q=encuestas+entrevistas"),
    @("analisis estadistico para proyectos de posgrado", "metodologia de la investigacion", $null, "q=estadistica+investigacion"),
    @("guia de redaccion de tesis en formato apa", "metodologia de la investigacion", $null, "q=redaccion+tesis+apa")
)
foreach ($item in $methData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 5. GESTION DEL CONOCIMIENTO / MODELO SECI (NONAKA & TAKEUCHI)
$seciData = @(
    @("libros del modelo SECI y gestion del conocimiento", "modelo SECI", "Nonaka, Ikujiro; Takeuchi, Hirotaka", "author=Nonaka&q=seci"),
    @("La creacion del conocimiento en la organizacion de Nonaka", "creacion del conocimiento", "Nonaka, Ikujiro; Takeuchi, Hirotaka", "author=Nonaka&q=conocimiento"),
    @("ocupo bibliografia sobre socializacion y exteriorizacion del conocimiento", "modelo SECI", "Nonaka, Ikujiro", "author=Nonaka&q=conocimiento+tacito"),
    @("conocimiento tacito y conocimiento explicito en organizaciones", "gestion del conocimiento", "Nonaka, Ikujiro", "author=Nonaka&q=conocimiento+tacito"),
    @("aprendizaje organizacional y transferencia de conocimiento", "aprendizaje organizacional", $null, "q=aprendizaje+organizacional"),
    @("libros de Ikujiro Nonaka y Hirotaka Takeuchi", "gestion del conocimiento", "Nonaka, Ikujiro; Takeuchi, Hirotaka", "author=Nonaka"),
    @("espiral del conocimiento en empresas y equipos", "modelo SECI", "Nonaka, Ikujiro", "author=Nonaka&q=espiral+conocimiento"),
    @("teoria de innovacion basada en conocimiento", "gestion del conocimiento", $null, "q=innovacion+conocimiento")
)
foreach ($item in $seciData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 6. PROGRAMACION, C#, .NET, PYTHON
$progData = @(
    @("libros de python para analisis de datos", "python", "McKinney, Wes", "author=McKinney&q=python+datos"),
    @("python para machine learning de wes mckinney", "python", "McKinney, Wes", "author=McKinney&q=python+datos"),
    @("wes mckinney pandas python", "python", "McKinney, Wes", "author=McKinney&q=pandas"),
    @("libros de programacion en C# y .NET", "C# .NET", $null, "q=csharp+dotnet"),
    @("desarrollo de servicios web con ASP.NET Core", "ASP.NET Core", "Deitel, Paul; Deitel, Harvey", "author=Deitel&q=aspnet+core"),
    @("libros de microservicios y APIs REST en c#", "ASP.NET Core", $null, "q=microservicios+rest+csharp"),
    @("programacion orientada a objetos POO", "programacion orientada a objetos", $null, "q=poo+programacion"),
    @("¿tienen algo de redes o poo?", "programacion orientada a objetos", $null, "q=poo"),
    @("libros de estructura de datos y algoritmos", "estructuras de datos", $null, "q=estructuras+datos+algoritmos"),
    @("arquitectura de software limpia y patrones de diseño", "ingenieria de software", $null, "q=patrones+diseno+software"),
    @("ingenieria de software de roger pressman", "ingenieria de software", "Pressman, Roger S.", "author=Pressman&q=ingenieria+software")
)
foreach ($item in $progData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 7. MATERIAS DIVERSAS / ARTE / HISTORIA / COCINA / OTRAS CIENCIAS
$otherData = @(
    @("tienes libros sobre el arte moderno", "arte moderno", $null, "q=arte+moderno"),
    @("tienes libros sobre el arte moderno?", "arte moderno", $null, "q=arte+moderno"),
    @("busco libros de historia del arte universal", "historia del arte", $null, "q=historia+arte"),
    @("¿tienen libros de arquitectura moderna?", "arquitectura", $null, "q=arquitectura+moderna"),
    @("libros de pintura y escultura mexicana", "arte mexicano", $null, "q=arte+mexicano"),
    @("tienes libros de cocina?", "cocina", $null, "q=cocina"),
    @("libros de gastronomia y cocina internacional", "gastronomia", $null, "q=gastronomia"),
    @("derecho constitucional mexicano", "derecho constitucional", $null, "q=derecho+constitucional"),
    @("libros de derecho penal y juicios orales", "derecho penal", $null, "q=derecho+penal"),
    @("libros de anatomia humana para medicina", "anatomia", $null, "q=anatomia+humana"),
    @("fisiologia medica de Guyton", "fisiologia medica", "Guyton, Arthur", "author=Guyton&q=fisiologia"),
    @("calculo diferencial e integral de stewart", "calculo", "Stewart, James", "author=Stewart&q=calculo"),
    @("algebra lineal de grossman", "algebra lineal", "Grossman, Stanley", "author=Grossman&q=algebra+lineal"),
    @("fisica universitaria de sears y zemansky", "fisica", "Sears, Francis; Zemansky, Mark", "author=Sears&q=fisica"),
    @("quimica organica de wade", "quimica organica", "Wade, L. G.", "author=Wade&q=quimica+organica"),
    @("libros de administracion y contabilidad financiera", "contabilidad", $null, "q=contabilidad+financiera"),
    @("psicologia clinica y terapia cognitiva", "psicologia", $null, "q=psicologia+clinica"),
    @("filosofia moderna y etica profesional", "filosofia", $null, "q=filosofia+etica"),
    @("historia de baja california y mexico", "historia", $null, "q=historia+mexico"),
    @("literatura y poesia mexicana", "literatura", $null, "q=literatura+mexicana")
)
foreach ($item in $otherData) { Add-Sample $item[0] "buscar_libro" $item[1] $item[2] $item[3] }

# 8. INFORMACION INSTITUCIONAL
$infoData = @(
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
)
foreach ($item in $infoData) { Add-Sample $item "informacion_biblioteca" $null $null $null }

# 9. SALUDOS
$greetData = @(
    "Hola", "Hola, buenas tardes", "Buenos días", "Buenas noches",
    "Hola, ¿cómo estás?", "Qué tal", "Saludos", "Hola qué onda",
    "Hola BiblioBot", "Buenas tardes", "Hola, ocupo ayuda", "Que onda"
)
foreach ($item in $greetData) { Add-Sample $item "saludo" $null $null $null }

# Write JSONL
$desktopPath = "C:\Users\Nera\Desktop\dataset_koha_entrenamiento.jsonl"
$projPath = "C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\training\dataset_koha_entrenamiento.jsonl"

$lines = $samples | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 4 }
[System.IO.File]::WriteAllLines($desktopPath, $lines, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllLines($projPath, $lines, [System.Text.Encoding]::UTF8)

Write-Host "¡Dataset generado con $($samples.Count) ejemplos en $desktopPath!"
