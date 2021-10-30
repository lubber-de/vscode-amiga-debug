import * as fs from 'fs';
import * as vscode from 'vscode';
import * as path from 'path';
import * as cp from 'child_process';
import * as os from 'os';
import { bundlePage } from './profile_editor_provider';
import { UssFile } from './backend/savestate';
import { ProfileFile, Profiler } from './backend/profile';
import { MI2 } from './backend/mi2';

class SavestateDocument implements vscode.CustomDocument {
	constructor(public uri: vscode.Uri) {
		this.ussPath = this.uri.fsPath;
	}

	public async load() {
		try {
			const ussFile = new UssFile(this.ussPath);
			this.content = JSON.stringify(ussFile);
		} catch(err) {
			this.content = `Error: ${err}`;
		}
	}

	public ussPath: string;
	public content: string;

	public dispose() {
		this.stop();
	}

	private winuae: cp.ChildProcess;
	private gdb: cp.ChildProcess;
	private miDebugger: MI2;
	private currentThreadId: number = 1;
	private ready: boolean = false;

	public async start(onReady: () => void) {
		if(this.winuae || this.gdb || this.miDebugger)
			return;

		// write config
		const binPath = await vscode.commands.executeCommand("amiga.bin-path") as string;
		const configPath = path.join(binPath, "savestate.uae");
		const gdbPath = path.join(binPath, "opt/bin/m68k-amiga-elf-gdb.exe");
		const gdbArgs = ['-q', '--interpreter=mi2'];
		const config = [];
		config['use_gui'] = 'no';
		config['win32.start_not_captured'] = 'yes';
		config['win32.nonotificationicon'] = 'yes'; // tray icons remain after killing WinUAE, so just disable altogether
		config['debugging_features'] = 'gdbserver';
		config['debugging_trigger'] = '';
		config['statefile'] = this.ussPath;

		// copy from amigaDebug.cpp
		const stringifyCfg = (cfg) => {
			let out: string = "";
			for (const [key, value] of Object.entries(cfg)) {
				out += key + '=' + cfg[key] + '\r\n';
			}
			return out;
		};

		try {
			fs.writeFileSync(configPath, stringifyCfg(config));
		} catch (e) {
			vscode.window.showErrorMessage(`Unable to write WinUAE config ${configPath}.`);
			return;
		}

		const winuaePath = path.join(binPath, "winuae-gdb.exe");
		const winuaeArgs = ['-portable', '-f', configPath];

		// launch WinUAE
		this.winuae = cp.spawn(winuaePath, winuaeArgs, { stdio: 'ignore', detached: true });

		// init debugger
		this.miDebugger = new MI2(gdbPath, gdbArgs);
		this.miDebugger.procEnv = { XDG_CACHE_HOME: gdbPath }; // to shut up GDB about index cache directory
		//initDebugger();
		//miDebugger.on('launcherror', this.launchErrorEvent.bind(this));
		//miDebugger.on('quit', this.quitEvent.bind(this));
		//miDebugger.on('exited-normally', this.quitEvent.bind(this));
		//miDebugger.on('stopped', this.stopEvent.bind(this));
		//miDebugger.on('msg', this.msgEvent.bind(this));
		//miDebugger.on('breakpoint', this.breakpointEvent.bind(this));
		//miDebugger.on('watchpoint', this.watchpointEvent.bind(this));
		//miDebugger.on('step-end', this.stepEndEvent.bind(this));
		//miDebugger.on('step-out-end', this.stepEndEvent.bind(this));
		//miDebugger.on('signal-stop', this.signalStopEvent.bind(this));
		//miDebugger.on('running', this.runningEvent.bind(this));
		//miDebugger.on('thread-created', this.threadCreatedEvent.bind(this));
		//miDebugger.on('thread-exited', this.threadExitedEvent.bind(this));
		//miDebugger.on('thread-selected', this.threadSelectedEvent.bind(this));
		this.miDebugger.trace = true; // DEBUG only

		this.miDebugger.once('debug-ready', async () => {
			console.log("debug-ready");
			await this.miDebugger.sendCommand('exec-continue');
			this.gdb = this.miDebugger.process;
			this.ready = true;
			onReady();
		});
		const commands = [
			'enable-pretty-printing',
			//'interpreter-exec console "set debug remote 1"',
			'interpreter-exec console "target remote localhost:2345"',
		];

		// launch GDB and connect to WinUAE
		this.miDebugger.connect(".", "", commands).catch((err) => {
			vscode.window.showErrorMessage(`Failed to launch GDB: ${err.toString()}`);
		});
	}

