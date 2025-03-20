@echo off
setlocal enabledelayedexpansion

:: Configuração de cores
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RESET=[0m"

:: Função para mostrar ajuda
:show_help
    if "%~1"=="-h" goto :display_help
    if "%~1"=="--help" goto :display_help
    goto :continue_script

:display_help
    echo Usage: %~nx0 [OPTIONS]
    echo Builds and deploys a Docker infrastructure for Selenium tests.
    echo Options:
    echo   -h, --help      Display this help message.
    echo   -s, --skip-net  Skip network creation if it already exists.
    echo.
    exit /b 0

:continue_script
    :: Verificar se Docker está instalado
    where docker >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo %RED%ERROR: Docker not found.%RESET%
        exit /b 1
    )

    :: Verificar se Docker Compose está instalado
    docker compose version >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo %RED%ERROR: Docker Compose not found.%RESET%
        exit /b 1
    )

    :: Verificar parâmetros
    set "SKIP_NETWORK=0"
    if "%~1"=="-s" set "SKIP_NETWORK=1"
    if "%~1"=="--skip-net" set "SKIP_NETWORK=1"

    echo %YELLOW%Preparing build...%RESET%
    :: Obtenha o diretório atual do script e volte um nível
    pushd "%~dp0"
    cd ..

    if "%SKIP_NETWORK%"=="0" (
        echo %YELLOW%Creating required network...%RESET%
        docker network create selenoid 2>nul
    )

    echo %YELLOW%Downloading required webdrivers...%RESET%
    docker pull selenoid/chrome:latest
    docker pull selenoid/firefox:latest
    docker pull selenoid/video-recorder:latest-release

    echo %YELLOW%Starting infrastructure via docker-compose...%RESET%
    docker compose up -d --force-recreate --build --remove-orphans
    if %ERRORLEVEL% neq 0 (
        echo %RED%ERROR: Failed to start infrastructure.%RESET%
        exit /b 1
    )

    echo %GREEN%Build successful.%RESET%
    
    :: Volte para o diretório original
    popd
    exit /b 0
