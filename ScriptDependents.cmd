::获取脚本依赖
::@author FB
::@version 1.1.0

::Bin:Dumpbin.exe::
::Script:Object.Destroy.CMD::
::Script:Config.FileRead.CMD::

::初始化环境
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"
SET "PATH=%CD%\Bin;%CD%\Script;%PATH%"
SET "EXIT_CODE=0"
::读取配置
CALL Object.Destroy.CMD "CONFIG"
CALL Config.FileRead.CMD "CONFIG" "%~n0.ini"
::初始化配置
FOR /F "tokens=1,* usebackq delims==" %%A IN (`SET "CONFIG." 2^>NUL`) DO (
  CALL SET "%%~A=%%~B"
  IF /I "%%~xA" == ".DST" (
    IF /I "%CONFIG.CLEAN%" == "TRUE" (
      CALL RMDIR /Q /S "%%~B" 1>NUL 2>&1
    )
    CALL MKDIR "%%~B" 1>NUL 2>&1
  )
)
::执行全部
FOR %%A IN (%*) DO (
  CALL :SCRIPT "%%~A"
)
EXIT /B %EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::扫描Script依赖(递归调用)
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

::复制Script文件
:COPY_SCRIPT
IF NOT EXIST "%CONFIG.SCRIPT.DST%\%~1" (
  ECHO %~1
  COPY "%~$CONFIG.SCRIPT.SRC:1" "%CONFIG.SCRIPT.DST%\%~1"
  EXIT /B
)
EXIT /B 1

::扫描Bin依赖(递归调用)
:BIN
FOR /F "tokens=* usebackq" %%A IN (
  `Dumpbin.exe /DEPENDENTS "%~1" ^| FINDSTR /I /R /C:"^    [^ ].*\.DLL$"`
) DO IF EXIST "%%~$CONFIG.BIN.SRC:A" (
  CALL :COPY_BIN "%%~A" && CALL :BIN "%CONFIG.BIN.DST%\%%~A" || SET /A "EXIT_CODE+=1"
)
EXIT /B

::复制Bin文件
:COPY_BIN
IF NOT EXIST "%CONFIG.BIN.DST%\%~1" (
  ECHO %~1
  COPY "%~$CONFIG.BIN.SRC:1" "%CONFIG.BIN.DST%\%~1"
  EXIT /B
)
EXIT /B 1

::复制Other文件
:COPY_OTHER
IF NOT EXIST "%CONFIG.OTHER.DST%\%~1" (
  ECHO %~1
  COPY "%~$CONFIG.OTHER.SRC:1" "%CONFIG.OTHER.DST%\%~1"
  EXIT /B
)
EXIT /B 1
