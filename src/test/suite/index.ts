import * as path from 'path';
import * as Mocha from 'mocha';
import * as glob from 'glob';
import * as inspector from 'inspector';
import * as fs from 'fs';

export function run(): Promise<void> {
	// Create the mocha test
	const mocha = new Mocha({
		ui: 'tdd', 
		timeout: '10s',
		color: true
	});

	const testsRoot = path.resolve(__dirname, '..');

	return new Promise((c, e) => {
		glob('**/**.test.js', { cwd: testsRoot }, (err, files) => {
			if (err) {
				return e(err);
			}

			// Add files to the test suite
			files.forEach(f => mocha.addFile(path.resolve(testsRoot, f)));

			try {
				// Run the mocha test
				mocha.run(failures => {
					if (failures > 0) {
						e(new Error(`${failures} tests failed.`));
					} else {
						c();
					}
				});
			} catch (err) {
				console.error(err);
				e(err);
			}
		});
	});
}

export const profile = (name: string, func: () => void) => () => {
	const session = new inspector.Session();
	session.connect();
	session.post('Profiler.enable', () => {
		session.post('Profiler.start', () => {
			func();
			session.post('Profiler.stop', (err, { profile }) => {
				if(!err)
					fs.writeFileSync(path.join('profile', `${name}.cpuprofile`), JSON.stringify(profile));
			});
		});
	});
};
