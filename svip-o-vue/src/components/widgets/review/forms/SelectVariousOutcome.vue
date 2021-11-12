<template>
    <b-form-select v-model="selection" class="form-control">
        <template v-for="(effect) in effects">
            <option :key="effect.id">{{ effect }}</option>
        </template>
    </b-form-select>
</template>

<script>
export default {
    name: "SelectVariousOutcome",
    props: [
        'value',
        'evidenceType'
    ],
    data() {
        return {
            effects: [],
            options: {
                "Predictive / Therapeutic": {
                    "effect": [
                        "Sensitive (in vitro)",
                        "Responsive",
                        "Resistant (in vitro)",
                        "Reduced sensitivity",
                        "Not responsive",
                        "Adverse response",
                        "Other"
                    ],
                    "tier_criteria": [
                        "FDA/EMA/Swissmedic approved therapy (Tier IA)",
                        "Therapy included in Professional Guidelines such as NCCN or CAP (Tier IA)",
                        "Well-powered studies with consensus from experts in the field (Tier IB)",
                        "FDA/EMA/Swissmedic approved therapy for a different tumor type (Tier IIC)",
                        "Small published studies with some consensus (Tier IIC)",
                        "Population study (Tier IID)",
                        "Clinical trial (Tier IID)",
                        "Pre-clinical trial (Tier IID)",
                        "Case reports (Tier IID)",
                        "No convincing published evidence of drugs effect (Tier III)",
                        "Reported evidence supportive of benign/likely benign effect (Tier IV)",
                        "Other criteria"
                    ]
                },
                "Prognostic": {
                    "effect": [
                        "Good outcome",
                        "Poor outcome",
                        "Intermediate",
                        "Not associated with prognosis"
                    ],
                    "tier_criteria": [
                        "Included in Professional Guidelines (Tier IA)",
                        "Well-powered studies with consensus from experts in the field (Tier IB)",
                        "Small published studies with some consensus (Tier IIC)",
                        "Population study (Tier IID)",
                        "Clinical trial (Tier IID)",
                        "Pre-clinical trial (Tier IID)",
                        "Case reports (Tier IID)",
                        "No convincing published evidence of drugs effect (Tier III)",
                        "Reported evidence supportive of benign/likely benign effect (Tier IV)",
                        "Other criteria"
                    ]
                },
                "Diagnostic": {
                    "effect": [
                        "Associated with diagnosis",
                        "Not associated with diagnosis",
                        "Other"
                    ],
                    "tier_criteria": [
                        "Included in Professional Guidelines (Tier IA)",
                        "Well-powered studies with consensus from experts in the field (Tier IB)",
                        "Small published studies with some consensus (Tier IIC)",
                        "Population study (Tier IID)",
                        "Clinical trial (Tier IID)",
                        "Pre-clinical trial (Tier IID)",
                        "Case reports (Tier IID)",
                        "No convincing published evidence of drugs effect (Tier III)",
                        "Reported evidence supportive of benign/likely benign effect (Tier IV)",
                        "Other criteria"
                    ]
                },
                "Variant identification": {
                    "effect": [
                        "Unknown"
                    ],
                    "tier_criteria": [
                        "None"
                    ]
                },
                "Function": {
                    "effect": [
                        "Gain of function",
                        "Loss of function",
                        "Neomorphic",
                        "Unaltered function",
                        "Dominant negative"
                    ],
                    "tier_criteria": [
                        "Well-established in vitro study",
                        "Well-established in vivo study",
                        "Prediction",
                        "Author statement",
                        "Other criteria"
                    ]
                },
                "Subcellular location": {
                    "effect": [
                        "Loss of physiological location",
                        "Decreased physiological location",
                        "Increased physiological location",
                        "New location",
                        "Unaltered location",
                        "Other"
                    ],
                    "tier_criteria": [
                        "Well-established in vitro study",
                        "Well-established in vivo study",
                        "Prediction",
                        "Author statement",
                        "Other criteria"
                    ]
                },
                "Interaction": {
                    "effect": [
                        "Loss of interaction with known partner(s)",
                        "Decreased interaction with known partner(s)",
                        "Increased interaction with known partner(s)",
                        "New interaction partner(s)",
                        "Other"
                    ],
                    "tier_criteria": [
                        "Well-established in vitro study",
                        "Well-established in vivo study",
                        "Prediction",
                        "Author statement",
                        "Other criteria"
                    ]
                },
                "Expression": {
                    "effect": [
                        "Loss of expression",
                        "Decreased expression",
                        "Increased expression",
                        "Misexpression",
                        "Other"
                    ],
                    "tier_criteria": [
                        "Well-established in vitro study",
                        "Well-established in vivo study",
                        "Author statement",
                        "Other criteria"
                    ]
                },
                "Response to drug": {
                    "effect": [
                        "Loss of drug response",
                        "Decreased drug response",
                        "Increased drug response",
                        "Newly acquired drug response",
                        "Other"
                    ],
                    "tier_criteria": [
                        "Well-established in vitro study",
                        "Well-established in vivo study",
                        "Prediction",
                        "Author statement",
                        "Other criteria"
                    ]
                },
            }
        }
    },
    created() {
        this.effects = this.options[this.evidenceType]['effect']
    },
    computed: {
        selection: {
            get() {
                return this.value
            },
            set(value) {
                this.$emit('input', value)
            },
        }
    },
}
</script>

<style scoped>

</style>