	public async profile(frames: number) {
		if(!this.ready)
			return;

		this.miDebugger.once("signal-stop", async () => {
			const date = new Date();
			const dateString = date.getFullYear().toString() + "." + (date.getMonth() + 1).toString().padStart(2, '0') + "." + date.getDate().toString().padStart(2, '0') + "-" +
				date.getHours().toString().padStart(2, '0') + "." + date.getMinutes().toString().padStart(2, '0') + "." + date.getSeconds().toString().padStart(2, '0');
			const tmp = path.join(os.tmpdir(), path.basename(this.ussPath) + '-' + dateString);
			// path to profile file
			const tmpQuoted = tmp.replace(/\\/g, '\\\\');
			await this.miDebugger.sendUserInput(`monitor profile ${frames} "" "${tmpQuoted}"`);
	
			// read profile file
			const profileArchive = new ProfileFile(tmp);
			fs.unlinkSync(tmp); // !DEBUG
	
			// generate output
			const profiler = new Profiler(null, null);
			//progress.report({ message: 'Writing profile...'});
			fs.writeFileSync(tmp + ".amigaprofile", profiler.profileSavestate(profileArchive));
	
			// open output
			vscode.commands.executeCommand("vscode.open", vscode.Uri.file(tmp + ".amigaprofile"), { preview: false } as vscode.TextDocumentShowOptions);
			this.miDebugger.continue(this.currentThreadId);
		});
		await this.miDebugger.interrupt(this.currentThreadId);
	}

	public async stop() {
		if(!this.ready)
			return;

		// disconnect debugger / kill WinUAE
		this.miDebugger.stop();
		this.winuae.kill();

		this.ready = false;
		this.winuae = undefined;
		this.miDebugger = undefined;
		this.gdb = undefined;
	}
}

export class SavestateEditorProvider implements vscode.CustomReadonlyEditorProvider<SavestateDocument> {
	constructor(private readonly context: vscode.ExtensionContext) {
	}

	public async openCustomDocument(uri: vscode.Uri, openContext: vscode.CustomDocumentOpenContext, token: vscode.CancellationToken): Promise<SavestateDocument> {
		const doc = new SavestateDocument(uri);
		await doc.load();
		return doc;
	}

	private async updateWebview(document: SavestateDocument, webview: vscode.Webview) {
		const html = await bundlePage(webview, path.join(this.context.extensionPath, 'dist'), { 
			SAVESTATE: document.content
		});
		webview.html = html;
	}

	public async resolveCustomEditor(document: SavestateDocument, webviewPanel: vscode.WebviewPanel, token: vscode.CancellationToken): Promise<void> {
		// Setup initial content for the webview
		webviewPanel.webview.options = {
			enableScripts: true,
			localResourceRoots: [ vscode.Uri.file(path.dirname(document.uri.fsPath)) ]
		};
		this.updateWebview(document, webviewPanel.webview);

		webviewPanel.webview.onDidReceiveMessage(async (message) => {
			switch (message.type) {
			case 'savestateStart':
				document.start(() => { webviewPanel.webview.postMessage({ type: 'status', body: { running: true }}); });
				break;
			case 'savestateStop':
				document.stop();
				webviewPanel.webview.postMessage({ type: 'status', body: { running: false }});
				break;
			case 'savestateProfile':
				document.profile(message.frames);
				break;
			}
		});
	}
}
