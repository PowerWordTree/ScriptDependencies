::��ȡ�ű�����
::@author FB
::@version 1.1.0

::Bin:Dumpbin.exe::
::Script:Object.Destroy.CMD::
::Script:Config.FileRead.CMD::

::��ʼ������
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"
SET "PATH=%CD%\Bin;%CD%\Script;%PATH%"
SET "EXIT_CODE=0"
::��ȡ����
CALL Object.Destroy.CMD "CONFIG"
CALL Config.FileRead.CMD "CONFIG" "%~n0.ini"
::��ʼ������
FOR /F "tokens=1,* usebackq delims==" %%A IN (`SET "CONFIG." 2^>NUL`) DO (
  CALL SET "%%~A=%%~B"
  IF /I "%%~xA" == ".DST" (
    IF /I "%CONFIG.CLEAN%" == "TRUE" (
      CALL RMDIR /Q /S "%%~B" 1>NUL 2>&1
    )
    CALL MKDIR "%%~B" 1>NUL 2>&1
  )
)
::ִ��ȫ��
FOR %%A IN (%*) DO (
  CALL :SCRIPT "%%~A"
)
EXIT /B %EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::ɨ��Script����(�ݹ����)
:SCRIPT
FOR /F "tokens=1,2 usebackq delims=#/;: " %%A IN (
  `TYPE "%~1" ^| FINDSTR "::[^:][^:]*:[^:][^:]*::"`
) DO IF /I "%%~A" == "Bin" (
  CALL :COPY_BIN "%%~B" && CALL :BIN "%CONFIG.BIN.DST%\%%~B" || SET /A "EXIT_CODE+=1"
) ELSE IF /I "%%~A" == "Script" (
  CALL :COPY_SCRIPT "%%~B" && CALL :SCRIPT "%CONFIG.SCRIPT.DST%\%%~B" || SET /A "EXIT_CODE+=1"
) ELSE IF /I "%%~A" == "Other" (
  CALL :COPY_OTHER "%%~B" || SET /A "EXIT_CODE+=1"
)
EXIT /B

::����Script�ļ�
:COPY_SCRIPT
IF NOT EXIST "%CONFIG.SCRIPT.DST%\%~1" (
  ECHO %~1
  COPY "%~$CONFIG.SCRIPT.SRC:1" "%CONFIG.SCRIPT.DST%\%~1"
  EXIT /B
)
EXIT /B 1

::ɨ��Bin����(�ݹ����)
:BIN
FOR /F "tokens=* usebackq" %%A IN (
  `Dumpbin.exe /DEPENDENTS "%~1" ^| FINDSTR /I /R /C:"^    [^ ].*\.DLL$"`
) DO IF EXIST "%%~$CONFIG.BIN.SRC:A" (
  CALL :COPY_BIN "%%~A" && CALL :BIN "%CONFIG.BIN.DST%\%%~A" || SET /A "EXIT_CODE+=1"
)
EXIT /B

::����Bin�ļ�
:COPY_BIN
IF NOT EXIST "%CONFIG.BIN.DST%\%~1" (
  ECHO %~1
  COPY "%~$CONFIG.BIN.SRC:1" "%CONFIG.BIN.DST%\%~1"
  EXIT /B
)
EXIT /B 1

::����Other�ļ�
:COPY_OTHER
IF NOT EXIST "%CONFIG.OTHER.DST%\%~1" (
  ECHO %~1
  COPY "%~$CONFIG.OTHER.SRC:1" "%CONFIG.OTHER.DST%\%~1"
  EXIT /B
)
EXIT /B 1
