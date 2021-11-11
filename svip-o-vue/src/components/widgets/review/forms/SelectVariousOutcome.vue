<template>
    <b-form-select v-model="selection" class="form-control">
        <option>Associated with diagnosis</option>
        <option>Not associated with diagnosis</option>
        <option>Other</option>
    </b-form-select>
</template>

<script>
export default {
    name: "SelectDiagnosticOutcome",
    props: ['value'],
    data() {
        return { 
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
                }
            }
        }
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
    }
}
</script>

<style scoped>

</style>
