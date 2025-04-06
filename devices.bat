@echo off
setlocal EnableDelayedExpansion

set TOKENS_FILE=device_tokens.txt
set COMPOSE_FILE=devices.yml
set CONTAINER_NAME_PREFIX=virtual_device

:: Очистить файл перед генерацией
echo services: > %COMPOSE_FILE%

:: Счётчик устройств
set /a i=1

:: Генерация сервисов
for /f "usebackq delims=" %%T in ("%TOKENS_FILE%") do (
    set TOKEN=%%T
    if not "!TOKEN!"=="" (
        echo   %CONTAINER_NAME_PREFIX%_!i!: >> %COMPOSE_FILE%
        echo     build: >> %COMPOSE_FILE%
        echo       context: ./ >> %COMPOSE_FILE%
        echo     environment: >> %COMPOSE_FILE%
        echo       - TOKEN=!TOKEN! >> %COMPOSE_FILE%
        echo     restart: always >> %COMPOSE_FILE%
        echo     networks: >> %COMPOSE_FILE%
        echo       - compose_ws-network >> %COMPOSE_FILE%
        echo. >> %COMPOSE_FILE%
        set /a i+=1
    )
)

:: Добавляем секцию сетей (один раз)
(
    echo networks:
    echo   compose_ws-network:
    echo     external: true
    echo.
) >> %COMPOSE_FILE%

:: Команды
set CMD=%1
if "%CMD%"=="up" (
    docker-compose -f %COMPOSE_FILE% up -d
) else if "%CMD%"=="down" (
    docker-compose -f %COMPOSE_FILE% down
) else if "%CMD%"=="build" (
    docker-compose -f %COMPOSE_FILE% build
) else if "%CMD%"=="logs" (
    docker-compose -f %COMPOSE_FILE% logs -f --tail=100
) else if "%CMD%"=="restart" (
    set SERVICE=%2
    docker-compose -f %COMPOSE_FILE% restart %SERVICE%
) else (
    echo Usage: devices.bat ^<up^|down^|build^|logs^|restart service^>
)

endlocal
