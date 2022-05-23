/* globals process, module, require */
const pkg_json = require("./package.json");
// process.env.VUE_APP_VERSION = pkg_json.version;
process.env.VUE_APP_RELEASE_NAME = pkg_json.release_name;

const GitRevisionPlugin = require("git-revision-webpack-plugin");

module.exports = {
    runtimeCompiler: true,
    transpileDependencies: [/\bvue-awesome\b/],
    configureWebpack: {
        plugins: [new GitRevisionPlugin({ branch: true })],
    },
    chainWebpack: (config) => {
        config.plugins.delete("progress");
        config.plugin("define").tap((args) => {
            const gitRevisionPlugin = new GitRevisionPlugin();
            args[0]["process.env"]["VUE_APP_COMMITHASH"] = JSON.stringify(
                gitRevisionPlugin.commithash()
            );
            args[0]["process.env"]["VUE_APP_VERSION"] = JSON.stringify(
                gitRevisionPlugin.version()
            );
            args[0]["process.env"]["VUE_APP_BRANCH"] = JSON.stringify(
                gitRevisionPlugin.branch()
            );
            // args[0]['process.env']['VUE_APP_LASTCOMMITDATETIME'] = JSON.stringify(gitRevisionPlugin.lastcommitdatetime())
            return args;
        });
    },
    devServer: {
        disableHostCheck: true,
    },
};
