# Changelog

### 2019-04-16

1. Fixed bug caused by Windows 10 19H1 changed the output of `mount` command 
	- Related pull request: <https://github.com/hangxingliu/wslgit/pull/13> (Thanks @kiroushi)
	- Related issue: <https://github.com/hangxingliu/wslgit/issues/10>

### 2019-03-11

1. **BREAKING CHANGE:** Start git installed in WSL in interactive mode. 
	- If you want to use non-interactive mode, **just like before**: Set Windows env variable `WSLGIT_USE_INTERACTIVE_SHELL` to `true`.
2. Fixed error in the unix path to win path convert function.
	- Related issue: <https://github.com/hangxingliu/wslgit/issues/11> (Thanks @rennex)
3. Added path converting for the output of `git init`

### 2019-03-06

1. Fixed the error when the default awk in system is `mawk`
	- Related issue: <https://github.com/hangxingliu/wslgit/issues/8> (Thanks @joaopluigi)

### 2019-02-08

1. Replaced WSL launch command from `bash` to `wsl`
	- Related issue: <https://github.com/hangxingliu/wslgit/issues/3>
2. Fixed error when executing `git.bat` without arguments
3. Refactored `wslgit.sh` in order to convert path more correctly. 
	- Supported convert path associated the drive be mounted manually
	- Supported git long form argument and double dash (eg. `--file=xxx` and `--`)
4. Internal change:
	- transfer env variable `WSLGIT_SH_CWD` into WSL for set up cwd in WSL correctly.
	- replace implementation of path convertor from `wslpath` to awk scripts and `mount` command.
