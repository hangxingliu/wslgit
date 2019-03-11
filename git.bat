@echo off

rem  Update: 2019-03-11
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

set "currentdir=%cd:\=\\%"

rem Enable interactive mode by default.
rem And disable it by set Windows environment variale WSLGIT_USE_INTERACTIVE_SHELL to 0 or false
set "bashic=true"
if [%WSLGIT_USE_INTERACTIVE_SHELL%] == [0] set bashic=false
if [%WSLGIT_USE_INTERACTIVE_SHELL%] == [false] set bashic=false

if [%1] == [] goto WITHOUT_ARGS

:WITH_ARGS
	set args=%*
	set "args=%args:\=\\%"

	if %bashic% == true (
		wsl bash -ic 'env "WSLGIT_SH_CWD=%currentdir%" wslgit.sh %args%'
	) else (
		wsl env "WSLGIT_SH_CWD=%currentdir%" wslgit.sh %args%
	)
	exit /b %errorlevel%

:WITHOUT_ARGS
	if %interactive% == true (
		wsl bash -ic 'env "WSLGIT_SH_CWD=%currentdir%" wslgit.sh'
	) else (
		wsl env "WSLGIT_SH_CWD=%currentdir%" wslgit.sh
	)
	exit /b %errorlevel%
