@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: ============================
:: CONFIGURACOES PADRAO
:: ============================
SET LOG_DIR=C:\Logs
SET LOG_FILE=%LOG_DIR%\restart-service_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%.log
SET WAIT_TIME=5

:: ============================
:: VALIDACOES INICIAIS
:: ============================
IF "%~1"=="" (
    ECHO Uso correto:
    ECHO restart-service.bat SERVIDOR1[,SERVIDOR2] "Nome do Servico"
    EXIT /B 1
)

IF "%~2"=="" (
    ECHO ERRO: Nome do servico nao informado.
    EXIT /B 1
)

:: ============================
:: PREPARA LOG
:: ============================
IF NOT EXIST "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

ECHO =============================== >> "%LOG_FILE%"
ECHO Execucao iniciada em %DATE% %TIME% >> "%LOG_FILE%"
ECHO Servidores: %~1 >> "%LOG_FILE%"
ECHO Servico: %~2 >> "%LOG_FILE%"
ECHO =============================== >> "%LOG_FILE%"

:: ============================
:: VARIAVEIS
:: ============================
SET SERVIDORES=%~1
SET SERVICO=%~2

:: ============================
:: LOOP DE SERVIDORES
:: ============================
FOR %%S IN (%SERVIDORES:,= %) DO (

    ECHO.
    ECHO [%%S] Verificando servico "%SERVICO%"
    ECHO [%%S] Verificando servico "%SERVICO%" >> "%LOG_FILE%"

    FOR /F "tokens=3" %%A IN (
        'sc \\%%S query "%SERVICO%" ^| find "STATE"'
    ) DO SET STATE=%%A

    IF "!STATE!"=="RUNNING" (

        ECHO [%%S] Servico em execucao. Reiniciando...
        ECHO [%%S] Servico em execucao. Reiniciando... >> "%LOG_FILE%"

        sc \\%%S stop "%SERVICO%" >> "%LOG_FILE%" 2>&1
        timeout /t %WAIT_TIME% > NUL

        CALL :WAIT_FOR_STATE %%S "%SERVICO%" STOPPED

        sc \\%%S start "%SERVICO%" >> "%LOG_FILE%" 2>&1
        timeout /t %WAIT_TIME% > NUL

        CALL :WAIT_FOR_STATE %%S "%SERVICO%" RUNNING

        ECHO [%%S] Servico reiniciado com sucesso!
        ECHO [%%S] Servico reiniciado com sucesso! >> "%LOG_FILE%"

    ) ELSE (

        ECHO [%%S] Servico nao esta em execucao. Estado atual: !STATE!
        ECHO [%%S] Servico nao esta em execucao. Estado atual: !STATE! >> "%LOG_FILE%"

    )
)

ECHO.
ECHO Execucao finalizada.
ECHO Execucao finalizada em %DATE% %TIME% >> "%LOG_FILE%"
EXIT /B 0

:: ============================
:: FUNCAO: AGUARDA ESTADO
:: ============================
:WAIT_FOR_STATE
SET SERVER=%1
SET SERVICE=%2
SET EXPECTED=%3

:CHECK_STATE
FOR /F "tokens=3" %%A IN (
    'sc \\%SERVER% query "%SERVICE%" ^| find "STATE"'
) DO SET CURRENT=%%A

IF NOT "%CURRENT%"=="%EXPECTED%" (
    timeout /t 2 > NUL
    GOTO CHECK_STATE
)

EXIT /B
