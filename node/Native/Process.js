Elm.Native = Elm.Native || {};
Elm.Native.Process = Elm.Native.Process || {};

Elm.Native.Process.make = function(localRuntime) {
	'use strict';

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Process = localRuntime.Native.Process || {};
	if ('values' in localRuntime.Native.Process) {
		return localRuntime.Native.Process.values;
	}

	var Task = Elm.Native.Task.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);
	var List = Elm.Native.List.make(localRuntime);

	var child = require('child_process');

	function exit(error) {
		return Task.asyncFunction(function(callback) {
			process.exit(error);
			return callback(Task.succeed(Utils.Tuple0));
		});
	}

	function exec(command) {
		return Task.asyncFunction(function(callback) {
			child.exec(command, function(error, stdout, stderr) {
				if (error != null) {
					callback(Task.fail('Exec: ' + error));
				} else {
					callback(Task.succeed('' + stdout));
				}
			});
		});
	}

	return localRuntime.Native.Process.values = {
		argv: List.fromArray(process.argv),
		execPath: process.execPath,
		execArgv: List.fromArray(process.execArgv),
		exec: exec,
		exit: exit,
		pid: process.pid,
		version: process.version,
	};
};

(function() {
	if (module.exports === Elm) {
		return;
	}

	if (typeof module == 'undefined') {
		throw new Error('You are trying to run a node Elm program in the browser!');
	}

	window = global;

	module.exports = Elm;
	setTimeout(function() {
		if (!module.parent) {
			if ('Main' in Elm) {
				setImmediate(Elm.worker, Elm.Main);
			} else {
				throw new Error('You are trying to run a node Elm program without a Main module.');
			}
		}
	});
})();
