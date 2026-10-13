# Generador de Dataset Gigante (2,500+ muestras para entrenamiento profundo de 1 hora)
$systemPrompt = "Eres el asistente inteligente de la Biblioteca Central Campus Mexicali (UABC). Tu función es analizar la consulta del usuario en lenguaje natural y extraer la intención y parámetros de búsqueda para la API de KOHA en formato JSON."

$samples = [System.Collections.Generic.List[PSObject]]::new()
$seenQueries = [System.Collections.Generic.HashSet[string]]::new()

function Add-Entry {
    param(
        [string]$userQuery,
        [string]$intencion,
        [string]$materia = $null,
        [string]$autor = $null,
        [string]$kohaQuery = $null
    )
    $cleanQ = $userQuery.Trim()
    if ([string]::IsNullOrWhiteSpace($cleanQ)) { return }
    if ($seenQueries.Contains($cleanQ.ToLowerInvariant())) { return }
    $seenQueries.Add($cleanQ.ToLowerInvariant()) | Out-Null

    $paramsDict = [ordered]@{
        materia = if ([string]::IsNullOrWhiteSpace($materia)) { $null } else { $materia }
        autor = if ([string]::IsNullOrWhiteSpace($autor)) { $null } else { $autor }
        koha_query = if ([string]::IsNullOrWhiteSpace($kohaQuery)) { $null } else { $kohaQuery }
    }
    $assistantJson = [ordered]@{
        intencion = $intencion
        parametros = $paramsDict
    } | ConvertTo-Json -Compress

    $entry = [ordered]@{
        messages = @(
            [ordered]@{ role = "system"; content = $systemPrompt },
            [ordered]@{ role = "user"; content = $cleanQ },
            [ordered]@{ role = "assistant"; content = $assistantJson }
        )
    }
    $samples.Add($entry)
}

# 1. PLANTILLAS DE PREGUNTAS (35 variaciones de redacción)
$templates = @(
    "¿Qué libros tienen sobre {0}?",
    "libros de {0}",
    "busco libros sobre {0}",
    "ocupo libros de {0} para mi clase",
    "¿Tendrán algo de {0}?",
    "tienes material de {0}?",
    "recomiéndame libros de {0}",
    "¿Hay libros disponibles de {0}?",
    "buenas tardes, busco bibliografía sobre {0}",
    "ocupo estudiar {0}, ¿qué tienen?",
    "¿Qué libros me recomiendan para aprender {0}?",
    "literatura académica sobre {0}",
    "¿Dónde encuentro los libros de {0}?",
    "ocupo referencias bibliográficas de {0}",
    "¿Me puedes buscar libros de {0}?",
    "estoy buscando material para mi materia de {0}",
    "¿Tienen algún ejemplar de {0} en sala?",
    "¿Puedo pedir prestado un libro de {0}?",
    "ocupo libros de {0} para hoy",
    "libros de texto universitarios de {0}",
    "bibliografía recomendada para {0}",
    "¿Cuáles son los mejores libros de {0} que tienen?",
    "buenas noches, ¿hay libros de {0}?",
    "hola, me urge encontrar libros de {0}",
    "busco títulos relacionados con {0}",
    "recomienda algo bueno de {0}",
    "¿Tienen libros de {0} en estantería abierta?",
    "material de apoyo para {0}",
    "¿Qué acervo tienen de {0}?",
    "libros de {0} para nivel licenciatura y posgrado",
    "¿Tienen libros actualizados de {0}?",
    "ocupo información y libros de {0}",
    "quiero consultar libros de {0}",
    "¿Hay algo nuevo de {0}?",
    "necesito libros de {0} para mi proyecto final"
)

