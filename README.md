# WSLGit

[![Build Status](https://travis-ci.org/hangxingliu/wslgit.svg?branch=master)](https://travis-ci.org/hangxingliu/wslgit)

Use Git installed in WSL(windows Subsystem for Linux) from Windows and Visual Studio Code.

The project was inspired by [A. R. S.](https://github.com/andy-5)'s project [andy-5/wslgit](https://github.com/andy-5/wslgit) written by Rust.   
But why do I re-implement it by scripts, because I hope the wslgit tools could support any mount points (but not only under the `/mnt/`) and could be used without compiling.

## Usage

1. Please ensure `git` is installed in your WSL.
2. Copy `wslgit.sh` to the `/usr/bin/` directory in your WSL.
3. Add the following config into yout VSCode Settings (Remember to replace the path)

``` json
{
	"git.path": "C:\\path\\to\\git.bat"
}
```

## Update

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

[CHANGELOG](CHANGELOG.md)

## Under the hood

### How does it work

1. Pass all arguments and env variable `WSLGIT_SH_CWD` into `wslgit.sh` in WSL when you or VSCode execute `git.bat`.
2. Get all mounted drive info by `mount -t drvfs` command in `wslgit.sh`.
3. Move cwd(current working directory) to `WSLGIT_SH_CWD`.
4. Iterate arguments, and replace each path argument from Windows style to Linux style by reference to mounted drive info.
5. And convert the path in the git output to Windows style if git arguments included special keywords/actions. (Eg. `rev-parse`, `remote`)
6. Why the it doesn't use `wslpath` for path convert, please reference to the test case: [test-win/main.js](test-win/main.js)


### How to test it

- Automatic test on Linux (also WSL): [test-ci/main.sh](test-ci/main.sh)
- Semi-automated test on Windows: [CONTRIBUTING.md](CONTRIBUTING.md)

### How to contribute (issue/pull request)

[CONTRIBUTING.md](CONTRIBUTING.md)

## Related links

- <https://github.com/andy-5/wslgit>
- <https://blogs.msdn.microsoft.com/commandline/2017/11/28/a-guide-to-invoking-wsl/>

## Author

[LiuYue (@hangxingliu)](https://github.com/hangxingliu)

## License

[GPL-3.0](LICENSE)
