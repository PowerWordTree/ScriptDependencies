# 获取脚本依赖

一个管理脚本依赖的工具.

当 CMD 脚本中包含`::Bin:Xxxx.exe::`和`::Script:Xxxx.cmd::`注释时, 表示 CMD 脚本使用了这些依赖文件. 本工具将这些依赖文件复制到指定位置, 以提供 CMD 脚本调用.

注意: 在 Bin 目录需要 MSVC BuildTools 的一些文件, 详情请查看`Bin/Readme.md`.

## 配置文件

执行时会读取同名但扩展名为`.ini`的配置文件, 通常为`ScriptDependents.ini`. 为非标准 INI 格式, 提供源路径和目标路径等配置.

### 格式

- 注释行(comment)

  以`#`开头的行.

- 无效行(invalid)

  不含`=` 或者 值为空.

- 段(section)

  以`[]`包裹的行.

- 键(key)

  行第一个`=`左边的字符串.

- 值(value)

  行第一个`=`右边的字符串.

### 内容

- 清理设置(CLEAN)

  段外键值, 键`CLEAN`, 可选值`TRUE`或者`FALSE`, 默认值`FALSE`. 执行前清空目标目录, `TRUE`清空, `FALSE`忽略.

- 可执行文件段(BIN)

  段名`BIN`, 段内定义`SRC`和`DST`键值. `SRC`指定依赖来源路径, 可以指定多个, 用`;`分隔. `DST`指定复制依赖到目标路径, 复制包含相关库文件.

- 脚本文件段(SCRIPT)

  段名`SCRIPT`, 段内定义`SRC`和`DST`键值. `SRC`指定依赖来源路径, 可以指定多个, 用`;`分隔. `DST`指定复制依赖到目标路径, 复制包含相关依赖脚本.

- 变量和转义

  配置文件中`%`包裹的变量, 在执行时会被展开. 需要保留`%`时, 用`%%`方式进行转义.

### 示例

```ini
CLEAN=TRUE

[BIN]
SRC=%CYGWIN_HOME%\Bin
DST=Target\Bin

[SCRIPT]
SRC=%CD%\..\Script
DST=Target\Script
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
