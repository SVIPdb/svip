<template>
    <div>
        <div v-if="showFilters || showSearch" class="card-subtitle mb-2 evidence-line">
            <span class="text-muted evidence-count">
                <b-spinner v-if="loading && !loading.error" small />
                <span v-else-if="loading.error">{{ loading.error }}</span>
                <span v-else-if="!loading">{{ itemNames }}: {{ totalRows.toLocaleString() }}</span>
            </span>

            <div v-if="showFilters" class="badges">
                <span :class="`badge badge-primary filter-${k}`" :key="k"
                    v-for="[k,v] in Object.entries(filters).filter(x => x[1])">
                    {{ desnakify(v) }}
                    <button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px"
                        @click="filters[k] = ''">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </span>
            </div>

            <div v-if="showSearch" class="search-box" style="margin-left: 10px;">
                <b-input-group size="sm">
                    <b-form-input v-model="search" placeholder="Type to Search"/>
                    <b-input-group-append>
                        <b-btn :disabled="!search" @click="search = ''">Clear</b-btn>
                    </b-input-group-append>
                </b-input-group>
            </div>
        </div>

        <b-table ref="table" v-bind="$attrs" :items="provider" :current-page="currentPage" :per-page="perPage" :filter="packedFilters">
            <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
            <template v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData">
                <slot :name="name" v-bind="slotData" />
            </template>

            <template v-slot:table-busy>
                <div class="text-center my-2">
                    <b-spinner class="align-middle" />
                </div>
            </template>
        </b-table>

        <div v-if="slotsUsed" :class="`paginator-holster ${slotsUsed ? 'occupied' : ''}`">
            <slot name="extra_commands" />

            <b-pagination
                v-if="totalRows > perPage"
                v-model="currentPage"
                :total-rows="totalRows"
                :per-page="perPage"
            />
        </div>
    </div>
</template>

<script>
import {HTTP} from '@/router/http';
import {desnakify} from "@/utils";

/**
 * Wraps b-table, generalizing paging, searching and filtering for our API. Props not included here are passed on to the
 * inner b-table.
 */
export default {
    name: "PagedTable",
    props: {
        /**
         *  The name of the items in the table, used to customize the item count label (default: "Items")
         */
        itemNames: { type: String, default: "Items" },
        /**
         * Whether to show filter badges from a preselected list.
         */
        showFilters: { type: Boolean, default: false },
        /**
         * Whether to show an inline free-text search box.
         */
        showSearch: { type: Boolean, default: false },
        /**
         * Transforms elements immediately after being requested by the API.
         */
        postMapper: { type: Function },
        /**
         * Search string applied to the table; supersedes the inline search box.
         */
        externalSearch: { type: String, default: null }
    },
    data() {
        return {
            items: [],
            currentPage: 1,
            perPage: 10,
            totalRows: 0,
            search: '',
            loading: true,
            filters: {}
        };
    },
    computed: {
        packedFilters() {
            return {
                __search: this.search,
                ...this.filters
            };
        },
        slotsUsed () {
            return !!this.$slots.extra_commands || (this.totalRows > this.perPage);
        },
    },
    watch: {
        externalSearch(value) {
            this.search = value;
        }
    },
    methods: {
        desnakify,
        provider(ctx) {
            const { __search, ...filter_params } = ctx.filter;

            const params = {
                page_size: ctx.perPage,
                page: ctx.currentPage,
                ordering: (ctx.sortDesc ? '-' : '') + ctx.sortBy,
                search: __search,
                ...(filter_params && filter_params)
            };

            this.loading = true;

            return HTTP.get(ctx.apiUrl, {params}).then(res => {
                this.totalRows = res.data.count;
                this.loading = false;
                return this.postMapper ? this.postMapper(res.data.results) : res.data.results;
            }).catch(err => {
                this.loading = { error: err };
                return [];
            });
        },
        refresh() {
            this.$refs.table.refresh();
        }
    }
}
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
