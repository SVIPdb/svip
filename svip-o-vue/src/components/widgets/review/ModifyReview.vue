<template>
    <div class="p-0 m-0">
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-header class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showReview"/>
                    <span>{{ label }}</span>
                </h6>
            </b-card-header>

            <transition name="slide-fade">
                <b-card-text v-if="showReview">
                    <b-table v-for="(disease, index) in disease" :key="index" :fields="fields"
                        :items="Object.values(disease)"
                        :thead-class="index !== 'Prognostic' ? 'hidden_header' : ''" class="mb-0" :bordered="true">

                        <template v-slot:cell(type_of_evidence)="row">
                            <row-expander :row="row" class="mr-2"/>
                            <span>{{ index }}</span>
                        </template>

                        <template v-slot:cell(list_of_evidences)="data">
                            <p v-for="(outcome, index) in data.item.outcome" :key="index">{{ outcome.label }}: {{ outcome.nb_evidence }} evidence(s)<br/>
                            </p>
                            <!-- Ivo : better to not include the number of evidences in the object and compute it here?
                            <span v-for="(outcome, index) in data.item.outcome" :key="index">{{ outcome.label }} ({{ Object.keys(data.item.evidence).length }} evidence(s))<br /></span>
                            -->
                        </template>

                        <template v-slot:cell(sib_annotation)="data">
                            <div class="pb-2" @change="handleEffect" v-bind:id="`effect-${data.item.id}`">
                                <b-form-select v-model="data.item.sib_annotation_outcome" v-if="index.includes('Prognostic')"
                                               :options="prognosticOutcomeOptions" class="form-control"></b-form-select>
                                <b-form-select v-model="data.item.sib_annotation_outcome" v-if="index.includes('Diagnostic')"
                                               :options="diagnosticOutcomeOptions" class="form-control"></b-form-select>
                                <b-form-select v-model="data.item.sib_annotation_outcome"
                                               v-if="index.includes('Predictive / Therapeutic')"
                                               :options="predictiveOutcomeOptions" class="form-control"></b-form-select>
                            </div>
                            <div class="pt-2" @change="handleTier" v-bind:id="`tier-${data.item.id}`">
                                <b-form-select v-model="data.item.sib_annotation_trust" v-if="index.includes('Prognostic')"
                                               :options="trustOptions" class="form-control"></b-form-select>
                                <b-form-select v-model="data.item.sib_annotation_trust" v-if="index.includes('Diagnostic')"
                                               :options="trustOptions" class="form-control"></b-form-select>
                                <b-form-select v-model="data.item.sib_annotation_trust"
                                               v-if="index.includes('Predictive / Therapeutic')" :options="trustOptions"
                                               class="form-control"></b-form-select>
                            </div>
                            <input class='invisible' v-model="data.item.sib_annotation_outcome" @change="annotationEdited(data.item)" />
                        </template>

                        <template v-slot:cell(reviewer_annotation)="data">
                            <b-row>
                                <b-col cols="4" v-for="(review,index) in data.item.reviews" :key="index">
                                    <h5 class="mb-3">
                                        <b-icon v-if="review.reviewer_annotation_outcome === data.item.sib_annotation_outcome && review.reviewer_annotation_trust === data.item.sib_annotation_trust" style="color:blue;" icon="check-square-fill"></b-icon>
                                        <b-icon v-else style="color:red;" icon="x-square-fill"></b-icon>
                                        {{ review.reviewer }}
                                    </h5>
                                    <p :class="review.reviewer_annotation_outcome !== data.item.sib_annotation_outcome ? 'text-danger bold' : null">
                                        {{ review.reviewer_annotation_outcome }}</p>
                                    <p :class="review.reviewer_annotation_trust !== data.item.sib_annotation_trust ? 'text-danger bold' : null">
                                        {{ review.reviewer_annotation_trust }}</p>
                                    <small class="justify-around">{{
                                            review.comment
                                        }}
                                        <b-btn variant="primary" block class="mt-3" v-if="review.comment" :href="`mailto:${review.reviewer_mail}?cc=curate@svip.ch&from=curate@svip.ch&subject=Review%20of%20disease:${label}%20${variant.description}&body=${review.comment}%0D---%0DView%20online:%20${fullUrl}` ">Reply by mail</b-btn></small>
                                </b-col>
                            </b-row>
                        </template>

                        <template v-slot:cell(actions)>
                            <!-- Ivo : need to refresh if we add an evidence from a new tab? -->
                            <!-- :href="addEntryURL()" -->
                            <div align="center">
                                <b-button
                                    v-b-modal="addEvidenceID"
                                    target="_blank"
                                    class="centered-icons mb-3"
                                    variant="info"
                                    size="sm"
                                    block
                                >
                                    <icon name="plus"/>
                                    Add publication
                                </b-button>
                                <b-button
                                    v-b-modal="addNoteID"
                                    
                                    target="_blank"
                                    class="centered-icons"
                                    variant="primary"
                                    size="sm"
                                    block
                                >
                                    <icon name="plus"/>
                                    Clinical input
                                </b-button>
                            </div>
                        </template>

                        <!-- For transition: https://github.com/bootstrap-vue/bootstrap-vue/issues/5129 -->
                        <template v-slot:row-details="row">
                            <b-table :items="row.item.evidence" :fields="footer" thead-class="thead-footer"
                                     class="mb-0 text-justify" style="background-color: #f3f3f3;">

                                <template v-slot:cell(evidence_link)="data">
                                    <span>Evidence : </span>
                                    <b-link :to="$route.fullPath + '/entry/' + data.item.evidence_link" target="_blank">
                                        {{ data.item.evidence_link }}
                                    </b-link>
                                </template>

                                <template v-slot:cell(pmid_link)="data">
                                    <span>PMID : </span>
                                    <b-link v-bind="pubmedURL(data.item.pmid_link)" target="_blank">
                                        {{ data.item.pmid_link }}
                                    </b-link>
                                </template>

                                <template v-slot:cell(outcome)="data">
                                    <span>{{ data.item.outcome }}</span>
                                </template>

                                <template v-slot:cell(evidence_comment)="data">
                                    <span>{{ data.item.evidence_comment }}</span>
                                </template>

                                <template v-slot:cell(actions)="data">
                                    <div align="center">
                                        <b-button
                                            :href="editEntryURL(data.item.evidence_link)"
                                            class="mb-2 centered-icons"
                                            variant="success"
                                            style="width: 110px;"
                                            size="sm"
                                            target="_blank"
                                        >
                                            <icon name="pen-alt"/>
                                            Edit
                                        </b-button>
                                        <b-button
                                            @click="deleteEntry(data.item.evidence_link)"
                                            class="mt-2 centered-icons"
                                            variant="danger"
                                            style="width: 110px;"
                                            size="sm"
                                        >
                                            <icon name="trash"/>
                                            Delete
                                        </b-button>
                                    </div>
                                </template>

                            </b-table>
                        </template>

                    </b-table>
                </b-card-text>
            </transition>
        </b-card>

        <div v-for="(evidence) in disease" :key="evidence">
            <b-modal :id="addNoteID" :ref="evidence.sib_annotation_id" title="Add/modify a note" class="modal-add-evidence"
                    size="lg" :hide-footer="true">
                <b-card no-body>
                    <b-textarea class="summary-box" v-model="note" rows="3"/>
                </b-card>
            </b-modal>
        </div>

        <b-modal :id="addEvidenceID" ref="modal-add-evidence" title="Add a new evidence" class="modal-add-evidence"
                size="lg" :hide-footer="true">
            <b-card no-body>
                <b-tabs
                    card
                    justified
                    nav-wrapper-class="bg-primary"
                    nav-class="text-white"
                    active-nav-item-class="font-weight-bolder"
                >
                    <b-tab title="Enter your reference" active>
                        <b-card-body>
                            <b-container>
                                <b-row no-gutters>
                                    <b-col cols="3">
                                        <b-form-select required class="custom-border-left" v-model="source"
                                                    :options="['PMID']"/>
                                    </b-col>
                                    <b-col cols="6">
                                        <b-form-input
                                            v-model="reference"
                                            required
                                            placeholder="Type reference"
                                            class="rounded-0"
                                        />
                                    </b-col>
                                    <b-col cols="2">
                                        <b-button-group>
                                            <b-button :disabled="!source || !reference"
                                                    class="custom-unrounded centered-icons" variant="info"
                                                    @click="viewCitation">
                                                <icon name="eye"/>
                                                View Abstract
                                            </b-button>
                                            <b-button :disabled="!source || !reference" type="submit"
                                                    class="custom-border-right centered-icons" variant="success"
                                                    @click="addEvidence" target="_blank">
                                                <icon name="plus"/>
                                                Create Entry
                                            </b-button>
                                        </b-button-group>
                                    </b-col>
                                </b-row>

                                <transition name="slide-fade" mode="out-in">
                                    <MessageWithIcon v-if="annotationUsed" class="mt-4 mr-5 ml-5">
                                        <template v-slot:icon>
                                            <icon name="exclamation-triangle" scale="2.5"/>
                                        </template>
                                        <template>
                                            This reference has already been used in other entries:

                                            <div class="mt-1 text-left">
                                                <b-button pill class="mr-1 mb-1" variant="primary" size="sm"
                                                        v-for="x in annotationUsed" :key="x.id"
                                                        :to="`/curation/gene/${x.gene_id}/variant/${x.variant_id}/entry/${x.id}`"
                                                        target="_blank"
                                                >
                                                    Entry #{{ x.id }}
                                                </b-button>
                                            </div>
                                        </template>
                                    </MessageWithIcon>
                                </transition>

                                <b-row no-gutters>
                                    <b-col cols="12">
                                        <VariomesAbstract v-if="loadingVariomes" style="margin-top: 1em;"
                                                        :variomes="variomes"/>
                                    </b-col>
                                </b-row>
                            </b-container>
                        </b-card-body>
                    </b-tab>
                </b-tabs>
            </b-card>
        </b-modal>

    </div>
