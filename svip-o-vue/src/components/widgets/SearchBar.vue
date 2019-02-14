<template>
	<form>
		<v-select label="label" :options="options" placeholder="Search for gene / variant" @change="queryChanged" @search="onSearch" v-model="selected" v-on:change="queryChanged">
			<template slot="option" slot-scope="option">
				<div class="d-center">
					<div class="bits" v-if="query">
						<span v-for="(bit, idx) in highlighted( query, option.label )" :key="idx" :class="{ segment: true, matched: bit.match }">{{ bit.text }}</span>
					</div>
					<div v-else>{{ option.label }}</div>

					<div class="result-type">
						{{ textmapper[option.type] }}
					</div>
				</div>
			</template>
		</v-select>

		<div style="padding: 10px;">
			<b-checkbox v-model="showOnlySVIP">show only SVIP variants</b-checkbox>
		</div>
	</form>
</template>

<script>
import _ from "lodash";
import {mapGetters} from "vuex";
import {HTTP} from "@/router/http";

// mock data for the demo
import svipVariants from "@/assets/svip_variants.json";
import store from "@/store";

const textmapper = {
	g: "gene",
	v: "variant"
};

export default {
	name: "SearchBar",
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
		...mapGetters({
			svipVariants: "svipVariants"
		}),
		showOnlySVIP: {
			get() {
				return store.state.genes.showOnlySVIP;
			},
			set(value) {
				store.dispatch("toggleShowSVIP", {showOnlySVIP: value});
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
		queryChanged(val) {
			debugger;
			console.log(val);
		},
		getGenesOnly: function () {
			HTTP.get("query", {params: {q: ""}}).then(res => {
				this.options = this.showOnlySVIP
					? res.data.filter(
						entry =>
							entry.type === "g" &&
							svipVariants.find(
								sv => sv.gene_name === entry.label
							) !== undefined
					)
					: res.data;
			});
		},
		search: _.debounce((loading, search, vm) => {
			return HTTP.get("query", {params: {q: search}}).then(res => {
				if (vm.showOnlySVIP) {
					// FIXME: verify that we've filtered the gene list to only those genes for which we have SVIP info
					vm.options = res.data.filter(
						entry =>
							(entry.type === "g" &&
								svipVariants.find(
									sv => sv.gene_name === entry.label
								) !== undefined) ||
							(entry.type === "v" && vm.hasSvipData(entry))
					);
				} else {
					vm.options = res.data;
				}

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
		},
		hasSvipData: function (entry) {
			return (
				svipVariants.find(sv => `${sv.gene_name} ${sv.variant_name}`.toLowerCase() === entry.label.toLowerCase()) !== undefined
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

.bits * {
	margin: 0;
	color: #555;
}

.bits .matched {
	font-weight: bolder;
	color: black;
}

.result-type {
	font-style: italic;
	color: #555;
}

.v-select .dropdown-toggle::after {
	content: "";
}
</style>
