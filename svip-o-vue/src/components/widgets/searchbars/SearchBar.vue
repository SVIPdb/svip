<template>
    <div>
        <v-select
            ref="search_bar"
            label="label"
            :options="options"
            :filterBy="() => true"
            :placeholder="`Search for ${!variantsOnly ? 'gene /' : ''} variant`"
            v-model="selected"
            :multiple="multiple"
            :disabled="disabled"
            @search="onSearch"
            @input="onInput"
        >
            <template slot="option" slot-scope="option">
                <div class="d-center">
                    <div class="bits" v-if="query">
                        <span
                            v-for="(bit, idx) in highlighted(
                                transformedQuery,
                                option.label
                            )"
                            :key="idx"
                            :class="{ segment: true, matched: bit.match }"
                            >{{ bit.text }}</span
                        >
                    </div>
                    <div v-else>{{ option.label }}</div>

                    <div class="sources-set">
                        <SourceIcon
                            v-for="x in option.sources"
                            :key="x"
                            :name="x"
                            :noTip="true"
                        />
                    </div>

                    <div class="result-type">{{ textmapper[option.type] }}</div>
                </div>
            </template>
        </v-select>

        <div v-if="!hideSvipToggle" style="padding: 10px">
            <b-checkbox v-model="showOnlySVIP">
                <span id="show-svip-vars">show only SVIP variants</span>
            </b-checkbox>
            <b-tooltip target="show-svip-vars" placement="bottom"
                >show only variants for which SVIP-specific data exists
            </b-tooltip>
        </div>
    </div>
</template>

<script>
import debounce from "lodash/debounce";
import ulog from "ulog";
import { HTTP } from "@/router/http";

import store from "@/store";
import SourceIcon from "@/components/widgets/SourceIcon";
import { escapeRegex } from "@/utils";

const log = ulog("SearchBar");

const textmapper = {
    g: "gene",
    v: "variant",
};

// maps three-letter AA refs to the one-letter ones we use internally
// this is done on the client side to make it easier to highlight the matching text in the result
const aa_three_to_one = [
    [new RegExp("[Aa]la", "g"), "A"],
    [new RegExp("[Aa]sx", "g"), "B"],
    [new RegExp("[Cc]ys", "g"), "C"],
    [new RegExp("[Aa]sp", "g"), "D"],
    [new RegExp("[Gg]lu", "g"), "E"],
    [new RegExp("[Pp]he", "g"), "F"],
    [new RegExp("[Gg]ly", "g"), "G"],
    [new RegExp("[Hh]is", "g"), "H"],
    [new RegExp("[Ii]le", "g"), "I"],
    [new RegExp("[Ll]ys", "g"), "K"],
    [new RegExp("[Ll]eu", "g"), "L"],
    [new RegExp("[Mm]et", "g"), "M"],
    [new RegExp("[Aa]sn", "g"), "N"],
    [new RegExp("[Pp]ro", "g"), "P"],
    [new RegExp("[Gg]ln", "g"), "Q"],
    [new RegExp("[Aa]rg", "g"), "R"],
    [new RegExp("[Ss]er", "g"), "S"],
    [new RegExp("[Tt]hr", "g"), "T"],
    [new RegExp("[Ss]ec", "g"), "U"],
    [new RegExp("[Vv]al", "g"), "V"],
    [new RegExp("[Tt]rp", "g"), "W"],
    [new RegExp("[Xx]aa", "g"), "Xa"],
    [new RegExp("[Tt]yr", "g"), "Y"],
    [new RegExp("[Gg]lx", "g"), "Z"],
    [new RegExp("\\*", "ig"), "X"],
];

