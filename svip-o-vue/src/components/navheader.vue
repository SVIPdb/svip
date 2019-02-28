<template>
	<!-- Navbar -->
	<b-navbar toggleable="md" type="light" variant="primary" fixed="top" class="svip-navbar">
		<b-navbar-toggle target="nav_collapse"></b-navbar-toggle>

		<b-navbar-brand href="#">
			<router-link to="/">
				<img src="../assets/SVIP_Logo_white_narrow.png" width="162" height="52" alt="SVIP-O" />
			</router-link>
		</b-navbar-brand>

		<b-collapse is-nav id="nav_collapse">
			<!-- Right aligned nav items -->
			<b-navbar-nav class="ml-auto">
				<b-navbar-nav right>
					<b-nav-item v-access="'admin'"><router-link to="/admin">Admin</router-link></b-nav-item>
					<b-nav-item v-access="'active'">Welcome {{ user.fullname }}</b-nav-item>
					<b-nav-item v-access="'active'">
						<a class="pointer" @click="logout()"><icon name="sign-out-alt"></icon></a>
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
	methods: {
		logout() {
			store.dispatch("logout").then(() => {
				Vue.prototype.$keycloak.logoutFn();
			});
		}
	}
};
</script>
