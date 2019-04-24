<template>
	<form>
		<v-select label="label" :options="options" placeholder="Search for gene / variant" @search="onSearch" v-model="selected">
			<template slot="option" slot-scope="option">
				<div class="d-center">
					<div class="bits" v-if="query">
						<span v-for="(bit, idx) in highlighted( query, option.label )" :key="idx" :class="{ segment: true, matched: bit.match }">{{ bit.text }}</span>
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
	</form>
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

export default {
	name: "SearchBar",
	components: {SourceIcon},
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
			const val = this.selected;

			if (val.type === "g") {
				this.$router.push("gene/" + val.id);
			} else if (val.type === "v") {
				this.$router.push("gene/" + val.g_id + "/variant/" + val.id);
			}
		},
		showOnlySVIP: function () {
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
					this.getGenesOnly();
				});
			}
		}
	},
	created() {
		this.getGenesOnly();
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
	flex: 1 1;
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
