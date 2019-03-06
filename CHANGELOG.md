# Changelog

### 2019-03-06

1. Fixed the error when the default awk in system is `mawk`
	- Related issue: <https://github.com/hangxingliu/wslgit/issues/8> (Thank @joaopluigi)

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
