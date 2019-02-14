<template>
	<div class="container">
		<b-row class="text-center">
			<p class="text-center"><i>some filters can go here...</i></p>
		</b-row>

		<b-table striped hover :items="gene.files" :fields="fields" :sort-by.sync="sortBy" :sort-desc.sync="sortDesc" :per-page="perPage" :current-page="currentPage" :filter="filter" @filtered="onFiltered">
			<template slot="selection" slot-scope="data">
				<input type="checkbox" v-model="data.item.is_selected" @click="selectVariant(data.item)"/>
			</template>
			<template slot="actions"></template>
		</b-table>

		<!-- Delete modal -->
		<b-modal id="modalInfo" @hide="resetModalInfo" title="Please confirm the deletion">
			<p>
				file: <b>{{ modalInfo.filename }}</b>
			</p>
		</b-modal>
	</div>
</template>

<script>
import {mapGetters} from "vuex";
import {serverURL} from "@/app_config";

export default {
	data() {
		return {
			sortBy: "timestamp",
			sortDesc: true,
			perPage: 50,
			currentPage: 1,
			totalRows: 0,
			selectedVariants: [],
			filter: "",
			fields: [
				{
					key: "selection",
					label: " ",
					sortable: false
				},
				{
					key: "name",
					sortable: true
				},
				{
					key: "timestamp",
					label: "Date",
					sortable: true
				},
				{
					key: "user_name",
					sortable: true
				}
			],
			modalInfo: {
				filename: "",
				file_id: null
			},
			wait: false,
			serverURL: serverURL
		};
	},
	computed: {
		...mapGetters({
			user: "currentUser"
		}),
		nbSelectedVariants: function () {
			return this.selectedVariants.length;
		}
	},
	props: ["gene"],
	methods: {},
	mounted() {
	}
};
</script>

<style></style>
