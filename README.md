# 获取脚本依赖

一个管理脚本依赖的工具.

在 CMD 脚本中添加指定格式注释后, 用本工具读取这些注释, 会将文件复制到指定位置, 以提供 CMD 脚本调用.

注意: 在 Bin 目录需要 MSVC BuildTools 的一些文件, 详情查看`Bin/Readme.md`.

## 注释格式

::类型:文件名::

以 2 个`:`开头和结尾, 以 1 个`:`分隔`类型`和`文件名`.

- ::Bin:可执行文件名::

  可执行文件依赖, 将可执行文件和相关库文件复制到指定位置.

- ::Script:脚本文件名::

  脚本文件依赖, 将递归查询脚本文件并复制相关依赖到指定位置.

- ::File:其它文件名::

  其它文件依赖, 将文件复制到指定位置.

- ::Folder:目录名::

  目录依赖, 将目录复制到指定位置.

## 配置文件

配置文件为非标准 INI 格式, 不支持行尾注释.

执行时读取同名但扩展名为`.ini`的配置文件, 通常为`ScriptDependents.ini`.

### 格式

- 注释行(comment)

  以`#`或者`;`开头的行.

- 无效行(invalid)

  不含`=`或者键值为空.

- 段(section)

  以`[]`包裹的行.

- 键(key)

  行第一个`=`左边的字符串.

- 值(value)

  行第一个`=`右边的字符串.

### 内容

- 清理设置(CLEAN)

  段外键值, 键`CLEAN`, 可选值`TRUE`或者`FALSE`, 默认值`FALSE`. 执行前清空目标目录, `TRUE`清空, `FALSE`忽略.

- 来源路径(SRC)

  指定来源路径, 可以指定多个用`;`分隔.

- 目标路径(DST)

  指定目标路径, 目录不存在时自动创建.

- 段(BIN,SCRIPT,FILE,FOLDER)

  段名为`BIN`和`SCRIPT`和`FILE`和`FOLDER`, 对应注释类型名.

- 变量和转义

  配置文件中`%`包裹的变量, 在执行时会被展开. 需要保留`%`时, 用`%%`方式进行转义.

### 示例

```ini
CLEAN=TRUE

[BIN]
SRC=%CYGWIN_HOME%\Bin;%MSYS_HOME%\usr\bin
DST=Target\Bin

[SCRIPT]
SRC=%CD%\..\Script
DST=Target\Script

[FILE]
SRC=%CD%\..\
DST=Target\File

[FOLDER]
SRC=%CD%\..\
DST=Target\Folder
```

## 命令行:

命令行: ScriptDependents.cmd <脚本文件>...

- 脚本文件

  可以指定一个或多个脚本文件，支持`*`和`?`通配符.

### 示例

```bat
ScriptDependents.cmd 1.cmd 2.cmd
ScriptDependents.cmd ..\xxx\*.cmd
```
