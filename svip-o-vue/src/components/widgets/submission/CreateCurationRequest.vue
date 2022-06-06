<template>
    <div>
        <b-form-group>
            <b-checkbox v-model="for_curation_request" @input="modelChanged">
                {{ $t("Create a curation request associated with this submission.")}}
            </b-checkbox>
        </b-form-group>

        <b-form-group label="Requestor" v-if="for_curation_request">
            <b-input type="text" name="requestor" v-model="requestor" @input="modelChanged" />
        </b-form-group>

        <ValidatedFormField v-if="for_curation_request"
            :inline="false"
            v-slot="props"
            :modeled="icdo_morpho"
            label="ICD-O Morpho Code"
            inner-id="icdo_morpho"
        >
            <MorphoSearchBar
                id="icdo_morpho"
                v-model="icdo_morpho" @input="modelChanged"
                :state="true"
            />
        </ValidatedFormField>

        <ValidatedFormField v-if="for_curation_request"
            v-slot="props"
            :modeled="icdo_topo"
            :enabled="!!(icdo_morpho)"
            :inline="false"
            label="ICD-O Topo Codes"
            inner-id="icdo_topo"
        >
            <TopoSearchBar
                id="icdo_topo"
                v-model="icdo_topo" @input="modelChanged"
                :state="true"
                :multiple="true"
            />
        </ValidatedFormField>
    </div>
</template>

<script>
import MorphoSearchBar from "@/components/widgets/searchbars/icdo/MorphoSearchBar";
import TopoSearchBar from "@/components/widgets/searchbars/icdo/TopoSearchBar";
import ValidatedFormField from "@/components/widgets/curation/ValidatedFormField";

export default {
    name: "CreateCurationRequest",
    components: { ValidatedFormField, TopoSearchBar, MorphoSearchBar },
    props: {
        value: { required: true }
    },
    created() {
        // copy in contents of value prop when we're created
        if (this.value) {
            Object.entries(this.value).forEach(([k, v]) => {
                this.$set(this.$data, k, v);
            })
        }
    },
    data() {
        return {
            for_curation_request: false,
            requestor: null,
            icdo_morpho: null,
            icdo_topo: null
        }
    },
    methods: {
        checkValidity(props, withoutChange) {
            return props.invalid && (withoutChange || !props.changed)
                ? false
                : null;
        },
        modelChanged() {
            this.$nextTick(() => {
                this.$emit('input', {...this.$data});
            })
        }
    }
}
</script>

<style scoped>

</style>
