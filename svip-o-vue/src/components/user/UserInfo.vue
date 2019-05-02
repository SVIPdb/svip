<template>
	<div class="trunk">
		<div v-if="user">
			<h3>Information for "{{ user.username }}"</h3>

			<div class="user-info">
				<dl>
					<dt>Username</dt>
					<dd>{{ user.username }}</dd>

					<dt>Groups</dt>
					<dd>
						<span v-for="(group, idx) in user.groups" :key="group"><span v-if="idx !== 0">, </span>{{ group }}</span>
					</dd>
				</dl>
			</div>
		</div>

		<div v-else class="not-logged-in">
			You must be logged in to view your user information.
			<hr style="width: 75%" />
			<router-link to="login">log in</router-link>
		</div>
	</div>
</template>

<script>
import {mapGetters} from "vuex";

export default {
	name: "UserInfo",
	computed: {
		...mapGetters({
			user: "currentUser"
		})
	}
}
</script>

<style scoped>
.trunk { width: 600px; }
.user-info {
	margin-top: 1em;
	border: solid 1px #ccc;
	border-radius: 5px;
	padding: 20px;
}

dl {
	display: flex;
	flex-wrap: wrap;
	margin: 0;
}
dt {
	width: 25%;
	text-align: right;
}
dt::after { content: ': '; }
dd {
	padding-left: 10px;
	width: 75%;
}

.not-logged-in {
	color: #777;
	font-size: 20px; text-align: center; font-style: oblique;
}
</style>
