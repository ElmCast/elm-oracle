Elm.Native = Elm.Native || {};
Elm.Native.Path = Elm.Native.Path || {};

Elm.Native.Path.make = function(localRuntime) {
	'use strict';

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Path = localRuntime.Native.Path || {};
	if ('values' in localRuntime.Native.Path) {
		return localRuntime.Native.Path.values;
	}

	var List = Elm.Native.List.make(localRuntime);

	var path = require('path');

	function normalize(p) {
		return path.normalize(p);
	}

	function join(ps) {
		return path.join.apply(path.join, List.toArray(ps));
	}

	function resolve(ps) {
		return path.resolve.apply(path.resolve, List.toArray(ps));
	}

	function isAbsolute(p) {
		return path.isAbsolute(p);
	}

	function relative(fromP, toP) {
		return path.relative(fromP, toP);
	}

	function dirname(p) {
		return path.dirname(p);
	}

	function basename(p, ext) {
		return path.basename(p, ext);
	}

	function extname(p) {
		return path.extname(p);
	}

	return localRuntime.Native.Path.values = {
		normalize: normalize,
		join: join,
		resolve: resolve,
		isAbsolute: isAbsolute,
		relative: F2(relative),
		dirname: dirname,
		basename: F2(basename),
		extname: extname,
		sep: path.sep,
		delimiter: path.delimier,
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
