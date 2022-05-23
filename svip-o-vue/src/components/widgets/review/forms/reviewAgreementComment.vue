<template>
    <b-container>
        <b-row>
            <b-col cols="4">
                <b-row class="p-2">
                    <SelectAgreement
                        v-model="review.agreement"
                        @input="change"
                    />
                </b-row>
            </b-col>

            <!--<b-col cols="2"/>-->

            <b-col cols="8">
                <b-textarea
                    :disabled="commentDisabled"
                    class="summary-box"
                    rows="3"
                    placeholder="Comment..."
                    v-model="review.comment"
                    @input="change"
                >
                </b-textarea>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import SelectAgreement from "@/components/widgets/review/forms/SelectAgreement";

export default {
    components: {
        SelectAgreement,
    },
    props: {
        value: { type: Object, required: true },
    },
    data() {
        return {
            review: this.value,
        };
    },
    computed: {
        commentDisabled() {
            return this.review.agreement === "I agree.";
        },
    },
    methods: {
        change() {
            this.$emit("input", this.review);
        },
    },
    watch: {
        value(newValue) {
            this.review = newValue;
        },
    },
};
</script>
