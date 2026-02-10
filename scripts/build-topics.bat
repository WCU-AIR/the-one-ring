@echo off
setlocal
REM Build topic images with the Spack mirror mounted so spack install fetches sources from it.
REM Run from repo root (or from scripts/). Requires: base and spack-mirror built, mirror populated.
REM Usage: scripts\build-topics.bat [SERVICE]
REM   If SERVICE is given, build only that topic (e.g. system-programming).
REM   If no argument, build all topic services.

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."
cd /d "%REPO_ROOT%"

if not defined MIRROR set "MIRROR=docker/spack-mirror-cache"
if not defined COMPOSE_FILE set "COMPOSE_FILE=docker-compose.yml"

set "ALL_TOPICS=system-programming parallel-computing big-data machine-learning embedded-system"

if "%~1"=="" (
  set "TOPICS=%ALL_TOPICS%"
) else (
  set "topic=%~1"
  set "VALID="
  for %%v in (%ALL_TOPICS%) do if "%%v"=="%topic%" set "VALID=1"
  if not defined VALID (
    echo Unknown topic: %topic%. Valid: %ALL_TOPICS%
    exit /b 1
  )
  set "TOPICS=%topic%"
)

set "MIRROR_ABS=%CD%\%MIRROR%"
set "DOCKER_BUILDKIT=1"
for %%t in (%TOPICS%) do (
  echo Building %%t with mirror mount %MIRROR% ...
  docker build -f "docker/%%t/Dockerfile" --mount=type=bind,source="%MIRROR_ABS%",target=/opt/spack-mirror -t "linhbngo/onering-amd64:%%t" docker/
  if errorlevel 1 exit /b 1
)

echo Done. Start with: docker compose up -d ide system-programming ...
endlocal
