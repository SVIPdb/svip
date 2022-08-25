<template>
	<b-form-select v-model="selection" class="form-control">
		<template v-for="opt in selectables">
			<option :key="opt.id">{{ opt }}</option>
		</template>
	</b-form-select>
</template>

<script>
export default {
	name: 'SelectVariousOutcome',
	props: ['value', 'evidenceType', 'fieldType'],
	data() {
		return {
			selectables: [],
			options: {
				'Predictive / Therapeutic': {
					effect: [
						'Sensitive (in vitro)',
						'Responsive',
						'Resistant (in vitro)',
						'Reduced sensitivity',
						'Not responsive',
						'Adverse response',
						'Other',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'FDA/EMA/Swissmedic approved therapy (Tier IA)',
						'Therapy included in Professional Guidelines such as NCCN or CAP (Tier IA)',
						'Well-powered studies with consensus from experts in the field (Tier IB)',
						'FDA/EMA/Swissmedic approved therapy for a different tumor type (Tier IIC)',
						'Small published studies with some consensus (Tier IIC)',
						'Population study (Tier IID)',
						'Clinical trial (Tier IID)',
						'Pre-clinical trial (Tier IID)',
						'Case reports (Tier IID)',
						'No convincing published evidence of drugs effect (Tier III)',
						'Reported evidence supportive of benign/likely benign effect (Tier IV)',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Prognostic': {
					effect: [
						'Good outcome',
						'Poor outcome',
						'Intermediate',
						'Not associated with prognosis',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Included in Professional Guidelines (Tier IA)',
						'Well-powered studies with consensus from experts in the field (Tier IB)',
						'Small published studies with some consensus (Tier IIC)',
						'Population study (Tier IID)',
						'Clinical trial (Tier IID)',
						'Pre-clinical trial (Tier IID)',
						'Case reports (Tier IID)',
						'No convincing published evidence of drugs effect (Tier III)',
						'Reported evidence supportive of benign/likely benign effect (Tier IV)',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Diagnostic': {
					effect: [
						'Associated with diagnosis',
						'Not associated with diagnosis',
						'Other',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Included in Professional Guidelines (Tier IA)',
						'Well-powered studies with consensus from experts in the field (Tier IB)',
						'Small published studies with some consensus (Tier IIC)',
						'Population study (Tier IID)',
						'Clinical trial (Tier IID)',
						'Pre-clinical trial (Tier IID)',
						'Case reports (Tier IID)',
						'No convincing published evidence of drugs effect (Tier III)',
						'Reported evidence supportive of benign/likely benign effect (Tier IV)',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Variant identification': {
					effect: ['Unknown'],
					tier_criteria: ['None'],
				},
				'Function': {
					effect: [
						'Gain of function',
						'Loss of function',
						'Neomorphic',
						'Unaltered function',
						'Dominant negative',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Well-established in vitro study',
						'Well-established in vivo study',
						'Prediction',
						'Author statement',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Subcellular location': {
					effect: [
						'Loss of physiological location',
						'Decreased physiological location',
						'Increased physiological location',
						'New location',
						'Unaltered location',
						'Other',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Well-established in vitro study',
						'Well-established in vivo study',
						'Prediction',
						'Author statement',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Interaction': {
					effect: [
						'Loss of interaction with known partner(s)',
						'Decreased interaction with known partner(s)',
						'Increased interaction with known partner(s)',
						'New interaction partner(s)',
						'Other',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Well-established in vitro study',
						'Well-established in vivo study',
						'Prediction',
						'Author statement',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Expression': {
					effect: [
						'Loss of expression',
						'Decreased expression',
						'Increased expression',
						'Misexpression',
						'Other',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Well-established in vitro study',
						'Well-established in vivo study',
						'Author statement',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
				'Response to drug': {
					effect: [
						'Loss of drug response',
						'Decreased drug response',
						'Increased drug response',
						'Newly acquired drug response',
						'Other',
						'Conflicting Evidences',
					],
					tier_criteria: [
						'Well-established in vitro study',
						'Well-established in vivo study',
						'Prediction',
						'Author statement',
						'Other criteria',
						'Conflicting Evidences',
					],
				},
			},
		};
	},
	created() {
		if (this.fieldType === 'effect') {
			this.selectables = this.options[this.evidenceType]['effect'];
		} else {
			this.selectables = this.options[this.evidenceType]['tier_criteria'];
		}
	},
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
