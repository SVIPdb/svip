<template>
    <!-- Navbar -->
    <b-navbar toggleable="md" type="dark" variant="primary" fixed="top" class="svip-navbar">
        <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>

        <b-navbar-brand>
            <router-link to="/">
                <img
                    src="../../assets/logos/SVIP_Logo_white_narrow.png"
                    width="162"
                    height="52"
                    alt="SVIP-O"
                />
            </router-link>
        </b-navbar-brand>

        <b-collapse is-nav id="nav_collapse">
            <b-navbar-nav>
                <b-nav-item
                    v-if="user && user.groups.indexOf('curators') != -1"
                    :to="{ name: 'curation-dashboard' }"
                >Dashboard
                </b-nav-item>
                <b-nav-item :to="'/help'">Help</b-nav-item>
                <b-nav-item :to="'/about'">About</b-nav-item>
                <b-nav-item :to="'/statistics'">Statistics</b-nav-item>
                <b-nav-item :to="'/releases'">Releases</b-nav-item>
            </b-navbar-nav>

            <!-- Right aligned nav items -->
            <b-navbar-nav class="ml-auto">
                <b-navbar-nav v-if="user" right>
                    <b-nav-text class="login-name">
                        logged in as
                        <router-link to="/user-info">{{ user.username }}</router-link>
                        -
                    </b-nav-text>
                    <b-nav-item>
                        <a class="pointer" @click="logout()">
                            <icon name="sign-out-alt"/>
                            log out
                        </a>
                    </b-nav-item>
                </b-navbar-nav>
                <b-navbar-nav v-else right>
                    <b-nav-item v-if="$router.currentRoute !== '/login'">
                        <router-link
                            class="pointer"
                            :to="{name: 'login', params: { nextRoute: whereFromHere }}"
                        >
                            <icon name="sign-in-alt"/>
                            log in
                        </router-link>
                    </b-nav-item>
                </b-navbar-nav>
            </b-navbar-nav>
        </b-collapse>

        <div class="ajax-loader-bar" style="position: relative; z-index: 1035;"></div>
    </b-navbar>
</template>

<script>
import { mapGetters } from "vuex";
import store from "@/store";

export default {
    name: "navHeader",
    computed: {
        ...mapGetters({
            user: "currentUser"
        }),
        whereFromHere() {
            // if we're at the login page, go home after logging in.
            // if we're anywhere else, return to that page after we're done
            return this.$route.path !== "/login" ? this.$route.path : "/";
        }
    },
    methods: {
        logout() {
            store.dispatch("logout").then(() => {
                this.$snotify.success("Logged out");
                // refresh the current page
                this.$router.go();
            });
        }
    }
};
</script>

<style scoped>
.navbar-text.login-name {
    color: #bec8d4;
}

.login-name b {
    color: #e6ebf2;
}

.ajax-loader-bar {
    position: absolute !important;
    pointer-events: none;
    left: 0;
    bottom: -40px;
    right: 0;
    height: 40px;
    z-index: 9999;
}
</style>
