::��ȡ�ű�����
::@author FB
::@version 1.2.0

::Bin:Dumpbin.exe::
::Bin:Link.exe::
::Script:Config.FileRead.CMD::

::��ʼ������
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
CD /D "%~dp0"
::��ȡ����
CALL Config.FileRead.CMD "_CONFIG" "%~n0.ini"
::��ʼ������
FOR /F "tokens=1,* usebackq delims==" %%A IN (`SET "_CONFIG." 2^>NUL`) DO (
  ::::չ������
  CALL SET "%%~A=%%~B"
  ::::����Ŀ¼
  IF /I "%%~xA" == ".DST" (
    IF /I "%_CONFIG.CLEAN%" == "TRUE" (
      CALL RMDIR /Q /S "%%~B" 1>NUL 2>&1
    )
    CALL MKDIR "%%~B" 1>NUL 2>&1
  )
)
::ִ��ȫ��
FOR %%A IN (%*) DO (
  CALL :SCRIPT "%%~A"
)
EXIT /B %_EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::ɨ��Script����(�ݹ����)
:SCRIPT
FOR /F "tokens=1,2 usebackq delims=#/;: " %%A IN (
  `TYPE "%~1" ^| FINDSTR "::[^:][^:]*:[^:][^:]*::"`
) DO IF /I "%%~A" == "Bin" (
  CALL :COPY_BIN "%%~B" && CALL :BIN "%_CONFIG.BIN.DST%\%%~B"
) ELSE IF /I "%%~A" == "Script" (
  CALL :COPY_SCRIPT "%%~B" && CALL :SCRIPT "%_CONFIG.SCRIPT.DST%\%%~B"
) ELSE IF /I "%%~A" == "File" (
  CALL :COPY_FILE "%%~B"
) ELSE IF /I "%%~A" == "Folder" (
  CALL :COPY_FOLDER "%%~B"
)
EXIT /B

::ɨ��Bin����(�ݹ����)
:BIN
FOR /F "tokens=* usebackq" %%A IN (
  `Dumpbin.exe /DEPENDENTS "%~1" ^| FINDSTR /I /R /C:"^    [^ ].*\.DLL$"`
) DO IF EXIST "%%~$_CONFIG.BIN.SRC:A" (
  CALL :COPY_BIN "%%~A" && CALL :BIN "%_CONFIG.BIN.DST%\%%~A"
)
EXIT /B

::����Script�ļ�
:COPY_SCRIPT
IF EXIST "%_CONFIG.SCRIPT.DST%\%~1" EXIT /B 1
ECHO =^> %~1
COPY /Y "%~$_CONFIG.SCRIPT.SRC:1" "%_CONFIG.SCRIPT.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B

::����Bin�ļ�
:COPY_BIN
IF EXIST "%_CONFIG.BIN.DST%\%~1" EXIT /B 1
ECHO =^> %~1
COPY /Y "%~$_CONFIG.BIN.SRC:1" "%_CONFIG.BIN.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B

::����FILE�ļ�
:COPY_FILE
IF EXIST "%_CONFIG.FILE.DST%\%~1" EXIT /B 1
ECHO =^> %~1
COPY /Y "%~$_CONFIG.FILE.SRC:1" "%_CONFIG.FILE.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B

::����FOLDER�ļ�
:COPY_FOLDER
IF EXIST "%_CONFIG.FOLDER.DST%\%~1" EXIT /B 1
ECHO =^> %~1
XCOPY /E /S /I /Q /Y "%~$_CONFIG.FOLDER.SRC:1" "%_CONFIG.FOLDER.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B
