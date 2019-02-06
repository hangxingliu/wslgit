#!/usr/env/bin node
//@ts-check

const fs = require('fs');
const path = require('path');
const os = require('os');
const nodeAssert = require('assert');
const childProcess = require('child_process');
const readLine = require('readline');
const color1 = getColor(process.stdout);
const color2 = getColor(process.stderr);

const workspace = path.join(__dirname, 'test-workspace');
const git = path.join(__dirname, '..', 'git.bat');
const usbWorkspaceName = 'wslgit-test';
let mountedUSB = '';
let last = { code: 0, signal: '', stdout: '', stderr: '' };

prepare().then(test).then(done).catch(fatal);

async function test() {

	echo(`[.] test: empty argument for git.bat`, color1.cyan);
	await exec(git, [], { cwd: workspace, echo: false });
	assert(/usage:\s+git/i.test(last.stdout), 'print git usage info');


	echo(`[.] test: git init`, color1.cyan);
	await vitalExec(git, ['init'], { cwd: workspace, echo: true });
	assert(/Initialized empty Git repository/i.test(last.stdout), 'init git repo success');


	echo(`[.] test: git rev-parse --show-toplevel`, color1.cyan);
	await vitalExec(git, ['rev-parse', '--show-toplevel'], { cwd: workspace, echo: true });
	assert(last.stdout.indexOf(workspace) >= 0, 'git top level is workspace');


	echo(`[.] test: git add file with absolute path`, color1.cyan);
	const filePath1 = path.join(workspace, 'README.md');
	fs.writeFileSync(filePath1, '# Just Test');
	await vitalExec(git, ['add', '-v', filePath1], { cwd: workspace });
	assert(last.stdout.indexOf('README.md') >= 0, 'add success');


	echo(`[.] test: git add file with relatived path`, color1.cyan);
	const filePath2 = path.join(workspace, 'DOCS.md');
	fs.writeFileSync(filePath2, '# Just Test Again');
	await vitalExec(git, ['add', '-v', 'DOCS.md'], { cwd: workspace });
	assert(last.stdout.indexOf('DOCS.md') >= 0, 'add success');


	echo(`[.] test: git commit`, color1.cyan);
	await vitalExec(git, ['commit', '-m', 'Init commit!'], { cwd: workspace });
	assert(last.stdout.indexOf('Init commit') >= 0, 'commit success (commit message)');
	assert(last.stdout.indexOf('2 files changed') >= 0, 'commit success (2 files changed)');


	echo(`[.] test: convert long form argument (example: --output=C:\\1.zip)`, color1.cyan);
	const archiveFile = path.join(workspace, 'archive', 'HEAD.zip');
	fs.mkdirSync(path.dirname(archiveFile));
	await vitalExec(git, ['archive', '-v', '--format=zip', `--output=${archiveFile}`, 'HEAD'],
		{ cwd: workspace });


	echo(`[.] test: get all mount drvfs in wsl`, color1.cyan);
	await listWslDrvFs();

	echo(`[.] test: new drive in wsl`, color1.cyan);
	let lastDrives = await listWindowsDrv();
	const insertedUSB = await new Promise(_resolve => {
		const read = readLine.createInterface({
			input: process.stdin, output: process.stdout, terminal: false,
			prompt: [
				`  Insert a USB device `,
				`    WARNING: This test will create a temporary dir "${usbWorkspaceName}" on your USB device`,
				`  Y: I inserted / N: cancel this test / Special drive caption (eg. E:) `,
				`  > `
			].join('\n')
		});
		const resolve = it => { read.close(); _resolve(it); };
		read.prompt();
		read.on('line', async (line) => {
			line = line.trim();
			if (/^n$/i.test(line)) return resolve(false);
			if (/^y$/i.test(line)) {
				const drives = await listWindowsDrv();
				const newDrv = drives.find(it => lastDrives.findIndex(last => last === it) < 0);
				if (newDrv) return resolve(newDrv);
				echoErr(`[-] no new drive detected!`);
			}
			if (/^\w:$/.test(line)) {
				const drv = lastDrives.find(it => it === line.toUpperCase());
				if (drv) return resolve(drv);
				echoErr(`[-] drive ${line} is not found!`);
			}
			read.prompt();
		})
	});
	if (!insertedUSB)
		return echo('[~] skip: user cancelled', color1.yellow);

	// ==================================================================
	// Following test cases are used for check gitwsl is working fine
	//   on the drive be mounted manually. (Eg. directory on a usb disk)
	// ==================================================================

	echo(`[~] new drive: ${insertedUSB}`, color1.green);
	const usbWorkspace = path.join(insertedUSB, usbWorkspaceName);
	const mountTo = '/tmp/wslgit-test-mount';

	echo(`[.] test: mount ${insertedUSB} on ${mountTo} in wsl`, color1.cyan);

	echo(`    [.] create mount point directory in wsl`, color1.cyan);
	await vitalExec('wsl', ['mkdir', '-p', mountTo]);

	echo(`    [.] list current mount point in wsl`, color1.cyan);
	await vitalExec('wsl', ['mount', '-t', 'drvfs']);

	if (last.stdout.indexOf(mountTo) < 0) {
		echo(`    [.] whoami and id -g`, color1.cyan);
		await vitalExec('wsl', ['whoami']);
		const whoami = last.stdout.trim();
		await vitalExec('wsl', ['id', '-g']);
		const group = last.stdout.trim();
		const opt = `metadata,umask=22,fmask=11,uid=${whoami},gid=${group}`;

		echo(`    [.] sudo mount -o ${opt} -t drvfs ${insertedUSB} ${mountTo}`,
			color1.cyan);
		await vitalExec('wsl', [
			'sudo', 'mount', '-o', opt, '-t', 'drvfs',
			insertedUSB, mountTo
		]);
		mountedUSB = mountTo;
	}

	// 🧪 The reason why the script doesn't use wslpath:
	// Example (Last test on Windows 10 Pro 1803 OS build: 17134.523):
	//    We mount inserted USB drive D: on /tmp/test-mount
	//    The result of `wslpath -w /tmp/test-mount/dir` is:   D:\dir
	//    But the result of `wslpath D:\\` is:                 wslpath: D:\: No such file or directory
	echo(`[.] test shortcomings of wslpath`, `${color1.cyan}${color1.bold}`);
	echo(`    [.] wslpath D:\\`, color1.cyan);
	await exec('wsl', ['wslpath', 'D:\\']);
	echo(`    [.] wslpath -w ${mountTo}`, color1.cyan);
	await exec('wsl', ['wslpath', '-w', mountTo]);


	echo(`[.] setup workspace dir on usb disk: ${usbWorkspace}`);
	if (!fs.existsSync(usbWorkspace))
		fs.mkdirSync(usbWorkspace);

	echo(`[.] test: git init on ${insertedUSB}`, color1.cyan);
	await vitalExec(git, ['init'], { cwd: usbWorkspace, echo: true });
	assert(/Initialized empty Git repository/i.test(last.stdout)
		|| /Reinitialized existing/i.test(last.stdout), 'init git repo success');


	echo(`[.] test: git rev-parse --show-toplevel on ${insertedUSB}`, color1.cyan);
	await vitalExec(git, ['rev-parse', '--show-toplevel'], { cwd: usbWorkspace, echo: true });
	assert(last.stdout.indexOf(usbWorkspace) >= 0, 'git top level is workspace');

	echo(`[.] test: git add file on ${insertedUSB}`, color1.cyan);
	const filePath3 = path.join(usbWorkspace, Date.now() + '.txt');
	fs.writeFileSync(filePath3, '# Just Test');
	await vitalExec(git, ['add', '-v', filePath3], { cwd: usbWorkspace });
	assert(last.stdout.indexOf(path.basename(filePath3)) >= 0, 'add success');

	echo(`[.] test: git commit on ${insertedUSB}`, color1.cyan);
	const commitMsg = new Date().toLocaleString();
	await vitalExec(git, ['commit', '-m', commitMsg], { cwd: usbWorkspace });
	assert(last.stdout.indexOf(commitMsg) >= 0, 'commit success (commit message)');


	echo(`[.] sudo umount -f ${mountTo}`, color1.cyan);
	await vitalExec('wsl', ['sudo', 'umount', mountTo]);
	mountedUSB = '';
	echo(`[~] please delete tmp directory manually: ${usbWorkspace}`, color1.yellow);




	async function listWslDrvFs() {
		await vitalExec('wsl', ['mount', '-t', 'drvfs']);
		const REGEXP = /^(\w):\s+on\s+(.+)\s+type\s+drvfs/;
		const drvs = last.stdout.split(/[\r\n]+/).filter(it => it);
		assert(drvs.length > 0, 'drive list is not empty');
		drvs.forEach((drv, i) =>
			assert(REGEXP.test(drv), `format of drive list item ${i} should be valid`));
		return drvs.map(it => it.match(REGEXP)).map(it => ({ drv: it[1], path: it[2] }));
	}
	async function listWindowsDrv() {
		await vitalExec('wmic', ['logicaldisk', 'get', 'caption'], { echo: false });
		return last.stdout.split(/[\r\n]+/)
			.filter((it, i) => it && i > 1)
			.map(it => it.trim())
			.filter(it => it);
	}
}

