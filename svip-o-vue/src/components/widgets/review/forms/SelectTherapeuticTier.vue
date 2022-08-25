<template>
	<b-form-select v-model="selection" class="form-control">
		<option>FDA/EMA/Swissmedic approved therapy</option>
		<option>Therapy included in Professional Guidelines such as NCCN or CAP</option>
		<option>Well-powered studies with consensus from experts in the field</option>
		<option>FDA/EMA/Swissmedic approved therapy for a different tumor type</option>
		<option>Small published studies with some consensus</option>
		<option>Population study</option>
		<option>Clinical trial</option>
		<option>Pre-clinical trial</option>
		<option>Case reports</option>
		<option>No convincing published evidence of drugs effect</option>
		<option>Reported evidence supportive of benign/likely benign effect</option>
		<option>Other criteria</option>
		<option>Conflicting Evidences</option>
	</b-form-select>
</template>

<script>
export default {
	name: 'SelectTherapeuticTier',
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
