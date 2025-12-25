@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: ============================
:: CONFIGURACOES
:: ============================
SET LOG_DIR=C:\Logs
SET WAIT_TIME=5
SET MAX_WAIT=60
SET DRY_RUN=0
SET EVENT_SOURCE=ServiceRestartScript

:: ============================
:: VALIDA ADMIN
:: ============================
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERRO: Execute como Administrador.
    EXIT /B 10
)

:: ============================
:: PARAMETROS
:: ============================
IF "%~1"=="" GOTO MENU
IF "%~2"=="" (
    ECHO Uso:
    ECHO restart-service-enterprise.bat SERVIDORES "Servico" [/dryrun]
    EXIT /B 1
)

IF /I "%~3"=="/dryrun" SET DRY_RUN=1

SET SERVIDORES=%~1
SET SERVICO=%~2

:: ============================
:: PREPARA LOG
:: ============================
IF NOT EXIST "%LOG_DIR%" mkdir "%LOG_DIR%"

SET LOG_FILE=%LOG_DIR%\restart_%SERVICO%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%.log

CALL :LOG "Inicio da execucao"
CALL :LOG "Servidores: %SERVIDORES%"
CALL :LOG "Servico: %SERVICO%"
CALL :LOG "DryRun: %DRY_RUN%"

:: ============================
:: LOOP DE SERVIDORES
:: ============================
FOR %%S IN (%SERVIDORES:,= %) DO (

    CALL :LOG "[%%S] Consultando estado do servico"

    FOR /F "tokens=3" %%A IN (
        'sc \\%%S query "%SERVICO%" ^| find "STATE"'
    ) DO SET STATE=%%A

    IF "!STATE!"=="RUNNING" (

        CALL :LOG "[%%S] Servico RUNNING"

        IF "%DRY_RUN%"=="1" (
            CALL :LOG "[%%S] DRY-RUN: stop/start ignorados"
        ) ELSE (

            CALL :EVENT "[%%S] Reiniciando servico %SERVICO%"

            sc \\%%S stop "%SERVICO%" >> "%LOG_FILE%" 2>&1
            CALL :WAIT %%S STOPPED

            sc \\%%S start "%SERVICO%" >> "%LOG_FILE%" 2>&1
            CALL :WAIT %%S RUNNING

            CALL :LOG "[%%S] Servico reiniciado com sucesso"
        )

    ) ELSE (
        CALL :LOG "[%%S] Estado atual: !STATE!"
    )
)

CALL :LOG "Execucao finalizada"
EXIT /B 0

:: ============================
:: MENU INTERATIVO
:: ============================
:MENU
ECHO ================================
ECHO  RESTART DE SERVICOS - ENTERPRISE
ECHO ================================
SET /P SERVIDORES=Informe os servidores (ex: SRV01,SRV02):
SET /P SERVICO=Informe o nome do servico:
SET /P CONFIRMA=Dry run? (S/N):

IF /I "%CONFIRMA%"=="S" SET DRY_RUN=1

GOTO CONTINUE

:CONTINUE
SHIFT
SHIFT
GOTO :EOF

:: ============================
:: FUNCAO: AGUARDA ESTADO
:: ============================
:WAIT
SET SERVER=%1
SET EXPECTED=%2
SET ELAPSED=0

:WAIT_LOOP
FOR /F "tokens=3" %%A IN (
    'sc \\%SERVER% query "%SERVICO%" ^| find "STATE"'
) DO SET CURRENT=%%A

IF "%CURRENT%"=="%EXPECTED%" EXIT /B 0

IF %ELAPSED% GEQ %MAX_WAIT% (
    CALL :LOG "[%SERVER%] TIMEOUT aguardando %EXPECTED%"
    EXIT /B 20
)

timeout /t 2 >NUL
SET /A ELAPSED+=2
GOTO WAIT_LOOP

:: ============================
:: LOG
:: ============================
:LOG
ECHO %DATE% %TIME% - %~1
ECHO %DATE% %TIME% - %~1 >> "%LOG_FILE%"
EXIT /B

:: ============================
:: EVENT VIEWER
:: ============================
:EVENT
EVENTCREATE /T INFORMATION /ID 100 /L APPLICATION /SO "%EVENT_SOURCE%" /D "%~1" >NUL 2>&1
EXIT /B