</template>

<script>
/* eslint-disable */
import {mapGetters} from "vuex";
import {pubmedURL} from "@/utils";
import BroadcastChannel from "broadcast-channel";
import VariomesSearch from "@/components/widgets/curation/VariomesSearch";
import VariomesAbstract from "@/components/widgets/curation/VariomesAbstract";
import {HTTP} from "@/router/http";
import {BIcon, BIconCheckSquareFill, BIconSquare, BIconXSquareFill} from "bootstrap-vue";

export default {
    name: "ModifyReview",
    components: {
        VariomesSearch,
        VariomesAbstract,
        BIcon,
        BIconSquare,
        BIconCheckSquareFill,
        BIconXSquareFill
    },
    props: {
        raw_disease: {type: Array, required: false},
        //disease: {type: Object, required: false},
        label: {type: String, required: false}
    },
    methods: {
        pubmedURL,
        created() {
            this.refreshReferences();
            this.channel.onmessage = () => {
                // update the list of references, since we likely added one
                this.refreshReferences();
            };
        },
        handleEffect(event) {
            const tag_id = event.target.parentNode.id
            const selectedValue = document.getElementById(tag_id).childNodes[2].value
            const evidence_id = tag_id.split("-").pop()
            for (var outcome in this.disease) {
                const evidence = this.disease[outcome][0]
                if (evidence.id == parseInt(evidence_id)) {
                    evidence['sib_annotation_outcome'] = selectedValue
                    this.annotationEdited(evidence)
                }
            }
        },
        handleTier(event) {
            const tag_id = event.target.parentNode.id
            const selectedValue = document.getElementById(tag_id).childNodes[2].value
            const evidence_id = tag_id.split("-").pop()
            for (var outcome in this.disease) {
                const evidence = this.disease[outcome][0]
                if (evidence.id == parseInt(evidence_id)) {
                    evidence['sib_annotation_trust'] = selectedValue
                    this.annotationEdited(evidence)
                }
            }
        },
        makeItems() {
            const evidences = {}
            this.raw_disease.map(evidence => {
                if (!(evidence.fullType in evidences)) {
                    evidences[evidence.fullType] = []
                }
                const evidenceObj = {}
                evidenceObj["outcome"] = []
                evidence.effectOfVariant.map(effect => {
                    evidenceObj["outcome"].push({
                        "label": effect.label,
                        "nb_evidence": effect.count
                    })
                })

                evidenceObj['id'] = evidence.id

                if (typeof evidence.finalAnnotation === 'undefined') {
                    // If not final annotation yet, then the values are those of first annotation
                    evidenceObj["sib_annotation_outcome"] = evidence.curator.annotatedEffect
                    evidenceObj["sib_annotation_trust"] = evidence.curator.annotatedTier
                    evidenceObj["clinical_input"] = ''
                    
                } else {
                    evidenceObj["sib_annotation_outcome"] = evidence.finalAnnotation.annotatedEffect
                    evidenceObj["sib_annotation_trust"] = evidence.finalAnnotation.annotatedTier
                    evidenceObj["clinical_input"] = evidence.finalAnnotation.clinical_input

                    // use id of final_annotation object so that the PATCH request is made to the right ID
                    evidenceObj["final_annotation_id"] = evidence.finalAnnotation.id
                }

                evidenceObj["reviews"] = []
                evidence.reviews.map(review => {
                    if (review.status != null) {
                        evidenceObj["reviews"].push({
                            "reviewer": review.reviewer,
                            "reviewer_mail": review.reviewer_mail,
                            "reviewer_annotation_outcome": review.annotatedEffect,
                            "reviewer_annotation_trust": review.annotatedTier,
                            "comment": review.comment
                        })
                    }
                })
                evidenceObj["evidence"] = []
                evidence.curations.map(curation => {
                    evidenceObj["evidence"].push({
                        reject: false,
                        outcome: curation.effect,
                        evidence_link: curation.id,
                        pmid_link: curation.pmid.toString(),
                        evidence_comment: curation.comment
                    })
                })
                evidenceObj["show_review_status"] = false
                evidenceObj["note"] = null
                evidences[evidence.fullType].push(evidenceObj)
                this.annotationEdited(evidenceObj)
            })
            this.disease = evidences;
        },
        annotationEdited(evidence) {
            let annotation = {
                'effect': evidence.sib_annotation_outcome,
                'tier': evidence.sib_annotation_trust,
                'evidence': evidence.id,
                'clinical_input': evidence.clinical_inpu
            }
            if (typeof evidence['final_annotation_id'] !== 'undefined') {
                annotation['id'] = evidence['final_annotation_id']
            }
            this.$emit('annotated', annotation)
        },
        deleteEntry(entry_id) {
            if (confirm("Are you sure that you want to delete this entry?")) {
                HTTP.delete(`/curation_entries/${entry_id}`)
                    .then(() => {
                        this.channel.postMessage(`Deleted ID ${entry_id}`);
                        this.$snotify.info("Entry deleted!");
                        this.$refs.paged_table.refresh();
                    })
                    .catch((err) => {
                        console.log("ERROR:")
                        console.log(err)
                        //this.$snotify.error("Failed to delete entry");
                    });
            }
        },
        editEntryURL(entry) {
            // FIXME: presumes again that the first variant is the 'main' one; do we want to assume that, or split it
            //  into a seprate field?
            // FIXME: alternatively, should curation entries have a 'main' variant at all, or should we restructure the
            //  URL to remove the gene, variant, disease refererences?
            const [gene_id, variant_id] = [
                this.$route.params.gene_id,
                this.$route.params.variant_id,
            ];
            return `/curation/gene/${gene_id}/variant/${variant_id}/entry/${entry}`;
        },
        /*addEntryURL(entry) {
            const [gene_id, variant_id] = [
                this.$route.params.gene_id,
                this.$route.params.variant_id,
            ];
            //return `/curation/gene/${gene_id}/variant/${variant_id}/entry/add?source=PMID&reference=${entry.id}`;
        },*/
        addEvidence() {
            let route = this.$router.resolve({
                name: "add-evidence",
                params: {
                    gene_id: this.$route.params.gene_id,
                    variant_id: this.$route.params.variant_id,
                    //disease_id: this.$route.params.disease_id,
                    disease_id: 9,
                    action: 'add'
                },
                query: {source: this.source, reference: this.reference}
            });
            window.open(route.href, "_blank");
        },
        viewCitation() {
            // look up the reference via the variomes API
            this.loadingVariomes = true;
            // FIXME: we should ensure that we have a variant before we fire this off somehow...
            HTTP.get(`variomes_single_ref`, {
                params: {
                    id: this.reference.trim(),
                    genvars: `${this.variant.gene.symbol} (${this.variant.name})`
                }
            })
                .then(response => {
                    this.variomes = response.data;
                    // this.loadingVariomes = false;
                })
                .catch((err) => {
                    log.warn(err);
                    this.variomes = {
                        error: "Couldn't retrieve publication info, try again later."
                    };
                    // this.loadingVariomes = false;
                });
        }
    },
    data() {
        return {
            disease: {},
            addNoteID: '',
            addEvidenceID: '',
            showReview: true,
            channel: new BroadcastChannel("curation-update"),
            source: "PMID",
            reference: "",
            loadingVariomes: false,
            variomes: null,
            used_references: {},
            note: null,
            fields: [
                {
                    key: "type_of_evidence",
                    label: "TYPE OF EVIDENCE",
                    class: "ten-percent-class"
                },
                {
                    key: "sib_annotation",
                    label: "SIB ANNOTATION",
                    class: "ten-percent-class"
                },
                {
                    key: "list_of_evidences",
                    label: "LIST OF EVIDENCES",
                    class: "fifteen-percent-class"
                },
                {
                    key: "reviewer_annotation",
                    label: "REVIEWERS ANNOTATIONS",
                    class: "fourty-five-percent-class"
                },
                {
                    key: "actions",
                    label: "ACTIONS",
                    class: "ten-percent-class"
                },
            ],
            footer: [
                {
                    key: "pmid_link",
                    class: "twenty-percent-class"
                },
                {
                    key: "outcome",
                    class: "twenty-percent-class"
                },
                {
                    key: "evidence_comment",
                    class: "fifteen-percent-class"
                },
                {
                    key: "actions",
                    class: "ten-percent-class"
                },
            ],
            prognosticOutcomeOptions: [
                'Good outcome',
                'Poor outcome',
                'Intermediate',
                'Unclear',
                'Context-dependent',
            ],
            diagnosticOutcomeOptions: [
                'Associated with diagnosis',
                'Not associated with diagnosis',
                'Other',
            ],
            predictiveOutcomeOptions: [
                'Sensitive (in vitro)',
                'Responsive',
                'Resistant (in vitro)',
                'Reduced sensivity',
                'Not responsive',
                'Adverse response',
                'Other',
            ],
            trustOptions: [
                'Tier IA: Included in Professional Guidelines',
                'Tier IB: Well-powered studies with consensus from experts in the field',
                'Tier IIC: Multiples small published studies with some consensus',
                'Tier IID: Clinical trial',
                'Tier IID: Pre-clinical trial',
                'Tier IID: Population study',
                'Tier IID: Small published study',
                'Tier IID: Case reports',
                'Tier III: No convincing published evidence of drugs effect',
                'Tier III: Author statement',
                'Tier IV: Reported evidence supportive of benign/likely benign effect',
                'Other criteria'
            ],
        }
    },
    mounted() {
        this.makeItems()
        this.addEvidenceID = `modal-add-evidence-${this.label.replace(" ", "-")}`
        this.addNoteID = `modal-add-note-${this.label.replace("wesh", "-")}`
    },
    computed: {
        ...mapGetters({
            variant: "variant",
            gene: "gene"
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
        fullUrl() {
            return window.location.href;
        }
    },
};
</script>

<style>
.table td {
    vertical-align: middle;
}
.hidden_header {
    display: none;
}
.ten-percent-class {
    width: 10%;
}
.fifteen-percent-class {
    width: 15%;
}
.twenty-percent-class {
    width: 20%;
}
.fourty-five-percent-class {
    width: 45%;
}
.modal-dialog {
    max-width: 1200px;
}
.custom-style .dropdown-toggle {
    border-radius: 0 !important;
    height: calc(2.15625rem + 2px) !important;
}
.custom-unrounded {
    border-radius: 0 !important;
}
.custom-border-left {
    border-radius: 0.25rem 0 0 0.25rem !important;
}
.custom-border-right {
    border-radius: 0 0.25rem 0.25rem 0 !important;
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
</style>
<style scoped>
table >>> .thead-footer {
    display: none !important;
}
.action-tray {
    display: flex;
    justify-content: flex-end;
}
.action-tray .btn {
    margin-left: 5px;
    margin-bottom: 5px;
    display: flex;
    align-items: center;
    justify-content: center;
}
.text-small {
    font-size: smaller;
}
.invisble {
    display: none;
}
</style>