# WSLGit

[![Build Status](https://travis-ci.org/hangxingliu/wslgit.svg?branch=master)](https://travis-ci.org/hangxingliu/wslgit)

Use Git installed in WSL(windows Subsystem for Linux) from Windows and Visual Studio Code.

The project was inspired by [A. R. S.](https://github.com/andy-5)'s project [andy-5/wslgit](https://github.com/andy-5/wslgit) written by Rust.

## Usage

0. Please make sure `git` have been installed in your WSL.
	- one-liner: `sudo apt install git -y`
1. Copy `wslgit.sh` to `/usr/bin/` in your WSL.
2. Configure your VSCode `settings.json`, set `git.path` as the path to file `git.bat` located in this project, example:

``` json
{
	"git.path": "C:\\path\\to\\git.bat"
}
```

## Principles

1. Transfer git invoking from Windows batch file `git.bat` to `wslgit.sh` located in WSL.
2. Convert Windows path in parameters to Linux path by `wslpath` or `awk`
3. Convert Linux path in git output back to Windows path.
	- Convert path by `wslpath` if git output only contains one Linux path
	- Otherwise, convert path by `awk` following WSL mounted `drvfs` list (`mount -t drvfs`)

## Author

[LiuYue (hangxingliu)](https://github.com/hangxingliu)

## License

[GPL-3.0](LICENSE)
