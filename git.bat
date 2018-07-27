@echo off

rem  Update: 2018-07-27
rem  Author: Liu Yue (hangxingliu@gmail.com)
rem
rem  Description:
rem    Pipe git invoking from Windows to git in WSL.
rem    And escape character "\\" to "\\\\"
rem
rem
rem  Knowledges:
rem   1. How to implements string replace in Windows batch:
rem        set "VAR=%VAR:REPLACE_FROM=REPLACE_TO%"
rem        Chinese blog: https://www.jb51.net/article/110243.htm
rem   2. Why prepend  `setlocal enabledelayedexpansion`
rem        Stackoverflow: https://stackoverflow.com/questions/6679907

setlocal enabledelayedexpansion

set args=%*
set "args=%args:\=\\%"

bash -c 'wslgit.sh %args%'
