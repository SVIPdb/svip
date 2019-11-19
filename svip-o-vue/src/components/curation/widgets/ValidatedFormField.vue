<template>
    <ValidationProvider v-if="enabled" :rules="required ? 'required' : ''" ref="provider" mode="passive" v-slot="{errors, invalid, changed, validate}">
        <b-form-group :label="label" :label-for="innerId" :description="sublabel" label-cols-sm="4" label-cols-lg="3">
            <slot :invalid="invalid" :changed="changed" :validate="validate" />
            <ul class="error-list" v-if="errors.length > 0 && !changed">
                <li v-for="(err, idx) in errors" :key="idx">{{ err }}</li>
            </ul>
        </b-form-group>
    </ValidationProvider>
</template>

<script>
export default {
    name: "ValidatedFormField",
    props: {
        label: { type: String, required: true },
        sublabel: { type: String, required: false },
        innerId: { type: String, required: true },
        enabled: { type: Boolean, default: true },
        required: { type: Boolean, default: false },
        modeled: { }
    },
    methods: {
        hasProvider() {
            return !!this.$refs.provider;
        },
        validate() {
            console.log(`Validating ${this.innerId} against value `, this.modeled);
            return this.$refs.provider.validate(this.modeled);
        }
    }
}
</script>

<style scoped>
.error-list {
    list-style: none;
    margin: 0; padding: 0;
    color: #c95555;
}
</style>
