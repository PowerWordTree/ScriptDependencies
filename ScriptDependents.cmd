::��ȡ�ű�����
::@author FB
::@version 0.1.0

::Bin:Dumpbin.exe::
::Script:Config.FileRead.CMD::
::Script:Object.ListAll.CMD::

::��ʼ������
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"
SET "PATH=%CD%\Bin;%CD%\Script;%PATH%"
::��ȡ����
CALL Config.FileRead.CMD "CONFIG" "%~n0.ini"
::չ������
CALL SET "CONFIG.BIN.SRC=%CONFIG.BIN.SRC%"
CALL SET "CONFIG.BIN.DST=%CONFIG.BIN.DST%"
CALL SET "CONFIG.SCRIPT.SRC=%CONFIG.SCRIPT.SRC%"
CALL SET "CONFIG.SCRIPT.DST=%CONFIG.SCRIPT.DST%"
::ִ��ȫ��
IF /I "%CONFIG.CLEAN%" == "TRUE" (
  RMDIR /Q /S "%CONFIG.BIN.DST%" 1>NUL 2>&1
  RMDIR /Q /S "%CONFIG.SCRIPT.DST%" 1>NUL 2>&1
)
MKDIR "%CONFIG.BIN.DST%" 1>NUL 2>&1
MKDIR "%CONFIG.SCRIPT.DST%" 1>NUL 2>&1
FOR %%A IN (%*) DO (
  CALL :SCRIPT "%%~A"
)
EXIT /B

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::ɨ��Script����(�ݹ����)
:SCRIPT
FOR /F "tokens=1,2 usebackq delims=:" %%A IN (
  `TYPE "%~1" ^| FINDSTR "::[^:][^:]*:[^:][^:]*::"`
) DO IF /I "%%~A" == "Bin" (
  CALL :COPY_BIN "%%~B" && CALL :BIN "%CONFIG.BIN.DST%\%%~B"
) ELSE IF /I "%%~A" == "Script" (
  CALL :COPY_SCRIPT "%%~B" && CALL :SCRIPT "%CONFIG.SCRIPT.DST%\%%~B"
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
  CALL :COPY_BIN "%%~A" && CALL :BIN "%CONFIG.BIN.DST%\%%~A"
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
