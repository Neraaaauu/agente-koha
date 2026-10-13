# Script para generar Dataset Masivo Hiper-Enfocado (~550+ pares)
$systemPrompt = "Eres el asistente inteligente de la Biblioteca Central Campus Mexicali (UABC). Tu función es analizar la consulta del usuario en lenguaje natural y extraer la intención y parámetros de búsqueda para la API de KOHA en formato JSON."

$samples = [System.Collections.Generic.List[PSObject]]::new()

function Add-Entry {
    param(
        [string]$userQuery,
        [string]$intencion,
        [string]$materia = $null,
        [string]$autor = $null,
        [string]$kohaQuery = $null
    )
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
            [ordered]@{ role = "user"; content = $userQuery },
            [ordered]@{ role = "assistant"; content = $assistantJson }
        )
    }
    $samples.Add($entry)
}

# Plantillas de variaciones sintácticas
$searchTemplates = @(
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
    "literatura académica sobre {0}"
)

# 1. INTELIGENCIA ARTIFICIAL & APRENDIZAJE AUTOMATICO
$aiTopics = @(
    @("inteligencia artificial", "q=inteligencia+artificial"),
    @("deep learning", "q=deep+learning"),
    @("redes neuronales", "q=redes+neuronales"),
    @("machine learning", "q=machine+learning"),
    @("visión por computadora", "q=vision+computadora"),
    @("procesamiento de lenguaje natural", "q=nlp"),
    @("agentes inteligentes", "q=agentes+inteligentes"),
    @("algoritmos genéticos y heurísticas", "q=algoritmos+geneticos")
)
foreach ($t in $aiTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
# Específicos con autor
Add-Entry "libro de inteligencia artificial de russell y norvig" "buscar_libro" "inteligencia artificial" "Russell, Stuart; Norvig, Peter" "author=Russell&q=inteligencia+artificial"
Add-Entry "¿Tienen el Russell de inteligencia artificial disponible?" "consultar_disponibilidad" "inteligencia artificial" "Russell, Stuart; Norvig, Peter" "author=Russell&q=inteligencia+artificial"
Add-Entry "deep learning de ian goodfellow" "buscar_libro" "deep learning" "Goodfellow, Ian" "author=Goodfellow&q=deep+learning"
Add-Entry "ocupo el libro de deep learning de goodfellow y bengio" "buscar_libro" "deep learning" "Goodfellow, Ian; Bengio, Yoshua" "author=Goodfellow&q=deep+learning"

# 2. REDES DE COMPUTADORAS Y SEGURIDAD
$netTopics = @(
    @("redes de computadoras", "q=redes+computadoras"),
    @("protocolos TCP/IP", "q=tcp+ip"),
    @("seguridad informática y redes", "q=seguridad+redes"),
    @("telecomunicaciones y sistemas distribuidos", "q=telecomunicaciones")
)
foreach ($t in $netTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "redes de computadoras de andrew tanenbaum" "buscar_libro" "redes de computadoras" "Tanenbaum, Andrew S." "author=Tanenbaum&q=redes"
Add-Entry "¿Tienen el libro de Tanenbaum de redes en sala?" "consultar_disponibilidad" "redes de computadoras" "Tanenbaum, Andrew S." "author=Tanenbaum&q=redes"
Add-Entry "libros del autor andrew tanenbaum" "buscar_libro" $null "Tanenbaum, Andrew S." "author=Tanenbaum"
Add-Entry "tanenbaum y wetherall redes" "buscar_libro" "redes de computadoras" "Tanenbaum, Andrew S.; Wetherall, David J." "author=Tanenbaum&q=redes"

# 3. BASES DE DATOS Y SQL
$dbTopics = @(
    @("bases de datos", "q=bases+datos"),
    @("diseño de bases de datos relacionales", "q=bases+datos+relacionales"),
    @("normalización de bases de datos y tablas", "q=normalizacion+bases+datos"),
    @("lenguaje SQL y optimización de consultas", "q=sql+bases+datos"),
    @("bases de datos NoSQL", "q=nosql")
)
foreach ($t in $dbTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "fundamentos de sistemas de bases de datos de silberschatz" "buscar_libro" "bases de datos" "Silberschatz, Abraham" "author=Silberschatz&q=bases+datos"
Add-Entry "¿Está disponible el Silberschatz de bases de datos?" "consultar_disponibilidad" "bases de datos" "Silberschatz, Abraham" "author=Silberschatz&q=bases+datos"
Add-Entry "Estoy teniendo problemas de redundancia en tablas relacionales, ocupo normalizacion" "buscar_libro" "bases de datos" $null "q=bases+datos+normalizacion"

# 4. METODOLOGIA DE LA INVESTIGACION & TESIS
$methTopics = @(
    @("metodología de la investigación", "q=metodologia+investigacion"),
    @("investigación cuantitativa y cualitativa", "q=cuantitativa+cualitativa"),
    @("redacción de tesis y marco teórico", "q=tesis+marco+teorico"),
    @("diseño experimental e instrumentos de medición", "q=instrumentos+medicion")
)
foreach ($t in $methTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "metodología de la investigación de hernández sampieri" "buscar_libro" "metodología de la investigación" "Hernández Sampieri, Roberto" "author=Sampieri&q=metodologia"
Add-Entry "¿Tienen el Sampieri de metodología para préstamo a domicilio?" "consultar_disponibilidad" "metodología de la investigación" "Hernández Sampieri, Roberto" "author=Sampieri"
Add-Entry "ocupo redactar el marco metodologico de mi tesis de maestria" "buscar_libro" "metodología de la investigación" $null "q=marco+metodologico+tesis"
Add-Entry "libros para diseñar encuestas y entrevistas de posgrado" "buscar_libro" "metodología de la investigación" $null "q=encuestas+entrevistas"

# 5. GESTION DEL CONOCIMIENTO & MODELO SECI (NONAKA & TAKEUCHI)
$seciTopics = @(
    @("modelo SECI y creación del conocimiento", "q=seci+conocimiento"),
    @("gestión del conocimiento organizacional", "q=gestion+conocimiento"),
    @("aprendizaje organizacional y transferencia de saberes", "q=aprendizaje+organizacional")
)
foreach ($t in $seciTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "la creación del conocimiento en la organización de nonaka y takeuchi" "buscar_libro" "gestión del conocimiento" "Nonaka, Ikujiro; Takeuchi, Hirotaka" "author=Nonaka&q=conocimiento"
Add-Entry "¿Tienen el libro de Nonaka sobre la espiral del conocimiento SECI?" "consultar_disponibilidad" "modelo SECI" "Nonaka, Ikujiro" "author=Nonaka&q=seci"
Add-Entry "bibliografía sobre conocimiento tácito y explícito" "buscar_libro" "gestión del conocimiento" "Nonaka, Ikujiro" "author=Nonaka&q=conocimiento+tacito"

# 6. PROGRAMACION, C#, .NET, PYTHON & SOFTWARE
$progTopics = @(
    @("programación en C# y .NET", "q=csharp+dotnet"),
    @("desarrollo de APIs REST con ASP.NET Core", "q=aspnet+core+api"),
    @("python para análisis de datos", "q=python+datos"),
    @("programación orientada a objetos POO", "q=poo+programacion"),
    @("estructuras de datos y algoritmos", "q=estructuras+datos+algoritmos"),
    @("ingeniería de software y metodologías ágiles", "q=ingenieria+software")
)
foreach ($t in $progTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "python para análisis de datos de wes mckinney" "buscar_libro" "python" "McKinney, Wes" "author=McKinney&q=python+datos"
Add-Entry "desarrollo web con asp net core de paul deitel" "buscar_libro" "ASP.NET Core" "Deitel, Paul; Deitel, Harvey" "author=Deitel&q=aspnet+core"
Add-Entry "ingeniería de software enfoque práctico de roger pressman" "buscar_libro" "ingeniería de software" "Pressman, Roger S." "author=Pressman&q=ingenieria+software"

# 7. CIENCIAS BASICAS: MATEMATICAS, FISICA, QUIMICA
$scienceTopics = @(
    @("cálculo diferencial e integral", "q=calculo"),
    @("álgebra lineal", "q=algebra+lineal"),
    @("ecuaciones diferenciales", "q=ecuaciones+diferenciales"),
    @("probabilidad y estadística para ingenieros", "q=probabilidad+estadistica"),
    @("física universitaria y mecánica clásica", "q=fisica+mecanica"),
    @("química general y orgánica", "q=quimica+organica")
)
foreach ($t in $scienceTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "cálculo de james stewart trascendentes tempranas" "buscar_libro" "cálculo" "Stewart, James" "author=Stewart&q=calculo"
Add-Entry "álgebra lineal de stanley grossman" "buscar_libro" "álgebra lineal" "Grossman, Stanley" "author=Grossman&q=algebra+lineal"
Add-Entry "física universitaria de sears y zemansky" "buscar_libro" "física" "Sears, Francis; Zemansky, Mark" "author=Sears&q=fisica"

# 8. OTRAS FACULTADES Y DISCIPLINAS (ARTE, DERECHO, MEDICINA, HISTORIA, COCINA, ETC.)
$diverseTopics = @(
    @("arte moderno y contemporáneo", "q=arte+moderno"),
    @("historia del arte universal", "q=historia+arte"),
    @("arquitectura moderna y diseño urbano", "q=arquitectura"),
    @("cocina y gastronomía mexicana", "q=cocina+mexicana"),
    @("derecho constitucional mexicano", "q=derecho+constitucional"),
    @("derecho penal y juicios orales", "q=derecho+penal"),
    @("anatomía humana clínica", "q=anatomia+humana"),
    @("fisiología médica", "q=fisiologia+medica"),
    @("psicología clínica y neurociencias", "q=psicologia+clinica"),
    @("administración de empresas y finanzas", "q=administracion+finanzas"),
    @("filosofía y ética profesional", "q=filosofia+etica"),
    @("literatura y poesía mexicana", "q=literatura+mexicana"),
    @("historia de méxico y baja california", "q=historia+mexico")
)
foreach ($t in $diverseTopics) {
    foreach ($tmpl in $searchTemplates) {
        $q = $tmpl -f $t[0]
        Add-Entry $q "buscar_libro" $t[0] $null $t[1]
    }
}
Add-Entry "tienes libros sobre el arte moderno" "buscar_libro" "arte moderno" $null "q=arte+moderno"
Add-Entry "tienes libros sobre el arte moderno?" "buscar_libro" "arte moderno" $null "q=arte+moderno"
Add-Entry "tienes libros de cocina?" "buscar_libro" "cocina" $null "q=cocina"
Add-Entry "fisiología médica de guyton y hall" "buscar_libro" "fisiología médica" "Guyton, Arthur; Hall, John" "author=Guyton&q=fisiologia"

# 9. JERGA ESTUDIANTIL, MODISMOS Y ABREVIATURAS
$slangQueries = @(
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
    @("pasame un libro de bases de datos chido", "bases de datos", $null, "q=bases+datos")
)
foreach ($sq in $slangQueries) {
    Add-Entry $sq[0] "buscar_libro" $sq[1] $sq[2] $sq[3]
}

# 10. INFORMACION INSTITUCIONAL (HORARIOS, REGLAMENTO, SERVICIOS)
$infoQueries = @(
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
    "informacion general de servicios de biblioteca"
)
foreach ($iq in $infoQueries) {
    Add-Entry $iq "informacion_biblioteca" $null $null $null
}

# 11. SALUDOS Y DIALOGO DE CORTESIA
$greetQueries = @(
    "Hola",
    "Hola, buenas tardes",
    "Buenos días",
    "Buenas noches",
    "Hola, ¿cómo estás?",
    "Qué tal",
    "Saludos",
    "Hola qué onda",
    "Hola BiblioBot",
    "Buenas tardes, ocupo ayuda",
    "Hola, ¿me puedes orientar?",
    "Buenas tardes bibliobot"
)
foreach ($gq in $greetQueries) {
    Add-Entry $gq "saludo" $null $null $null
}

# Exportar a Desktop y Proyecto
$desktopFile = "C:\Users\Nera\Desktop\dataset_koha_entrenamiento.jsonl"
$projFile = "C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\training\dataset_koha_entrenamiento.jsonl"

$lines = $samples | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 4 }
[System.IO.File]::WriteAllLines($desktopFile, $lines, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllLines($projFile, $lines, [System.Text.Encoding]::UTF8)

Write-Host "============================================================"
Write-Host "  DATASET MASIVO GENERADO EXITOSAMENTE"
Write-Host "  Total de pares de entrenamiento: $($samples.Count)"
Write-Host "  Ruta Desktop: $desktopFile"
Write-Host "============================================================"