# 2. CATÁLOGO EXTENSO DE MATERIAS (80 materias de todas las áreas)
$allSubjects = @(
    # Computación e IA
    @("inteligencia artificial", "q=inteligencia+artificial"),
    @("deep learning", "q=deep+learning"),
    @("redes neuronales", "q=redes+neuronales"),
    @("machine learning", "q=machine+learning"),
    @("visión por computadora", "q=vision+computadora"),
    @("procesamiento de lenguaje natural", "q=nlp"),
    @("agentes inteligentes", "q=agentes+inteligentes"),
    @("robótica y mecatrónica", "q=robotica"),
    @("sistemas expertos", "q=sistemas+expertos"),
    @("minería de datos y big data", "q=mineria+datos"),
    @("computación en la nube", "q=cloud+computing"),
    @("ciberseguridad y hacking ético", "q=ciberseguridad"),
    @("criptografía aplicada", "q=criptografia"),
    @("sistemas operativos", "q=sistemas+operativos"),
    @("compiladores y lenguajes de programación", "q=compiladores"),
    @("arquitectura de computadoras", "q=arquitectura+computadoras"),
    # Redes y Telecomunicaciones
    @("redes de computadoras", "q=redes+computadoras"),
    @("protocolos TCP/IP y enrutamiento", "q=tcp+ip"),
    @("telecomunicaciones y señales", "q=telecomunicaciones"),
    @("redes inalámbricas y sensores", "q=redes+inalambricas"),
    @("sistemas distribuidos", "q=sistemas+distribuidos"),
    # Bases de Datos
    @("bases de datos", "q=bases+datos"),
    @("diseño de bases de datos relacionales", "q=bases+datos+relacionales"),
    @("lenguaje SQL y optimización", "q=sql"),
    @("bases de datos NoSQL", "q=nosql"),
    @("almacenes de datos y data warehouse", "q=data+warehouse"),
    # Software y Programación
    @("ingeniería de software", "q=ingenieria+software"),
    @("metodologías ágiles y scrum", "q=agile+scrum"),
    @("patrones de diseño de software", "q=patrones+diseno"),
    @("pruebas de software y QA", "q=software+testing"),
    @("programación en C# y .NET", "q=csharp+dotnet"),
    @("ASP.NET Core y desarrollo web", "q=aspnet+core"),
    @("python para ciencia de datos", "q=python+datos"),
    @("programación orientada a objetos", "q=poo"),
    @("estructuras de datos y algoritmos", "q=estructuras+datos+algoritmos"),
    @("programación en Java", "q=java"),
    @("programación en C y C++", "q=cpp"),
    # Metodología y Posgrado
    @("metodología de la investigación", "q=metodologia+investigacion"),
    @("investigación cuantitativa", "q=investigacion+cuantitativa"),
    @("investigación cualitativa", "q=investigacion+cualitativa"),
    @("redacción de tesis y artículos científicos", "q=tesis+redaccion"),
    @("epistemología de la ciencia", "q=epistemologia"),
    @("diseño de experimentos y muestreo", "q=diseno+experimentos"),
    # Gestión del Conocimiento / SECI
    @("modelo SECI y espiral del conocimiento", "q=seci+conocimiento"),
    @("gestión del conocimiento organizacional", "q=gestion+conocimiento"),
    @("aprendizaje organizacional", "q=aprendizaje+organizacional"),
    @("innovación y transferencia tecnológica", "q=innovacion+tecnologica"),
    # Ciencias Básicas (Ingeniería)
    @("cálculo diferencial", "q=calculo+diferencial"),
    @("cálculo integral", "q=calculo+integral"),
    @("cálculo vectorial y multivariable", "q=calculo+vectorial"),
    @("álgebra lineal", "q=algebra+lineal"),
    @("ecuaciones diferenciales", "q=ecuaciones+diferenciales"),
    @("probabilidad y estadística", "q=probabilidad+estadistica"),
    @("física mecánica", "q=fisica+mecanica"),
    @("electromagnetismo y circuitos", "q=electromagnetismo"),
    @("termodinámica", "q=termodinamica"),
    @("química general", "q=quimica+general"),
    @("química orgánica", "q=quimica+organica"),
    # Otras Facultades y Humanidades
    @("arte moderno y contemporáneo", "q=arte+moderno"),
    @("historia del arte universal", "q=historia+arte"),
    @("arquitectura y diseño urbano", "q=arquitectura"),
    @("gastronomía y cocina mexicana", "q=gastronomia+cocina"),
    @("derecho constitucional", "q=derecho+constitucional"),
    @("derecho penal y juicios orales", "q=derecho+penal"),
    @("derecho laboral", "q=derecho+laboral"),
    @("anatomía humana clínica", "q=anatomia"),
    @("fisiología médica", "q=fisiologia"),
    @("farmacología", "q=farmacologia"),
    @("enfermería y primeros auxilios", "q=enfermeria"),
    @("psicología clínica y cognitiva", "q=psicologia"),
    @("contabilidad financiera y costos", "q=contabilidad"),
    @("administración de empresas", "q=administracion"),
    @("finanzas corporativas", "q=finanzas"),
    @("marketing digital y mercadotecnia", "q=marketing"),
    @("filosofía y ética", "q=filosofia+etica"),
    @("literatura y poesía mexicana", "q=literatura"),
    @("historia de méxico", "q=historia+mexico"),
    @("historia de baja california", "q=historia+baja+california")
)

