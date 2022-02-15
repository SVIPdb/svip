<template>
    <div>
        <div class="container-fluid">
            <!-- Ivo : To change? -->
            <CuratorVariantInformations :variant="variant" :disease_id="disease_id"/>

            <!-- Ivo : Change name to "VariantSummaryReview"? -->
            <ModifyVariantSummary :variant="variant" :comments="summary.comments"/>

            <div v-for="(disease) in diseases" :key="disease">
                <modify-review :raw_disease="disease.evidences" :label="disease.disease" @annotated="updateAnnotations" :annotated="annotated" :not_reviewed="not_reviewed"/>
            </div>
            <b-button class="float-right" @click="submitAnnotations" :disabled="not_reviewed || annotated">
                Submit annotation
            </b-button>
        </div>
        <b-navbar-text v-if="not_reviewed" class="fixed-bottom submitted-bar" align="center">
            THIS VARIANT HASN'T RECEIVED 3 REVIEWS YET.
        </b-navbar-text>
        <b-navbar-text class="fixed-bottom submitted-bar" align="center" v-if="annotated">
            THIS VARIANT HAS ALREADY BEEN SUBMITTED TO A SECOND ROUND OF REVIEWS.
        </b-navbar-text>
    </div>
</template>

<script>
/* eslint-disable */
import {HTTP} from "@/router/http";
import {var_to_position} from "@/utils";
import {BIcon, BIconQuestion, BIconCheck, BIconX} from "bootstrap-vue";
import ModifyReview from "@/components/widgets/review/ModifyReview";
import ulog from "ulog";
import {mapGetters} from "vuex";
import CuratorVariantInformations from "@/components/widgets/curation/CuratorVariantInformations";
import ModifyVariantSummary from "@/components/widgets/review/ModifyVariantSummary";
import store from "@/store";
const log = ulog("ViewReview");
export default {
    name: "ViewReview",
    components: {
        BIcon,
        BIconQuestion,
        BIconCheck,
        BIconX,
        ModifyReview,
        CuratorVariantInformations,
        ModifyVariantSummary
    },
    props: {
        review: {type: Object, required: false},
    },
    data() {
        return {
            diseases: [],
            diseases_test: [
                {
                    "disease": "Aggressive fibromatosis",
                    evidences: {
                        "Prognostic": [],
                        "Diagnostic": [],
                        "Predictive / Therapeutic": []
                    }
                }
            ],
            summary: {
                content: "",
                comments: []
            },
            annotations: {},

            not_reviewed: false,
            annotated: false
        }
    },
    created() {
        // Watch if use is going to leave the page
        window.addEventListener('beforeunload', this.beforeWindowUnload)

        // Check that this page is appropriate regarding current review stage of variant
        if (['none', 'loaded', 'ongoing_curation', '0_review', '1_review', '2_reviews'].includes(this.variant.stage)) {
            this.not_reviewed = true
        } else if (['to_review_again', 'on_hold', 'fully_reviewed'].includes(this.variant.stage)) {
            this.annotated = true
        }
    },
    mounted() {
        HTTP.get(`/summary_comments/?variant=${this.variant.id}`).then((response) => {
            const results = response.data.results
            this.summary.comments = results;
        });
        this.getReviewData();
    },
    computed: {
        ...mapGetters({
            variant: "variant",
            gene: "gene",
            user: "currentUser"
        }),
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        },
        annotationUsed() {
            if (!this.source || !this.reference) {
                return null;
            }
            const thisRef = `${this.source.trim()}:${this.reference.trim()}`;
            return this.used_references[thisRef];
        },
    },
    methods: {
        beforeWindowUnload(e) {
            console.log('beforeWindowUnload is run')
            // Cancel the event
            e.preventDefault()
            // Chrome requires returnValue to be set
            e.returnValue = ''
        },
        getReviewData() {
            const params = {
                reviewer: this.user.user_id,
                var_id: this.variant.id,
            }
            HTTP.post(`/review_data`, params)
                .then((response) => {
                    this.diseases = response.data.review_data
                })
                .catch((err) => {
                    log.warn(err);
                })
        },
        updateAnnotations(annotation) {
            this.annotations[annotation['evidence']] = annotation
        },
        submitAnnotations() {
            for (var evidence_id in this.annotations) {
                // check wether annotation has an ID field (in that case it means an instance already exists in the DB)
                const annotation = this.annotations[evidence_id]
                if (typeof annotation.id === 'undefined') {
                    HTTP.post('/sib_annotations_2/', annotation)
                    .then((response) => {
                        console.log(`response: ${response}`)
                    })
                    .catch((err) => {
                        log.warn(err);
                    })
                } else {
                    const params = annotation
                    //console.log(annotation.id)
                    //delete params['id']
                    HTTP.patch(`/sib_annotations_2/${annotation.id}/`, annotation)
                    .then((response) => {
                        console.log(`response: ${response}`)
                    })
                    .catch((err) => {
                        log.warn(err);
                    })
                }
            }

            this.$snotify.success("Your review has been saved");
        }
    },
    beforeRouteEnter(to, from, next) {
        const {variant_id} = to.params;
        // ask the store to populate detailed information about this variant
        store.dispatch("getGeneVariant", {variant_id: variant_id}).then(({gene, variant}) => {
            to.meta.title = `SVIP-O: Annotate ${gene.symbol} ${variant.name}`;
            next();
        });
    },
};
</script>

<style>
.table td {
    vertical-align: middle;
}
/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
    transition: all 0.5s ease;
}
.slide-fade-leave-active {
    transition: all 0.3s ease;
}
.slide-fade-enter-to,
.slide-fade-leave {
    max-height: 120px;
}
.slide-fade-enter, .slide-fade-leave-to
    /* .slide-fade-leave-active below version 2.1.8 */
{
    opacity: 0;
    max-height: 0;
}

.submitted-bar {
    background-color: rgb(194, 45, 0);
    color: white;
    font-weight: bold;
    text-align: center;
    padding: 0.4rem;
}
</style>
