<template>
    <h6 class="card-subtitle mb-2 evidence-line">
        <span class="text-muted evidence-count">{{ name }}: {{ totalRows.toLocaleString() }}</span>

        <div class="badges">
            <span
                :class="`badge badge-primary filter-${k}`"
                :key="k"
                v-for="[k, v] in Object.entries(value).filter(x => x[1] && x[0] !== 'search')">
                {{ desnakify(v) }}
                <button
                    type="button"
                    class="close small ml-3"
                    aria-label="Close"
                    style="font-size: 14px"
                    @click="value[k] = ''">
                    <span aria-hidden="true">&times;</span>
                </button>
            </span>
        </div>

        <div class="search-box" style="margin-left: 10px">
            <b-input-group size="sm">
                <b-form-input v-model="value.search" placeholder="Type to Search" />
                <b-input-group-append>
                    <b-btn :disabled="!value.search" @click="value.search = ''">Clear</b-btn>
                </b-input-group-append>
            </b-input-group>
        </div>
    </h6>
</template>

<script>
import {desnakify, titleCase} from '@/utils';

export default {
    name: 'RowDetailsHeader',
    props: ['name', 'totalRows', 'value'],
    methods: {
        titleCase,
        desnakify,
        updateValue: function (value) {
            this.$emit('input', value);
        },
    },
};
</script>

<style scoped>
.evidence-line {
    display: flex;
    align-items: center;
}

.evidence-count {
    flex: 1 1;
}

.badges {
    align-self: center;
}
</style>
