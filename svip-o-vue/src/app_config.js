/* globals process */
// export const serverURL = "https://svip-dev.nexus.ethz.ch/api/v1/";
// export const serverURL = 'http://localhost:8085/api/v1/'
export const serverURL = process.env.VUE_APP_API_URL;

export const appVersion = process.env.VUE_APP_VERSION;
export const releaseName = process.env.VUE_APP_RELEASE_NAME;

export const siteTitle = "SVIP-O";

export const loginType = "google";

export const getHeader = function () {
	const headers = {
		Accept: "application/json"
		// 'Authorization':'Bearer' + tokenData.access_token
	};
	return headers;
};