# Generar combinaciones de Materia x Plantilla (~2,400 muestras)
foreach ($sub in $allSubjects) {
    foreach ($tmpl in $templates) {
        $qText = $tmpl -f $sub[0]
        Add-Entry $qText "buscar_libro" $sub[0] $null $sub[1]
    }
}

# 3. CONSULTAS CON AUTORES CLAVE Y ESPECÍFICOS (~150 muestras)
$authorBooks = @(
    @("Russell, Stuart; Norvig, Peter", "inteligencia artificial", "author=Russell&q=inteligencia+artificial", @("russell y norvig inteligencia artificial", "el libro de russell de ia", "inteligencia artificial enfoque moderno de russell", "¿Tienen el Russell Norvig?", "busco a stuart russell")),
    @("Goodfellow, Ian; Bengio, Yoshua", "deep learning", "author=Goodfellow&q=deep+learning", @("deep learning de ian goodfellow", "el libro de deep learning de goodfellow y bengio", "goodfellow redes neuronales", "ocupo a ian goodfellow")),
    @("Tanenbaum, Andrew S.", "redes de computadoras", "author=Tanenbaum&q=redes", @("redes de computadoras de andrew tanenbaum", "el tanenbaum de redes", "tanenbaum y wetherall redes", "¿Tienen el libro de Tanenbaum?", "ocupo a andrew s tanenbaum")),
    @("Silberschatz, Abraham", "bases de datos", "author=Silberschatz&q=bases+datos", @("fundamentos de bases de datos de silberschatz", "el silberschatz de bd", "abraham silberschatz bases de datos", "¿Tienen disponible el Silberschatz?")),
    @("Hernández Sampieri, Roberto", "metodología de la investigación", "author=Sampieri&q=metodologia", @("metodología de la investigación de hernández sampieri", "el sampieri para mi tesis", "sampieri y mendoza metodología", "ocupo el libro de roberto hernandez sampieri", "¿Tienen el Sampieri en sala?")),
    @("Nonaka, Ikujiro; Takeuchi, Hirotaka", "gestión del conocimiento", "author=Nonaka&q=conocimiento", @("la creación del conocimiento de nonaka y takeuchi", "el libro de nonaka del modelo seci", "ikujiro nonaka conocimiento tácito", "takeuchi y nonaka aprendizaje organizacional")),
    @("Pressman, Roger S.", "ingeniería de software", "author=Pressman&q=ingenieria+software", @("ingeniería de software de roger pressman", "el pressman de software", "roger pressman enfoque práctico")),
    @("McKinney, Wes", "python", "author=McKinney&q=python+datos", @("python para análisis de datos de wes mckinney", "wes mckinney pandas", "el libro del creador de pandas")),
    @("Deitel, Paul; Deitel, Harvey", "ASP.NET Core", "author=Deitel&q=aspnet+core", @("desarrollo web con asp net core de paul deitel", "los hermanos deitel c#", "deitel y deitel servicios web")),
    @("Stewart, James", "cálculo", "author=Stewart&q=calculo", @("cálculo trascendentes tempranas de james stewart", "el stewart de cálculo", "cálculo multivariable de stewart")),
    @("Grossman, Stanley", "álgebra lineal", "author=Grossman&q=algebra+lineal", @("álgebra lineal de stanley grossman", "el grossman de álgebra lineal")),
    @("Sears, Francis; Zemansky, Mark", "física", "author=Sears&q=fisica", @("física universitaria de sears y zemansky", "el sears zemansky física volumen 1")),
    @("Guyton, Arthur; Hall, John", "fisiología médica", "author=Guyton&q=fisiologia", @("tratado de fisiología médica de guyton y hall", "el guyton de fisiología")),
    @("Wade, L. G.", "química orgánica", "author=Wade&q=quimica+organica", @("química orgánica de wade volumen 1", "el wade de química"))
)

