<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="drugs"
        :value="value"
        label="common_name"
        @input="update"
        :reduce="x => x.common_name"
        :disabled="disabled">
        <template v-slot:option="option">
            <span :class="[option.user_created && 'user_created']">
                {{ titleCase(option.common_name) }}
            </span>
        </template>
    </v-select>
</template>

<script>
import {HTTP} from '@/router/http';
import {titleCase} from '@/utils';
import sortBy from 'lodash/sortBy';

export default {
    name: 'DrugSearchBar',
    props: {
        label: {type: String, default: 'common_name'},
        value: {},
        state: {type: Boolean},
        multiple: {type: Boolean, default: false},
        disabled: {type: Boolean, default: false},
        allowCreate: {type: Boolean, default: false},
    },
    data() {
        return {
            drugs: [],
        };
    },
    created() {
        HTTP.get('/drugs').then(response => {
            this.drugs = sortBy(response.data, x => !x.user_created);
        });
    },
    methods: {
        titleCase,
        update(newValue) {
            this.$emit('input', newValue);
        },
    },
};
</script>

<style scoped>
#my-select >>> .vs__dropdown-toggle {
    padding: 24px;
}

.invalidated >>> .vs__dropdown-toggle {
    border-color: #e74c3c !important;
}

.user_created {
    font-style: italic;
}
</style>
