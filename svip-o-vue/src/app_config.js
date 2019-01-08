export const serverURL = "http://oncokb.org/api/v1/";

export const siteTitle = 'SVIP-O';

export const loginType = 'google';

export const getHeader = function () {
    const tokenData = JSON.parse(window.localStorage.getItem('lbUser'))
    const headers = {
        'Accept':'application/json',
        // 'Authorization':'Bearer' + tokenData.access_token
       }
       return headers
}