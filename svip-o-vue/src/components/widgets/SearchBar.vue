<template>
  <div>
		<v-select ref="search_bar" label="label"
			:options="options" :filterBy="() => true"
      :placeholder="`Search for ${!variantsOnly ? 'gene /' : ''} variant`" @search="onSearch" v-model="selected"
      :multiple="multiple"
		>
			<template slot="option" slot-scope="option">
				<div class="d-center">
					<div class="bits" v-if="query">
						<span v-for="(bit, idx) in highlighted( transformedQuery, option.label )" :key="idx" :class="{ segment: true, matched: bit.match }">{{ bit.text }}</span>
					</div>
					<div v-else>{{ option.label }}</div>

					<div class="sources-set">
						<SourceIcon v-for="x in option.sources" :key="x" :name="x" :noTip="true" />
					</div>

					<div class="result-type">
						{{ textmapper[option.type] }}
					</div>
				</div>
			</template>
		</v-select>

		<div style="padding: 10px;">
			<b-checkbox v-model="showOnlySVIP"><span id="show-svip-vars">show only SVIP variants</span></b-checkbox>
			<b-tooltip target="show-svip-vars" placement="bottom">show only variants for which SVIP-specific data exists</b-tooltip>
		</div>
	</div>
</template>

<script>
import _ from "lodash";
import {HTTP} from "@/router/http";

import store from "@/store";
import SourceIcon from "@/components/widgets/SourceIcon";

const textmapper = {
	g: "gene",
	v: "variant"
};

// maps three-letter AA refs to the one-letter ones we use internally
// this is done on the client side to make it easier to highlight the matching text in the result
const aa_three_to_one = [
	[ new RegExp("[Aa]la", "g"), "A" ],
	[ new RegExp("[Aa]sx", "g"), "B" ],
	[ new RegExp("[Cc]ys", "g"), "C" ],
	[ new RegExp("[Aa]sp", "g"), "D" ],
	[ new RegExp("[Gg]lu", "g"), "E" ],
	[ new RegExp("[Pp]he", "g"), "F" ],
	[ new RegExp("[Gg]ly", "g"), "G" ],
	[ new RegExp("[Hh]is", "g"), "H" ],
	[ new RegExp("[Ii]le", "g"), "I" ],
	[ new RegExp("[Ll]ys", "g"), "K" ],
	[ new RegExp("[Ll]eu", "g"), "L" ],
	[ new RegExp("[Mm]et", "g"), "M" ],
	[ new RegExp("[Aa]sn", "g"), "N" ],
	[ new RegExp("[Pp]ro", "g"), "P" ],
	[ new RegExp("[Gg]ln", "g"), "Q" ],
	[ new RegExp("[Aa]rg", "g"), "R" ],
	[ new RegExp("[Ss]er", "g"), "S" ],
	[ new RegExp("[Tt]hr", "g"), "T" ],
	[ new RegExp("[Ss]ec", "g"), "U" ],
	[ new RegExp("[Vv]al", "g"), "V" ],
	[ new RegExp("[Tt]rp", "g"), "W" ],
	[ new RegExp("[Xx]aa", "g"), "Xa" ],
	[ new RegExp("[Tt]yr", "g"), "Y" ],
	[ new RegExp("[Gg]lx", "g"), "Z" ],
	[ new RegExp("\\*", "ig"), "X" ]
];

export default {
	name: "SearchBar",
	components: {SourceIcon},
	props: {
		variantsOnly: { type: Boolean, required: false, default: false },
		multiple: { type: Boolean, required: false, default: false },
	},
	data() {
		return {
			query: "",
			options: [],
			selected: null,
			textmapper: textmapper
		};
	},
	watch: {
		selected: function () {
			if (this.variantsOnly) {
				return;
			}

			const val = this.selected;

			if (val.type === "g") {
				this.$router.push("gene/" + val.id);
			} else if (val.type === "v") {
				this.$router.push("gene/" + val.g_id + "/variant/" + val.id);
			}
		},
		showOnlySVIP: function () {
			if (this.variantsOnly) {
				return;
			}

			if (this.query === "") {
				this.getGenesOnly();
			}
		}
	},
	computed: {
		showOnlySVIP: {
			get() {
				return store.state.genes.showOnlySVIP;
			},
			set(value) {
				store.dispatch("toggleShowSVIP", {showOnlySVIP: value}).then(() => {
					// FIXME: perhaps let's reset the contents of the search box when we toggle this
					if (!this.variantsOnly) {
					  this.getGenesOnly();
					}
					else {
						this.selected = null;
					}
				});
			}
		},
		transformedQuery() {
			// convert Val600Glu into V600E so that stuff like highlighting continues to function client-side
			// (NOTE: on the server side we also transform Val600Glu to V600E, and match either description)

			// FIXME: ideally we should just send the transformed query instead of mirroring the behavior
			//  on the client and the server
			return aa_three_to_one.reduce((acc, x) => acc.replace(x[0], x[1]), this.query);
		}
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
		getGenesOnly: function () {
			HTTP.get("query", {params: {q: "", in_svip: this.showOnlySVIP}}).then(res => {
				this.options = res.data;
			});
		},
		search: _.debounce((loading, search, vm) => {
			return HTTP.get("query", {params: {q: search, in_svip: vm.showOnlySVIP}}).then(res => {
				vm.options = res.data;
				loading(false);
			});
		}, 350),
		highlighted: function (query, orig) {
			if (!query) return orig;

			const r = new RegExp(query, "gi");
			const bits = orig.split(r);
			const parts = [];
			// we just use this to match the query bits
			orig.replace(r, match => {
				parts.push(match);
			});

			// zip together bits and parts into an array
			// (we only want to concatenate the followers if there are some, otherwise we end up popping nothing)
			return bits.reduce(
				(acc, next) =>
					parts.length > 0
						? acc.concat({text: next.replace(" ", "\u00A0"), match: false}, {text: parts.pop(), match: true})
						: acc.concat({text: next.replace(" ", "\u00A0"), match: false}), []
			);
		}
	}
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
	width: 5em;
}

.result-type {
	font-style: italic;
	color: #555;
}

.v-select .dropdown-toggle::after {
	content: "";
}
</style>
