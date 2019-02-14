<template>
	<div class="container">
		<div class="highlight-clean">
			<div class="container">
				<div class="intro section text-center">
					<img
						src="../assets/svip_logo.png"
						width="368"
						height="137"
						alt="Svip Logo"
					/>
				</div>
				<div class="section row justify-content-md-center">
					<div class="col-6">
						<!-- <form ><input type="search" placeholder="Search for gene / variant" class="form-control" /></form> -->
						<!--
            <form>
                <v-select :options="options" value='' placeholder="Search for gene / variant" v-model="gene"></v-select>
            </form>
-->

						<SearchBar/>
					</div>
				</div>

				<div class="section stats row justify-content-md-center">
					<div class="col">
						<h3>{{ nbGenes }} Genes</h3>
					</div>
					<div class="col">
						<h3>{{ nbVariants }} Variants</h3>
					</div>
				</div>
			</div>
		</div>
	</div>
</template>

<script>
import {mapGetters} from "vuex";
import store from "@/store";
import {serverURL} from "@/app_config";
import SearchBar from "./widgets/SearchBar";

export default {
	name: "home",
	components: {SearchBar},
	data() {
		return {
			gene: {}
		};
	},
	watch: {
		gene: function (n) {
			if (n.value) {
				let geneIdx = _.findIndex(this.genes, g => {
					return g.entrez_id === n.value;
				});
				let id = "";
				if (geneIdx > -1) {
					let url = this.genes[geneIdx].url;
					id = url.replace(serverURL + "genes", "");
					id = id.replace(/\D/, "");
				}
				if (id) this.$router.push("gene/" + id);
			}
		}
	},
	computed: {
		...mapGetters({
			genes: "genes",
			variants: "variants",
			phenotypes: "phenotypes",
			nbVariants: "nbVariants",
			nbPhenotypes: "nbPhenotypes",
			nbGenes: "nbGenes"
		}),
		project() {
			return this.user.projects.filter(
				p => p.project_id === this.user.project_id
			)[0];
		},
		options() {
			return this.genes.map(g => {
				return {label: g.symbol, value: g.entrez_id};
			});
		},
		nbUniquePhenotypes() {
			return _.uniqBy(this.phenotypes, d => {
				return d.pheno_id;
			}).length;
		}
	},
	methods: {
		test(val) {
			// eslint-disable-next-line no-console
			console.log(val);
		}
	},
	created() {
		store.dispatch("getSiteStats");
		store.dispatch("getGenes");
		store.dispatch("getVariants");
	}
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.section {
	margin-top: 60px;
}

.intro {
	margin-top: 120px;
}

.stats {
	text-align: center;
}

.d-center {
	display: flex;
	align-items: center;
}

.selected img {
	width: auto;
	max-height: 23px;
	margin-right: 0.5rem;
}
</style>
