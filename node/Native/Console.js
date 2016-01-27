Elm.Native = Elm.Native || {};
Elm.Native.Console = Elm.Native.Console || {};

Elm.Native.Console.make = function(localRuntime) {
	'use strict';

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Console = localRuntime.Native.Console || {};
	if ('values' in localRuntime.Native.Console) {
		return localRuntime.Native.Console.values;
	}

	var NS = Elm.Native.Signal.make(localRuntime);
	var Task = Elm.Native.Task.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);

	function log(value) {
		return Task.asyncFunction(function(callback) {
			if (typeof value == "string") {
				console.log(value);
			} else {
				console.log(Utils.toString(value));
			}
			return callback(Task.succeed(Utils.Tuple0));
		});
	}

	function error(value) {
		return Task.asyncFunction(function(callback) {
			if (typeof value == "string") {
				console.error(value);
			} else {
				console.error(Utils.toString(value));
			}
			return callback(Task.succeed(Utils.Tuple0));
		});
	}

	function fatal(value) {
		return Task.asyncFunction(function(callback) {
			if (typeof value == "string") {
				console.error(value);
			} else {
				console.error(Utils.toString(value));
			}
			process.exit(1);
			return callback(Task.succeed(Utils.Tuple0));
		});
	}

	return localRuntime.Native.Console.values = {
		log: log,
		error: error,
		fatal: fatal
	};
};

(function() {
	if (typeof module == 'undefined') {
		throw new Error('You are trying to run a node Elm program in the browser!');
	}

	if (module.exports === Elm) {
		return;
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
