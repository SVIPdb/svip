import axios from "axios";
import { serverURL } from "@/app_config";
import debounce from "lodash/debounce";
import createAuthRefreshInterceptor from "axios-auth-refresh";
import { USING_JWT_COOKIE } from "@/store/modules/users";
import store from "@/store";
import router from "@/router";
import vueInstance from "@/main";
import ulog from "ulog";
import { np_manager } from "@/App";

const log = ulog("Support:HTTP");

export var HTTProot = axios.create({
    baseURL: serverURL.replace("/v1", ""),
    withCredentials: USING_JWT_COOKIE,
});
export var HTTP = axios.create({
    baseURL: serverURL,
    withCredentials: USING_JWT_COOKIE,
});

// shows only one auth warning when the warning is triggered repeatedly within a short timeframe
// (e.g., if we havemultiple failing auth requests)
const debouncedAuthWarn = debounce((x) => {
    vueInstance.$snotify.warning(x);
}, 300);

createAuthRefreshInterceptor(
    HTTP,
    (failedRequest) => {
        const jwtRefresh = store.state.users.currentRefreshJWT;

        log.debug("Request failed, attempting refresh w/token: ", jwtRefresh);

        return HTTProot.post(`token/refresh/`, { refresh: jwtRefresh })
            .then((response) => {
                // replace the existing token with the new one if we succeed
                const { access } = response.data;
                store.commit("LOGIN", { access });
                // and annotate the failed request with a new access header, which we'll use to repeat the request
                failedRequest.response.config.headers["Authorization"] =
                    "Bearer " + access;

                // console.log("Successfully refreshed, repeating request");

                return Promise.resolve();
            })
            .catch((err) => {
                log.warn(err);

                debouncedAuthWarn(`Authentication expired!`);
                if (router.currentRoute.name !== "login") {
                    router.push({
                        name: "login",
                        params: {
                            default_error_msg:
                                "Refresh token expired, please log in again",
                            nextRoute: router.currentRoute.path,
                        },
                    });
                }

                return Promise.reject();
            });
    },
    { statusCodes: [401, 403] }
);

HTTP.interceptors.request.use((request) => {
    const start = new Date();
    // update nprogress
    np_manager && np_manager.start();

    // always make sure to use the most up-to-date access token.
    // (this is especially important when using axios-auth-refresh, since it intercepts and stalls
    // requests that occur after an auth failure until the original succeeds, then allows them to proceed
    // after re-authentication has completed.)
    const access = store.state.users.currentJWT;
    if (access) {
        if (!USING_JWT_COOKIE) {
            request.headers.common["Authorization"] = "Bearer " + access;
        }
    }

    const end = new Date();
    const duration = (end - start) / 1000;
    //console.log(`request: ${duration.toFixed(1)}s`)
    return request;
});

HTTP.interceptors.response.use(
    (response) => {
        const start = new Date();
        np_manager && np_manager.done();
        const end = new Date();
        const duration = (end - start) / 1000;
        //console.log(`response: ${duration.toFixed(1)}s`)
        return response;
    },
    (err) => {
        np_manager && np_manager.done();

        // HTTP users can pass handled: true in the call to get/post to disable these messages
        // FIXME: see if we can make that part not break spec
        if (err.config.handled) {
            return;
        }

        // displays a toast when something goes wrong, but propogates the error
        // (note that HTTProot doesn't need a handler, since it does its own error reporting)
        // vueInstance.$snotify.error(err.toString().slice("Error: ".length), `Network Error`, {timeout: 3000});
        throw err;
    }
);
