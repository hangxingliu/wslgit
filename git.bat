@echo off

rem  Update: 2019-02-06
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
rem   3. How to detect a variable is empty:
rem        Stackoverflow: https://stackoverflow.com/a/2541820/3831547
rem   4. Get command exit code: (Just like "$?" on linux)
rem        Stackoverflow: https://stackoverflow.com/a/334890/3831547
rem
rem

setlocal enabledelayedexpansion

if [%1] == [] goto WITHOUT_ARGS

:WITH_ARGS
	set args=%*
	set "args=%args:\=\\%"

	wsl wslgit.sh %args%
	exit /b %errorlevel%

:WITHOUT_ARGS
	wsl wslgit.sh
	exit /b %errorlevel%
