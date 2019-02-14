/* globals process, module */
process.env.VUE_APP_VERSION = require('./package.json').version

module.exports = {
	runtimeCompiler: true,
	transpileDependencies: [
		/\bvue-awesome\b/
	]
}
