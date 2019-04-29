<template>
		<div class="trunk">
			<b-form>
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
export default {
  name: "Login",
	data() {
  	return {
  		username: '',
			password: ''
		}
	}
}
</script>

<style scoped>
.trunk {
	width: 400px;
	margin: 25em auto;
}
</style>