foreach ($ab in $authorBooks) {
    $autName = $ab[0]
    $matName = $ab[1]
    $kqBase = $ab[2]
    $phrases = $ab[3]
    foreach ($p in $phrases) {
        Add-Entry $p "buscar_libro" $matName $autName $kqBase
        Add-Entry "¿Tienen disponible '$p'?" "consultar_disponibilidad" $matName $autName $kqBase
    }
}

# 4. JERGA ESTUDIANTIL, MODISMOS Y ABREVIATURAS MEXICANAS (~150 muestras)
$slangForms = @(
    @("¿Qué onda pa, tienes libros de IA?", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("oye carnal hay libros de IA?", "inteligencia artificial", $null, "q=inteligencia+artificial"),
    @("que onda pa, ocupo libros de BD", "bases de datos", $null, "q=bases+datos"),
    @("tienes algo de redes o poo?", "programación orientada a objetos", $null, "q=poo"),
    @("tírame paro con la tesis del profe tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("nmms ando atrasado con redes de tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("ocupo el sampieri en caliente", "metodología de la investigación", "Hernández Sampieri, Roberto", "author=Sampieri"),
    @("compa, tienen libros de progra en c#?", "C# .NET", $null, "q=csharp"),
    @("que onda we, tienes libros de SO?", "sistemas operativos", $null, "q=sistemas+operativos"),
    @("ando buscando algo de algos y grafos", "estructuras de datos", $null, "q=algoritmos+grafos"),
    @("el libro de redes del viejito tanenbaum", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("ocupo el stewart de cálculo pa hoy", "cálculo", "Stewart, James", "author=Stewart&q=calculo"),
    @("¿tienen libros de IA generativa y transformers?", "inteligencia artificial", $null, "q=transformers+ia"),
    @("pasame un libro de bases de datos chido", "bases de datos", $null, "q=bases+datos"),
    @("oye bro, ocupo el libro de pressman para ingenieria de software", "ingeniería de software", "Pressman, Roger S.", "author=Pressman"),
    @("tienen la biblia de tanenbaum para redes?", "redes de computadoras", "Tanenbaum, Andrew S.", "author=Tanenbaum&q=redes"),
    @("ocupo el libro de python para machine learning para antes de las 3", "python", $null, "q=python+machine+learning"),
    @("profe me encargo buscar libros del modelo seci", "modelo SECI", "Nonaka, Ikujiro", "author=Nonaka&q=seci"),
    @("ando bien perdido con el marco teorico, que libro me sirve?", "metodología de la investigación", $null, "q=marco+teorico"),
    @("tienen algo de deep learning o redes neuronales para hoy?", "deep learning", $null, "q=deep+learning"),
    @("carnal me prestas el sampieri?", "metodología de la investigación", "Hernández Sampieri, Roberto", "author=Sampieri"),
    @("que onda compa, hay libros de calculo diferencial disponibles?", "cálculo diferencial", $null, "q=calculo+diferencial"),
    @("ocupo un libro perrón de ciberseguridad", "ciberseguridad", $null, "q=ciberseguridad"),
    @("oye pa, tienes libros de cocina?", "cocina", $null, "q=cocina"),
    @("tienes libros sobre el arte moderno?", "arte moderno", $null, "q=arte+moderno"),
    @("tienes libros sobre el arte moderno", "arte moderno", $null, "q=arte+moderno"),
    @("ando buscando libros de derecho constitucional", "derecho constitucional", $null, "q=derecho+constitucional"),
    @("ocupo el guyton de medicina", "fisiología médica", "Guyton, Arthur", "author=Guyton"),
    @("tienen libros de física universitaria?", "física", $null, "q=fisica+universitaria"),
    @("profe me pidió buscar libros de arquitectura limpia", "ingeniería de software", $null, "q=arquitectura+limpia")
)
foreach ($sf in $slangForms) {
    Add-Entry $sf[0] "buscar_libro" $sf[1] $sf[2] $sf[3]
}

# 5. INFORMACIÓN INSTITUCIONAL DE LA BIBLIOTECA (~80 muestras)
$infoVariants = @(
    "¿Cuál es el horario de la Biblioteca Central?",
    "oye carnal a que hora cierran la biblioteca hoy?",
    "¿A qué hora abren y a qué hora cierran?",
    "horarios de atencion de biblioteca central mexicali",
    "¿Abren los sabados la biblioteca?",
    "¿A qué hora abren el fin de semana?",
    "¿Dónde está ubicada la biblioteca central en campus mexicali?",
    "¿Cómo puedo tramitar mi credencial de biblioteca?",
    "¿Cuáles son los requisitos para préstamo a domicilio?",
    "¿Cuántos libros puedo pedir prestados con mi credencial?",
    "¿Por cuántos días me prestan un libro de sala?",
    "¿Cómo puedo renovar el préstamo de mis libros?",
    "¿Cómo puedo apartar un cubículo de estudio grupal?",
    "¿Tienen servicio de internet wifi y computadoras en sala?",
    "¿Qué costo tiene la multa por entregar un libro después de la fecha?",
    "¿Cómo funciona el préstamo interbibliotecario entre campus UABC?",
    "¿Puedo llevar libros de biblioteca central a campus tijuana?",
    "¿Tienen servicio de fotocopiado e impresión?",
    "¿Tienen área de silencio para posgrado?",
    "¿Puedo entrar a la biblioteca con mochila y alimentos?",
    "¿Dónde pago las multas de biblioteca?",
    "reglamento general de la biblioteca central uabc",
    "servicios disponibles en biblioteca central mexicali",
    "¿Tienen computadoras con acceso a bases de datos científicas?",
    "¿Cómo entro al repositorio digital de tesis de la uabc?",
    "¿Puedo solicitar préstamos si soy egresado de uabc?",
    "¿Qué días no abre la biblioteca por días festivos?",
    "contacto y teléfono de la biblioteca central mexicali"
)
foreach ($iv in $infoVariants) {
    Add-Entry $iv "informacion_biblioteca" $null $null $null
    Add-Entry "Disculpa, $iv" "informacion_biblioteca" $null $null $null
    Add-Entry "Hola buenas tardes, $iv" "informacion_biblioteca" $null $null $null
}

# 6. SALUDOS, CORTESÍA Y DIÁLOGOS DE ENTRADA (~50 muestras)
$greetList = @(
    "Hola",
    "Hola, buenas tardes",
    "Buenos días",
    "Buenas noches",
    "Hola, ¿cómo estás?",
    "Qué tal",
    "Saludos cordiales",
    "Hola qué onda",
    "Hola BiblioBot",
    "Buenas tardes, ocupo ayuda",
    "Hola, ¿me puedes orientar con una búsqueda?",
    "Buenas tardes bibliobot cimarrón",
    "Hola, buen día",
    "Hola asistente de biblioteca",
    "Hola, ¿hay alguien ahí?",
    "Muchas gracias por la información",
    "Gracias, que tengas buen día",
    "Excelente servicio, gracias"
)
foreach ($gl in $greetList) {
    Add-Entry $gl "saludo" $null $null $null
}

# 7. EXPORTAR DATASET A DESKTOP Y PROYECTO
$desktopPath = "C:\Users\Nera\Desktop\dataset_koha_entrenamiento.jsonl"
$projPath = "C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\training\dataset_koha_entrenamiento.jsonl"

$lines = $samples | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 4 }
[System.IO.File]::WriteAllLines($desktopPath, $lines, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllLines($projPath, $lines, [System.Text.Encoding]::UTF8)

Write-Host "=================================================================="
Write-Host "  DATASET GIGANTE GENERADO EXITOSAMENTE"
Write-Host "  Muestras totales únicas: $($samples.Count)"
Write-Host "  Ruta Desktop: $desktopPath"
Write-Host "=================================================================="
