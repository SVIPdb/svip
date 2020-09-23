import * as NProgress from "nprogress";

import ulog from 'ulog';

const log = ulog('Support:progress');

// the duration between one request ending and another starting which should be considered part of the same session
const CATCHUP_DURATION = 600;

/**
 * Wraps NProgress object and counts calls to start() and done(), allowing us to display the progress bar as long
 * as there are inflight requsts.
 *
 * Also provides a short buffer after ending, defined by CATCHUP_DURATION ms; if a new request comes in within
 * CATCHUP_DURATION ms of the last one ending, the progress bar will remain displayed rather than disappearing and
 * reappearing.
 * @param options the options object that NProgress takes, see https://github.com/rstacruz/nprogress#configuration
 * @return {{start: start, done: done}}
 */
export default (options) => {
    const manager = NProgress.configure(options);
    let inflight = 0;

    return {
        start: (ctx) => {
            if (inflight > 0) {
                manager.inc();
            }
            else {
                manager.start();
            }

            inflight += 1;

            log.debug(`start(${ctx ? ctx : ''}): Inflight: ${inflight}`);
        },
        done: (ctx) => {
            inflight -= 1;

            log.debug(`done(${ctx ? ctx : ''}): Inflight: ${inflight}`);

            if (inflight < 0) {
                log.info("Inflight became less than 0!: ", inflight);
            }

            if (inflight <= 0) {
                // buffer the ending of the progress bar so we don't flicker
                // if inflight transitions between 1 and 0 quickly
                setTimeout(() => {
                    if (inflight <= 0) {
                        manager.done();
                    }
                }, CATCHUP_DURATION);
            }
        }
    }
}
