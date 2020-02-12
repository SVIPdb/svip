<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="diseases" :value="value" @input="update"
        :multiple="multiple" :taggable="allowCreate" :push-tags="allowCreate"
        :disabled="disabled"
        label="name"
    />
</template>

<script>
import { HTTP } from "@/router/http";
import {titleCase} from "@/utils";

export default {
    name: "DiseaseSearchBar",
    props: {
        value: {},
        state: {type: Boolean},
        multiple: {type: Boolean, default: false},
        disabled: {type: Boolean, default: false},
        allowCreate: {type: Boolean, default: false},
    },
    data() {
        return {
            diseases: []
        }
    },
    created() {
        HTTP.get('/diseases?page_size=9999').then(response => {
            this.diseases = response.data.results;
        });
    },
    methods: {
        update(newValue) {
            this.$emit('input', newValue);
        }
    }
}
</script>

<style scoped>
#my-select >>> .vs__dropdown-toggle { padding: 24px; }
.invalidated >>> .vs__dropdown-toggle  {
    border-color: #e74c3c !important;
}
</style>
