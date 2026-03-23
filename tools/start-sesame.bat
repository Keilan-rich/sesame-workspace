@echo off
title Sesame Server
echo Demarrage du serveur Sesame...
cd /d "%~dp0.."
python tools/sesame-server.py
pause
