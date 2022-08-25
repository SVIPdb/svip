<template>
	<b-form-select v-model="selection" class="form-control">
		<option>Included in Professional Guidelines</option>
		<option>Well-powered studies with consensus from experts in the field</option>
		<option>Multiples small published studies with some consensus</option>
		<option>Clinical trial</option>
		<option>Pre-clinical trial</option>
		<option>Population study</option>
		<option>Small published study</option>
		<option>Small published studies with some consensus</option>
		<option>Case reports</option>
		<option>No convincing published evidence of drugs effect</option>
		<option>Author statement</option>
		<option>Reported evidence supportive of benign/likely benign effect</option>
		<option>Other criteria</option>
		<option>Not applicable</option>
	</b-form-select>
</template>

<script>
export default {
	name: 'SelectTier',
	props: ['value'],
	computed: {
		selection: {
			get() {
				return this.value;
			},
			set(value) {
				this.$emit('input', value);
			},
		},
	},
};
</script>

<style scoped></style>
