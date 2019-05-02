<template>
	<!-- Navbar -->
	<b-navbar toggleable="md" type="dark" variant="primary" fixed="top" class="svip-navbar">
		<b-navbar-toggle target="nav_collapse"></b-navbar-toggle>

		<b-navbar-brand href="#">
			<router-link to="/">
				<img src="../assets/logos/SVIP_Logo_white_narrow.png" width="162" height="52" alt="SVIP-O" />
			</router-link>
		</b-navbar-brand>

		<b-collapse is-nav id="nav_collapse">
			<!-- Right aligned nav items -->
			<b-navbar-nav v-if="user" class="ml-auto">
				<b-navbar-nav right>
					<b-nav-text class="login-name">logged in as <router-link to="user-info">{{ user.username }}</router-link> -</b-nav-text>
					<b-nav-item>
						<a class="pointer" @click="logout()"><icon name="sign-out-alt" /> log out</a>
					</b-nav-item>
				</b-navbar-nav>
			</b-navbar-nav>

			<b-navbar-nav v-else class="ml-auto">
				<b-navbar-nav right>
					<b-nav-item v-if="$router.currentRoute !== '/login'">
						<router-link class="pointer" :to="{name: 'login'}"><icon name="sign-in-alt" /> log in</router-link>
					</b-nav-item>
				</b-navbar-nav>

			</b-navbar-nav>
		</b-collapse>
	</b-navbar>
</template>

<script>
import {mapGetters} from "vuex";
import store from "@/store";
import Vue from "vue";

export default {
	name: "navHeader",
	computed: {
		...mapGetters({
			user: "currentUser"
		})
	},
	mounted() {
		// FIXME: this applies the user's cached login info if it exists; maybe it should be somewhere more central?
		store.dispatch("checkCredentials");
	},
	methods: {
		logout() {
			store.dispatch("logout").then(() => {
				this.$snotify.success("Logged out");
				this.$router.push("/");
				// Vue.prototype.$keycloak.logoutFn();
			});
		}
	}
};
</script>

<style scoped>
.navbar-text.login-name {
	color: #bec8d4;
}
.login-name b { color: #e6ebf2; }
</style>