export default {
    name: "SearchBar",
    components: { SourceIcon },
    props: {
        variantsOnly: { type: Boolean, required: false, default: false },
        multiple: { type: Boolean, required: false, default: false },
        disabled: { type: Boolean, required: false, default: false },
        preOptions: { type: Array, required: false, default: null },
        hideSvipToggle: { type: Boolean, default: false },
        value: {},
    },
    data() {
        return {
            query: "",
            raw_options: [],
            selected: null,
            textmapper: textmapper,
        };
    },
    watch: {
        value: function () {
            this.selected = this.value;
        },
        selected: function () {
            if (this.variantsOnly || this.multiple) {
                return;
            }

            // navigates to the gene/variant page when something is selected
            const val = this.selected;

            if (val.type === "g") {
                const real_id = val.id.split("_")[1];
                this.$router.push("gene/" + real_id);
            } else if (val.type === "v") {
                const real_id = val.id.split("_")[1];
                this.$router.push("gene/" + val.g_id + "/variant/" + real_id);
            }
        },
        showOnlySVIP: function () {
            if (this.variantsOnly) {
                return;
            }

            if (this.query === "") {
                this.getGenesOnly();
            }
        },
    },
    computed: {
        showOnlySVIP: {
            get() {
                if (this.hideSvipToggle) {
                    return false;
                }
                return store.state.genes.showOnlySVIP;
            },
            set(value) {
                store
                    .dispatch("toggleShowSVIP", { showOnlySVIP: value })
                    .then(() => {
                        // FIXME: perhaps let's reset the contents of the search box when we toggle this
                        if (!this.variantsOnly) {
                            this.getGenesOnly();
                        } else {
                            this.selected = null;
                        }
                    });
            },
        },
        transformedQuery() {
            // convert Val600Glu into V600E so that stuff like highlighting continues to function client-side
            // (NOTE: on the server side we also transform Val600Glu to V600E, and match either description)

            // FIXME: ideally we should just send the transformed query instead of mirroring the behavior
            //  on the client and the server
            return aa_three_to_one.reduce(
                (acc, x) => acc.replace(x[0], x[1]),
                this.query
            );
        },
        options() {
            return this.raw_options.map((x) => ({
                ...x,
                id: `${x.type}_${x.id}`,
            }));
        },
    },
    created() {
        if (!this.variantsOnly) {
            this.getGenesOnly();
        }
    },
    methods: {
        onSearch(search, loading) {
            loading(true);
            this.query = search;
            this.search(loading, search, this);
        },
        onInput() {
            this.$emit("input", this.selected);
        },
        getGenesOnly: function () {
            HTTP.get("query", {
                params: { q: "", in_svip: this.showOnlySVIP },
            }).then((res) => {
                this.raw_options = res.data;
            });
        },
        search: debounce((loading, search, vm) => {
            return HTTP.get("query", {
                params: {
                    q: search,
                    in_svip: vm.showOnlySVIP,
                    variants_only: vm.variantsOnly ? "true" : "false",
                },
            })
                .then((res) => {
                    // only take the response if it matches the query (timeing problem especially through proxy)
                    if (res.config.params.q === vm.query) {
                        vm.raw_options = res.data;
                    }
                    loading(false);
                })
                .catch((err) => {
                    vm.$snotify.error("An error occurred while searching");
                    log.warn(err);
                    loading(false);
                });
        }, 350),
        highlighted: function (query, orig) {
            if (!query) return orig;

            const parts = escapeRegex(query).split(" ");
            const parts_re = new RegExp("(" + parts.join("|") + ")", "gi");
            const matched = orig.split(parts_re);

            return matched.map((x, idx) => ({
                text: x.replace(" ", "\u00A0"),
                match: idx % 2 === 1,
            }));
        },
    },
};
</script>

<style scoped>
.d-center {
    margin: 0;
    padding: 0;
    display: flex;
    justify-content: space-between;
}

.d-center .segment {
    margin: 0;
}

.bits {
    display: inline-block;
    flex: 1 1;
    overflow: hidden;
    text-overflow: ellipsis;
    padding-right: 5px;
}

.bits * {
    margin: 0;
    color: #555;
}

.bits .matched {
    font-weight: bolder;
    color: black;
}

.sources-set {
    margin-right: 3px;
}

.result-type {
    font-style: italic;
    color: #555;
}
</style>
