::@author FB
::@version 0.1.0

::���ݽṹΪObject
::��֧��һ����
::��%�����ı������ᱻչ��

::���KEY��#��ͷ,ʲôҲ����
::���VALUE��Ϊ��,���浽����
::���KEY��[]����,�л���ǰ��

::��ȡ�����ļ�
::  ����1: ʵ������
::  ����2: �����ļ�

::Script:String.Trim.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@VAR=%~1" & SET "@SECTION=."
FOR /F "eol=# tokens=1,* usebackq delims==" %%A IN (
  `TYPE "%~2" 2^>NUL`
) DO (
  SET "@KEY=%%~A"
  SET "@VALUE=%%~B"
  CALL String.Trim.CMD %%@KEY%% & CALL SET "@KEY=%%@%%"
  CALL String.Trim.CMD %%@VALUE%% & CALL SET "@VALUE=%%@%%"
  CALL :_PARSE_LINE
)
SET "@VALUE=" & SET "@KEY=" & SET "@SECTION=" & SET "@VAR="
EXIT /B

:_PARSE_LINE
IF NOT "%@KEY:~,1%" == "#" IF NOT "%@VALUE%" == "" (
  SET "%@VAR%%@SECTION%%@KEY%=%@VALUE%"
) ELSE IF "%@KEY:~,1%" == "[" IF "%@KEY:~-1%" == "]" (
  SET "@SECTION=.%@KEY:~1,-1%."
)
GOTO :EOF