async function prepare() {
	if (os.platform() !== 'win32')
		fatal(`this script is used for win32! (current platform: ${os.platform()})`);
	if (workspace.indexOf('\'') >= 0)
		fatal(`workspace path include invalid char: ' (${workspace})`);

	echo(`[.] clean and setup workspace: ${workspace}`);
	if (fs.existsSync(workspace))
		await vitalExec(`cmd`, [`/c`, `rmdir`, `/s`, `/q`, workspace]);
	fs.mkdirSync(workspace);
}

async function done() {
	echo(`[.] clean workspace`);
	await vitalExec(`cmd`, [`/c`, `rmdir`, `/s`, `/q`, workspace]);

	echo(`[+] test done!`, color1.green);
}

// ==========================================
// ==========================================
// ==========================================

/**
 * @param {string} command
 * @param {string[]} [args]
 * @param {childProcess.SpawnOptions&{echo?:boolean}} [options]
 */
async function vitalExec(command, args, options) {
	const result = await exec(command, args, options);
	if (result.code !== 0)
		fatal(`last command exit with code ${result.code} (${command} ${args.join(' ')})`);
	return result;
}

/**
 * @param {string} command
 * @param {string[]} [args]
 * @param {childProcess.SpawnOptions&{echo?:boolean}} [options]
 */
