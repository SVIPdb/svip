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
import {checkInRole} from "@/directives/access";

Vue.use(Router);

const router = new Router({
    mode: "history",
    routes: [
        {
            path: "/gene/:gene_id",
            name: "gene",
            component: ViewGene
        },
        {
            path: "/gene/:gene_id/variant/:variant_id",
            name: "variant",
            component: ViewVariant
        },

        {
            path: "/help",
            name: "help",
            component: Help
        },

        {
            path: "/statistics",
            name: "statistics",
            component: Statistics
        },

        {
            path: "/login",
            name: "login",
            component: Login,
            props: true
        },
        {
            path: "/user-info",
            name: "user-info",
            component: UserInfo
        },
        {
            path: "/curation/dashboard",
            name: "curation-dashboard",
            component: CurationDashboard,
            meta: { requiresAuth: true, roles: ['curators', 'reviewers'] }
        },
        {
            path: "/curation/gene/:gene_id/variant/:variant_id/disease/:disease_id",
            name: "annotate-variant",
            component: AnnotateVariant,
            meta: { requiresAuth: true, roles: ['curators', 'reviewers'] }
        },
        {
            path: "/curation/gene/:gene_id/variant/:variant_id/disease/:disease_id/entry/:action",
            name: "add-evidence",
            component: AddEvidence,
            meta: { requiresAuth: true, roles: ['curators', 'reviewers'] }
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

        console.log("Requires auth, roles?: ", possibleRoles);

        store.dispatch("checkCredentials").then((result) => {
            if (!result.valid && (result.reason === TokenErrors.EXPIRED || result.reason === TokenErrors.REFRESH_EXPIRED) && to.name !== "login") {
                // if our token's expired, go get a new one from the login page,
                // remembering where we eventually want to go to as well
                next({ name: 'login', params: { default_error_msg: "Token expired, please log in again", nextRoute: to.path } });
            }
            else if (possibleRoles && !possibleRoles.some(x => checkInRole(x))) {
                console.log("Roles check failed!");
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
