@echo off
title Agente Inteligente Biblioteca Central UABC (Koha API)
echo =======================================================
echo    AGENTE INTELIGENTE BIBLIOTECA CENTRAL MEXICALI
echo    UABC - FCITEC / Maestria en Tecnologias
echo =======================================================
echo.
echo [1] Abriendo Diapositivas de Presentacion en:
echo     http://localhost:5000/presentacion.html
echo.
echo [2] Abriendo Chatbot del Agente en:
echo     http://localhost:5000
echo.
echo [3] Archivo PowerPoint listo para Google Slides en:
echo     Presentacion_Primer_Avance_Agente_Koha_UABC.pptx
echo.

start "" "http://localhost:5000/presentacion.html"
start "" "http://localhost:5000"
dotnet run --project "C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\koha_agent_mvp.csproj"

pause
