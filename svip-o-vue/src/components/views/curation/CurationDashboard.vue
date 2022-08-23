<template>
	<div class="container-fluid">
		<div>
			<ReviewNotificationCard
				:items="variantsForReview"
				:fields="review.fields"
				:loading="review.loading"
				:isReviewer="user.groups.includes('clinicians') ? true : false"
				title="REVIEWS"
				:error="on_request.error"
				defaultSortBy="days_left"
				cardHeaderBg="secondary"
				customBgColor="#1f608f"
				cardTitleVariant="white"
				cardFilterOption />
		</div>

		<div v-if="checkInRole('curators')">
			<!-- TBC: request queue -->
			<OnRequestEntries
				:isCurator="checkInRole('curators')"
				:isReviewer="checkInRole('reviewers')"
				defaultSortBy="days_left"
				title="ON REQUEST"
				cardHeaderBg="secondary"
				cardTitleVariant="white"
				cardCustomClass
				cardFilterOption
				@itemsloaded="onRequestItemsLoaded" />

			<EvidenceCard
				:isDashboard="true"
				has-header
				include-gene-var
				header-title="CURATION ENTRIES"
				cardHeaderBg="secondary"
				cardTitleVariant="white"
				small />
		</div>

		<div v-else style="text-align: center; margin-top: 3em">
			<router-link to="/" class="text-uppercase">Return to homepage</router-link>
		</div>
	</div>
</template>

<script>
import ReviewNotificationCard from '@/components/widgets/curation/ReviewNotificationCard';

import EvidenceCard from '@/components/widgets/curation/EvidenceCard';
import {checkInRole} from '@/directives/access';
import fields_on_request from '@/data/curation/on_request/fields.js';
import fields_review from '@/data/review/fields.js';
import OnRequestEntries from '@/components/widgets/curation/OnRequestEntries';
import {mapActions, mapGetters} from 'vuex';

export default {
	name: 'CurationDashboard',
	components: {
		OnRequestEntries,
		EvidenceCard,
		ReviewNotificationCard,
	},
	computed: {
		...mapGetters({
			user: 'currentUser',
			variantsForReview: 'variantsForReview',
		}),
	},
	data() {
		return {
			on_request: {
				loading: false,
				fields: fields_on_request,
				items: [],
			},
			review: {
				loading: false,
				fields: fields_review,
			},
		};
	},
	mounted() {
		this.getVariantsForReview();
	},
	methods: {
		...mapActions({getVariantsForReview: 'getVariantsForReview'}),
		checkInRole,
		onRequestItemsLoaded(items) {
			this.on_request.items = items;
			this.on_request.loading = false;
		},
	},
};
</script>

<style scoped>
.variant-card .card-body {
	padding: 0;
}

.variant-header td,
.variant-header th {
	vertical-align: text-bottom;
	padding: 1rem;
}
</style>