function exec(command, args, options) {
	let echo = (options && options.echo === false) ? false : true;
	return new Promise((resolve, reject) => {
		const out = { stdout: [], stderr: [] };
		const p = childProcess.spawn(command, args, options);
		p.stdout.setEncoding('utf8');
		p.stderr.setEncoding('utf8');
		p.stdout.on('data', pipe.bind(null, 'stdout'));
		p.stderr.on('data', pipe.bind(null, 'stderr'));
		p.on('error', end);
		p.on('exit', end.bind(null, null));
		p.on('close', end.bind(null, null));
		function end(err, code, signal) {
			try { p.kill(); } catch (err) { }
			if (err)
				return reject(err);
			resolve(last = {
				code, signal,
				stdout: out.stdout.join(''),
				stderr: out.stderr.join(''),
			});
		}
		function pipe(outType, data) {
			if (echo) process[outType].write(data.replace(/([^\r])\n/g, '$1\r\n'));
			out[outType].push(data);
		}
	});
}


function fatal(msg) {
	if (mountedUSB)
		echo(`Please umount your drive in WSL manually! (sudo umount ${mountedUSB})`, color1.yellow);
	echoErr(`fatal: ${msg.stack || msg}`); process.exit(1);
}
function assert(ok, msg) { echo(`    - assert: ${msg}`, `${color1.grey}`); nodeAssert(ok); }
function echo(msg, color = '') { process.stdout.write(`${color}${msg}${color1.reset}\n`); }
function echoErr(msg) { process.stderr.write(`${color2.red}${msg}${color2.reset}\n`); }
function getColor(stream) {
	const ok = stream && stream.isTTY;
	return new Proxy({
		red: '\u001b[31m',
		green: '\u001b[32m',
		yellow: '\u001b[33m',
		cyan: '\u001b[36m',
		reset: '\u001b[0m',
		bold: '\u001b[1m',
		grey: '\u001b[90m',
	}, { get: (obj, name, r) => ok ? obj[name] : '' });
}
