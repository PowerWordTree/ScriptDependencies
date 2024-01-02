::获取脚本依赖
::@author FB
::@version 1.2.0

::Bin:Dumpbin.exe::
::Bin:Link.exe::
::Script:Config.FileRead.CMD::

::初始化环境
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
CD /D "%~dp0"
::读取配置
CALL Config.FileRead.CMD "_CONFIG" "%~n0.ini"
::初始化配置
FOR /F "tokens=1,* usebackq delims==" %%A IN (`SET "_CONFIG." 2^>NUL`) DO (
  ::::展开变量
  CALL SET "%%~A=%%~B"
  ::::创建目录
  IF /I "%%~xA" == ".DST" (
    IF /I "%_CONFIG.CLEAN%" == "TRUE" (
      CALL RMDIR /Q /S "%%~B" 1>NUL 2>&1
    )
    CALL MKDIR "%%~B" 1>NUL 2>&1
  )
)
::执行全部
FOR %%A IN (%*) DO (
  CALL :SCRIPT "%%~A"
)
EXIT /B %_EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::扫描Script依赖(递归调用)
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

::扫描Bin依赖(递归调用)
:BIN
FOR /F "tokens=* usebackq" %%A IN (
  `Dumpbin.exe /DEPENDENTS "%~1" ^| FINDSTR /I /R /C:"^    [^ ].*\.DLL$"`
) DO IF EXIST "%%~$_CONFIG.BIN.SRC:A" (
  CALL :COPY_BIN "%%~A" && CALL :BIN "%_CONFIG.BIN.DST%\%%~A"
)
EXIT /B

::复制Script文件
:COPY_SCRIPT
IF EXIST "%_CONFIG.SCRIPT.DST%\%~1" EXIT /B 1
ECHO =^> %~1
COPY /Y "%~$_CONFIG.SCRIPT.SRC:1" "%_CONFIG.SCRIPT.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B

::复制Bin文件
:COPY_BIN
IF EXIST "%_CONFIG.BIN.DST%\%~1" EXIT /B 1
ECHO =^> %~1
COPY /Y "%~$_CONFIG.BIN.SRC:1" "%_CONFIG.BIN.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B

::复制FILE文件
:COPY_FILE
IF EXIST "%_CONFIG.FILE.DST%\%~1" EXIT /B 1
ECHO =^> %~1
COPY /Y "%~$_CONFIG.FILE.SRC:1" "%_CONFIG.FILE.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B

::复制FOLDER文件
:COPY_FOLDER
IF EXIST "%_CONFIG.FOLDER.DST%\%~1" EXIT /B 1
ECHO =^> %~1
XCOPY /E /S /I /Q /Y "%~$_CONFIG.FOLDER.SRC:1" "%_CONFIG.FOLDER.DST%\%~1" ^
  || SET /A "_EXIT_CODE+=1"
EXIT /B
