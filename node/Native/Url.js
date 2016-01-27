Elm.Native = Elm.Native || {};
Elm.Native.Url = Elm.Native.Url || {};

Elm.Native.Url.make = function(localRuntime) {
	'use strict';

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Url = localRuntime.Native.Url || {};
	if ('values' in localRuntime.Native.Url) {
		return localRuntime.Native.Url.values;
	}

	var List = Elm.Native.List.make(localRuntime);

	var url = require('url');

	function resolve(ps) {
		var b = url.resolve.apply(url.resolve, List.toArray(ps));
		console.log(b);
		return b;
	}

	return localRuntime.Native.Url.values = {
		resolve: resolve,
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
