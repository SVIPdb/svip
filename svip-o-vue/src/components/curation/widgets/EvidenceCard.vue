<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-body class="p-0">
            <b-table
                class="mb-0"
                thead-class="bg-primary text-light"
                :tbody-tr-class="rowClass"
                :items="items"
                :fields="fields"
                show-empty
                empty-text="There seems to be an error"
            >
                <template v-slot:cell(status)="data">
                    <icon
                        :class="setClass(data.value)"
                        :name="setIcon(data.value)"
                        v-b-tooltip
                        :title="data.value"
                    ></icon>
                </template>
            </b-table>
        </b-card-body>
    </b-card>
</template>

<script>
import fields from "@/data/curation/evidence/fields.json";

export default {
    name: "EvidenceCard",
    props: {
        items: {
            type: Array,
            required: true
        }
    },
    data() {
        return {
            fields
        };
    },
    methods: {
        rowClass(item, type) {
            if (!item) return;
            if (item.stats === "completed") return "table-light";
        },
        setClass(status) {
            if (status === "complete") {
                return "text-success";
            } else if (status === "review") {
                return "text-info";
            } else {
                return "text-primary";
            }
        },
        setIcon(status) {
            if (status === "complete") {
                return "check";
            } else if (status === "review") {
                return "tasks";
            } else {
                return "pen-alt";
            }
        }
    }
};
</script>

<style>
</style>
