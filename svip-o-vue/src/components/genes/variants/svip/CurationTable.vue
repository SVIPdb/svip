<template>
    <b-card-text>
        <b-table
            :fields="fields"
            :responsive="true"
            :items="entries"
            show-empty
            small
            class="align-rows-center">
            <template v-slot:cell(display)="row">
                <row-expander v-access="'curators'" :row="row" />
            </template>

            <template v-slot:cell(warning)="row">
                <div
                    v-if="row.item.status === 'unreviewed'"
                    v-b-tooltip.right="'this entry is unreviewed'"
                    class="d-flex justify-content-center align-items-center"
                    style="font-size: 30px">
                    <icon name="exclamation-triangle" color="#cfb578" style="margin-top: 5px" />
                </div>
            </template>

            <template v-slot:cell(references)="data">
                <VariomesLitPopover
                    :pubmeta="{pmid: trimPrefix(data.value, 'PMID:')}"
                    :variant="variant.name"
                    :gene="variant.gene.symbol"
                    :disease="row.item.name" />
            </template>

            <template v-slot:row-details="row">
                <b-card
                    v-access="'curators'"
                    no-body
                    class="border-0 p-3 bg-light"
                    style="border-radius: 0; margin-bottom: 0">
                    <div style="margin-bottom: 1em">
                        <b>Complementary information</b>
                        <br />
                        {{ row.item.summary || '-' }}
                    </div>
                    <div>
                        <b>Personal comment (Only for curators)</b>
                        <br />
                        {{ row.item.comment || '-' }}
                    </div>
                </b-card>
            </template>

            <template v-slot:cell(created_on)="data">
                {{ simpleDateTime(data.value).date }}
            </template>

            <template v-slot:empty="scope">
                <div class="empty-table-msg">no evidence items</div>
            </template>
        </b-table>
    </b-card-text>
</template>

<script>
import VariomesLitPopover from '@/components/widgets/VariomesLitPopover';
import {simpleDateTime, trimPrefix} from '@/utils';
import {checkInRole} from '@/directives/access';

export default {
    name: 'CurationTable',
    components: {VariomesLitPopover},
    props: {
        variant: {required: true, type: Object},
        row: {required: true, type: Object},
        entries: {required: true, type: Array},
    },
    data() {
        return {
            fields: [
                {key: 'display', label: '', sortable: false},
                {key: 'warning', label: '', sortable: false},
                {
                    key: 'type_of_evidence',
                    label: 'Evidence Type',
                    sortable: true,
                },
                {key: 'effect', label: 'Effect', sortable: true},
                {
                    key: 'drugs',
                    label: 'Drugs',
                    sortable: true,
                    formatter: x => x.join(', '),
                },
                {
                    key: 'tier_level_criteria',
                    label: 'Tier Criteria',
                    sortable: true,
                },
                {key: 'tier_level', label: 'Tier Level', sortable: true},
                {
                    key: 'short_escat_score',
                    label: 'ESCAT score',
                    sortable: true,
                },
                {
                    key: 'mutation_origin',
                    label: 'Mutation Origin',
                    sortable: true,
                },
                {key: 'support', label: 'Support', sortable: true},
                {key: 'references', label: 'References', sortable: false},
                {
                    key: 'owner_name',
                    label: 'Curator',
                    sortable: false,
                    class: [this.checkInRole('curators') ? '' : 'd-none'],
                },
                {
                    key: 'status',
                    label: 'Status',
                    sortable: false,
                    class: [this.checkInRole('curators') ? '' : 'd-none'],
                },
                {
                    key: 'created_on',
                    label: 'Date',
                    sortable: true,
                    class: [this.checkInRole('curators') ? '' : 'd-none'],
                },
            ].map(x => {
                if (!x.formatter) {
                    x.formatter = v => v || '-';
                }
                return x;
            }),
        };
    },
    methods: {
        trimPrefix,
        checkInRole,
        simpleDateTime,
    },
};
</script>

<style scoped>
.align-rows-center td {
    vertical-align: middle;
}
</style>
