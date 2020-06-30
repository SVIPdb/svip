import Vue from "vue";
import Router from "vue-router";
import Home from "@/components/views/Home";
import ViewGene from "@/components/views/ViewGene";
import ViewVariant from "@/components/views/ViewVariant";
import Login from "@/components/views/user/Login";
import UserInfo from "@/components/views/user/UserInfo";
import store from '@/store';
import { TokenErrors } from "@/store/modules/users";
import PageNotFound from "@/components/views/PageNotFound";
import Help from "@/components/views/Help";
import Statistics from "@/components/views/Statistics";

import CurationDashboard from "@/components/views/curation/CurationDashboard";
import AnnotateVariant from "@/components/views/curation/AnnotateVariant";
import AddEvidence from "@/components/views/curation/AddEvidence";
import DebugPage from "@/components/views/DebugPage";
import { checkInRole } from "@/directives/access";

import Releases from "@/components/views/Releases";
import About from "@/components/views/About";

import ulog from 'ulog';

const log = ulog('Router:index');

Vue.use(Router);

/*
function remapGeneSymbol(to, from, next) {
    // remaps to.params.gene_id to an actual ID if it's non-numeric (e.g., "BRAF")
    // FIXME: we should just commit to using gene/variant symbols in URLs rather than supporting both IDs and symbols

    if (Number.isNaN(to.params.gene_id)) {
        // map gene_symbol to gene_id
        HTTP.get(`/genes?symbol=${to.params.gene_id}`).then((response) => {
            to.params.gene_id = response.data.results[0].id;
            next();
        })
    }
    else {
        next();
    }
}
*/

const router = new Router({
    mode: "history",
    routes: [
        {
            path: "/gene/:gene_id",
            name: "gene",
            component: ViewGene,
            // beforeEnter: remapGeneSymbol,
            meta: {
                title: (to) => `SVIP-O: Gene ${to.params.gene_id}`
            }
        },
        {
            path: "/gene/:gene_id/variant/:variant_id",
            name: "variant",
            component: ViewVariant,
            // beforeEnter: remapGeneSymbol,
            meta: { title: 'SVIP-O: Details' }
        },

        {
            path: "/help",
            name: "help",
            component: Help,
            meta: { title: 'SVIP-O: Help' }
        },

        {
            path: "/about",
            name: "about",
            component: About,
            meta: { title: 'SVIP-O: About' }
        },

        {
            path: "/statistics",
            name: "statistics",
            component: Statistics,
            meta: { title: 'SVIP-O: Stats' }
        },

        {
            path: "/releases",
            name: "releases",
            component: Releases,
            meta: { title: 'SVIP-O: Releases' }
        },

        {
            path: "/login",
            name: "login",
            component: Login,
            props: true,
            meta: { title: 'SVIP-O: Login' }
        },
        {
            path: "/user-info",
            name: "user-info",
            component: UserInfo,
            meta: { title: 'SVIP-O: Your Profile' }
        },
        {
            path: "/curation/dashboard",
            name: "curation-dashboard",
            component: CurationDashboard,
            meta: {
                title: 'SVIP-O: Dashboard',
                requiresAuth: true, roles: ['curators', 'reviewers']
            }
        },
        {
            path: "/curation/gene/:gene_id/variant/:variant_id",
            name: "annotate-variant",
            component: AnnotateVariant,
            // beforeEnter: remapGeneSymbol,
            meta: {
                title: 'SVIP-O: Curate',
                requiresAuth: true, roles: ['curators', 'reviewers']
            }
        },
        {
            path: "/curation/gene/:gene_id/variant/:variant_id/entry/:action",
            name: "add-evidence",
            component: AddEvidence,
            // beforeEnter: remapGeneSymbol,
            meta: {
                title: 'SVIP-O: Edit Curation',
                requiresAuth: true, roles: ['curators', 'reviewers']
            }
        },
        {
            path: "/debug",
            name: "debug",
            component: DebugPage
        },
        {
            path: "/",
            name: "home",
            component: Home
        },

        { path: '*', name: 'not-found', component: PageNotFound }
    ]
});

router.beforeEach((to, from, next) => {
    if (to.matched.some(record => record.meta.requiresAuth)) {
        // only check credentials if the route includes authorized content; if not, we'll get rejected if we have invalid creds even for public routes
        // (we'd probably do that by adding a 'requiresAuth' and/or 'groups' fields to the route definitions)

        const possibleRoles = to.matched.reduce((acc, record) => {
            return record.meta.roles ? acc.concat(record.meta.roles) : acc;
        }, []);

        store.dispatch("checkCredentials").then((result) => {
            if (!result.valid && (result.reason === TokenErrors.EXPIRED || result.reason === TokenErrors.REFRESH_EXPIRED) && to.name !== "login") {
                // if our token's expired, go get a new one from the login page,
                // remembering where we eventually want to go to as well
                next({ name: 'login', params: { default_error_msg: "Token expired, please log in again", nextRoute: to.path } });
            }
            else if (possibleRoles && !possibleRoles.some(x => checkInRole(x))) {
                log.warn("Roles check failed!");
                next({ name: 'login', params: {
                    default_error_msg: `You don't have access to that resource (required role(s): ${possibleRoles.join(", ")}).`,
                    nextRoute: to.path
                }});
            }
            else {
                next();
            }
        });
    }
    else {
        next(); // just let them proceed
    }
});

export default router;
