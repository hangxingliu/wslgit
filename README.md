# WSLGit

[![Build Status](https://travis-ci.org/hangxingliu/wslgit.svg?branch=master)](https://travis-ci.org/hangxingliu/wslgit)

Use Git installed in WSL(windows Subsystem for Linux) from Windows and Visual Studio Code.

The project was inspired by [A. R. S.](https://github.com/andy-5)'s project [andy-5/wslgit](https://github.com/andy-5/wslgit) written by Rust.

## Usage

0. Please make sure `git` and `gawk` have been installed in your WSL.
	- one-liner: `sudo apt install git gawk -y`
1. Copy `wslgit.sh` to `/usr/bin/` in your WSL.
2. Configure your VSCode `settings.json`, set `git.path` as the path to file `git.bat` located in this project, example:

``` json
{
	"git.path": "C:\\path\\to\\git.bat"
}
```

## Author

[LiuYue (hangxingliu)](https://github.com/hangxingliu)

## License

[GPL-3.0](LICENSE)
