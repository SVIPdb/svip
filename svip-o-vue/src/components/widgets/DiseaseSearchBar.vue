<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="diseases" :value="value" @input="update"
        :multiple="multiple" :taggable="allowCreate" :push-tags="allowCreate"
        :disabled="disabled"
        label="name"
        :filter-by="filterBy"
    >
        <template v-slot:option="option">
            {{ option.name || option.label }}
            <span class="text-muted float-right">{{ option.localization && titleCase(option.localization.toLowerCase()) }}</span>
        </template>
    </v-select>
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
        titleCase,
        update(newValue) {
            this.$emit('input', newValue);
        },
        filterBy(option, label, search) {
            const isearch = search.toLowerCase();
            return (
                (option.name && option.name.toLowerCase().includes(isearch)) ||
                (option.localization && option.localization.toLowerCase().includes(isearch))
            );
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
