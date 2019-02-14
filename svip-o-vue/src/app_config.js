/* globals process */
// export const serverURL = "https://svip-dev.nexus.ethz.ch/api/v1/";
// export const serverURL = 'http://localhost:8085/api/v1/'
export const serverURL = process.env.API_URL;

export const siteTitle = 'SVIP-O'

export const loginType = 'google'

export const getHeader = function () {
	const headers = {
		'Accept': 'application/json'
		// 'Authorization':'Bearer' + tokenData.access_token
	}
	return headers
}
