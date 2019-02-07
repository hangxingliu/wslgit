# Contributing

👨‍💻 **Please** to read this document before **contributing code**

## Commit Issue/Pull Request

Submitting an issue to this project is a easy way to contribute. 
If you find bug in this project or have of an improvement, 
you can create [issue](https://github.com/hangxingliu/wslgit/issues). Of course, 
Pull Requests are welcomed for bug fixes and improvements.

### Pull Request Requirements

1. Included any one description followed in your pull request content
	- What bugs your pull request fixes
	- What improvements your pull request includes
	- Welcome to add documentation reference 
2. Passed auto test suites. [Travis-CI](https://travis-ci.org/hangxingliu/wslgit)
	- `./test-ci/main.sh`
3. Passed the following **semi-automated test**


## Semi-automated Test on Windows

The reason why I wrote this section is because I don't know the automated testing technology on Windows.

You can use the following tests to ensure scripts (current or modified) are working fine.

## Prerequisites

- OS: Windows 10 
- Install Node.js
- Install Visual Studio Code
- _(Optional)_ Install two different WSL distro.
- _(Optional)_ A USB Disk (test path convert for drive be mounted manually)

## Tests

1. Execute Windows test Node.js script:
	- `node.exe test-win/main.js`
2. Open a git project in Visual Studio Code
	- Check is source control panel working fine in Visual Studio Code 
	- Try modify files.then add, commit them in Visual Studio Code
