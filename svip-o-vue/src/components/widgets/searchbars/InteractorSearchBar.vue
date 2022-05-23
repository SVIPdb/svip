<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="interactors"
        :value="value"
        label="label"
        @input="update"
        :reduce="(x) => x.label"
        :multiple="multiple"
        :taggable="allowCreate"
        :push-tags="allowCreate"
        :disabled="disabled"
    >
        <template v-slot:option="option">
            <span :class="[option.user_created && 'user_created']">
                {{ titleCase(option.label) }}
            </span>

            <span
                v-if="option.type"
                :class="['float-right', `tag-${option.type}`, 'entry-type']"
            >
                {{ option.type }}
            </span>
        </template>

        <template
            v-slot:selected-option-container="{
                option,
                deselect,
                disabled,
                multiple,
            }"
        >
            <span
                :class="['selected-tag', 'vs__selected', `tag-${option.type}`]"
                v-bind:key="option.index"
            >
                <slot
                    name="selected-option"
                    v-bind="
                        typeof option === 'object'
                            ? option
                            : { [label]: option }
                    "
                >
                    {{ option.label }}
                </slot>
                <button
                    v-if="multiple"
                    :disabled="disabled"
                    @click="deselect(option)"
                    type="button"
                    class="vs__deselect"
                    aria-label="Remove option"
                >
                    <span aria-hidden="true">&times;</span>
                </button>
            </span>
        </template>
    </v-select>
</template>

<script>
import { HTTP } from "@/router/http";
import { titleCase } from "@/utils";
import sortBy from "lodash/sortBy";

export default {
    name: "InteractorSearchBar",
    props: {
        label: { type: String, default: "common_name" },
        value: {},
        state: { type: Boolean },
        multiple: { type: Boolean, default: false },
        disabled: { type: Boolean, default: false },
        allowCreate: { type: Boolean, default: false },
    },
    data() {
        return {
            drugs: [],
            genes: [],
        };
    },
    created() {
        HTTP.get("/drugs").then((response) => {
            this.drugs = sortBy(response.data, (x) => !x.user_created);
        });
        HTTP.get("/genes?page_size=9999").then((response) => {
            this.genes = response.data.results;
        });
    },
    computed: {
        interactors() {
            if (!this.drugs || !this.genes) {
                return null;
            }

            return [
                ...this.drugs.map((x) => ({
                    ...x,
                    type: "drug",
                    id: "d_" + x.id,
                    label: x.common_name,
                })),
                ...this.genes.map((x) => ({
                    ...x,
                    type: "gene",
                    id: "g_" + x.id,
                    label: x.symbol,
                })),
            ];
        },
    },
    methods: {
        titleCase,
        update(newValue) {
            this.$emit("input", newValue);
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
.tag-gene {
    background-color: #e79abd;
}
.tag-drug {
    background-color: #8beea4;
}
.entry-type {
    display: inline-block;
    border-radius: 5px;
    padding: 2px;
    border: solid 1px #ccc;
    color: #555;
    font-size: smaller;
}
</style>
