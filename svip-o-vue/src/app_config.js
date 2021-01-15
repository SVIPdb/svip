import yn from 'yn'

/* globals process */
// export const serverURL = "https://svip-dev.nexus.ethz.ch/api/v1/";
// export const serverURL = 'http://localhost:8085/api/v1/'
export const serverURL = process.env.VUE_APP_API_URL;
export const appVersion = process.env.VUE_APP_VERSION;
export const releaseName = process.env.VUE_APP_RELEASE_NAME;

// -----------------------------------------------------------
// --- feature flags
// -----------------------------------------------------------
export const commentsEnabled = true;
export const showHarvestRuns = yn(process.env.VUE_APP_DEBUG, { default: false }) || false;
export const loginDisabled = yn(process.env.VUE_APP_DISABLE_LOGIN, { default: false }) || false;
