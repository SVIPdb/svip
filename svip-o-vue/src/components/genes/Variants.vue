<template>
	<div class="card card-default">
		<div class="card-header">
			<div class="card-title">
				List of variants....
			</div>
		</div>
		<div class="card-body">
			<p class="text-center"><i>something interesting here...</i></p>
		</div>
	</div>
</template>

<script>
import {mapGetters} from "vuex";

export default {
	data() {
		return {};
	},
	computed: {
		...mapGetters({
			user: "currentUser"
		})
	},
	components: {
		// filesTable
	},
	filters: {},
	props: ["gene"],
	created() {
	},
	methods: {}
};
</script>

<style></style>
