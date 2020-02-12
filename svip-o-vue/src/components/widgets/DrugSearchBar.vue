<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="drugs" :value="value" @input="update"
        :multiple="multiple" :taggable="allowCreate" :push-tags="allowCreate"
        :disabled="disabled"
    />
</template>

<script>
import { HTTP } from "@/router/http";
import {titleCase} from "@/utils";

export default {
    name: "DrugSearchBar",
    props: {
        label: {type: String, default: 'common_name' },
        value: {},
        state: {type: Boolean},
        multiple: {type: Boolean, default: false},
        disabled: {type: Boolean, default: false},
        allowCreate: {type: Boolean, default: false},
    },
    data() {
        return {
            drugs: []
        }
    },
    created() {
        HTTP.get('/drugs').then(response => {
            this.drugs = response.data.map(x => titleCase(x[this.label]));
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
