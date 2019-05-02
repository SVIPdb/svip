<template>
	<div class="trunk">
		<transition name="fade">
			<div v-if="error_msg" class="errors">
				<h3>Errors:</h3>
				<div v-if="error_msg.non_field_errors && error_msg.non_field_errors.length === 1">{{ error_msg.non_field_errors[0] }}</div>
				<ul v-else>
					<li v-for="(err, idx) in error_msg.non_field_errors" :key="idx">{{ err }}</li>
				</ul>
			</div>
		</transition>

		<b-form @submit="onSubmit">
			<b-form-group label="Username">
				<b-form-input v-model="username"></b-form-input>
			</b-form-group>

			<b-form-group label="Password">
				<b-form-input v-model="password" type="password"></b-form-input>
			</b-form-group>

			<b-form-group>
				<b-button type="submit" variant="primary" class="float-right">Log In</b-button>
			</b-form-group>
		</b-form>
	</div>
</template>

<script>
import store from '@/store';

export default {
	name: "Login",
	data() {
		return {
			username: '',
			password: '',
			error_msg: null
		}
	},
	methods: {
		onSubmit(evt) {
			evt.preventDefault();
			this.error_msg = null;

			store.dispatch("login", { username: this.username, password: this.password }).then(() => {
				// we presume success if we reached this point
				this.$snotify.success(`Logged in as ${this.username}`);
				this.$router.push("/");
			}).catch((err) => {
				this.error_msg = err.response.data;
				return true;
			});
		}
	}
}
</script>

<style scoped>
.errors {
	margin-bottom: 1em;
	color: #a33;
}

/* causes the errors to animate whenever a login is attempted */
.fade-enter-active, .fade-leave-active {
	transition: opacity .5s;
}
.fade-enter, .fade-leave-to {
	opacity: 0;
}
</style>
