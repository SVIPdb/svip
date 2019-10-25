<template>
    <b-container fluid>
        <variant-informations :variant="variant" :fields="fields" />
        <b-row>
            <b-col sm="9">
                <b-card no-body style="margin-bottom: 1.5em;">
                    <b-card-body>
                        <b-container
                            fluid
                            class="evidence"
                            v-if="variomes && !variomes.error"
                            style="max-height:20rem;overflow-y:scroll;"
                            @mouseup="getSelectionText()"
                            @contextmenu.prevent.stop="handleRightClick($event)"
                        >
                            <h5 class="font-weight-bolder" v-html="variomes.publication.title_highlight"></h5>
                            <div>{{variomes.publication.date}}</div>
                            <p>
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${author}[Author]`"
                                    target="_blank"
                                    v-for="(author,index) in variomes.publication.authors"
                                    :key="index"
                                >{{author + (index < variomes.publication.authors.length-1 ? ', ' : '')}}</b-link>
                            </p>
                            <b>Abstract</b>
                            <p class="text-justify" v-html="variomes.publication.abstract_highlight"></p>
                            <small>
                                PMID:
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/${variomes.publication.id}`"
                                    target="_blank"
                                >{{variomes.publication.id}}</b-link>
                            </small>
                        </b-container>
                        <div
                            v-else-if="variomes && variomes.error"
                            class="text-center"
                        >We couldn't load the abstract due to some techincal issues.</div>
                        <div v-else class="text-center">
                            <b-spinner label="Spinning" variant="primary"></b-spinner>Loading
                        </div>
                    </b-card-body>
                </b-card>

                <b-card no-body>
                    <b-card-body>
                        <b-container fluid>
                            <b-form @submit.prevent>
                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Add variants ? (In case of a combination)"
                                    label-for="variants-combination"
                                >
                                    <SearchBar
                                        id="variants-combination"
                                        variants-only
                                        multiple
                                        v-model="form.variants"
                                    />
                                </b-form-group>
                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="For which type of evidence ?"
                                    label-for="evidence"
                                >
                                    <b-form-select
                                        id="evidence"
                                        :required="required"
                                        v-model="type_of_evidence"
                                        @input="setEvidence()"
                                    >
                                        <optgroup
                                            v-for="(label,index) in Object.keys(inputs)"
                                            :key="index"
                                            :label="label"
                                        >
                                            <option
                                                v-for="(option,n) in Object.keys(inputs[label])"
                                                :key="n"
                                                :value="{label: label,value: option}"
                                            >{{ option }}</option>
                                        </optgroup>
                                    </b-form-select>
                                </b-form-group>

                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Effect of the variant on the therapy"
                                    label-for="effect"
                                >
                                    <b-form-select
                                        id="effect"
                                        v-model="form.effect"
                                        :options="effects"
                                        :required="required"
                                    />
                                </b-form-group>

                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Select a Tier criteria"
                                    label-for="tier_criteria"
                                >
                                    <b-form-select
                                        id="tier_criteria"
                                        v-model="form.tier_criteria"
                                        :options="tier_criteria"
                                        :required="required"
                                    />
                                </b-form-group>

                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Origin of the mutation"
                                    label-for="origin"
                                >
                                    <b-form-select
                                        id="origin"
                                        v-model="form.origin"
                                        :options="['Somatic', 'Germline', 'Both somatic and germline', 'Unknown']"
                                        :required="required"
                                    />
                                </b-form-group>

                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Support"
                                    label-for="support"
                                >
                                    <b-form-select
                                        id="support"
                                        v-model="form.support"
                                        :options="['Strong', 'Moderate', 'Low', 'Other']"
                                        :required="required"
                                    />
                                </b-form-group>

                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Complementary information (viewed by others)"
                                    label-for="information"
                                >
                                    <b-form-textarea
                                        id="information"
                                        v-model="form.information"
                                        rows="3"
                                        max-rows="5"
                                        :required="required"
                                    ></b-form-textarea>
                                </b-form-group>

                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Personal comment (viewed by you only)"
                                    label-for="note"
                                >
                                    <b-form-textarea
                                        id="note"
                                        v-model="form.note"
                                        rows="3"
                                        max-rows="5"
                                        :required="required"
                                    ></b-form-textarea>
                                </b-form-group>
                                <b-form-group
                                    label-cols-sm="4"
                                    label-cols-lg="3"
                                    label="Your annotations"
                                    label-for="annotations"
                                >
                                    <b-input-group
                                        v-for="(annotation,index) in form.annotations"
                                        :key="index"
                                        class="mt-3"
                                    >
                                        <b-form-textarea rows="3" disabled :value="annotation" no-resize></b-form-textarea>
                                        <b-input-group-append>
                                            <b-button variant="danger" @click="removeAnnotation(index)">
                                                <icon name="minus" />
                                            </b-button>
                                        </b-input-group-append>
                                    </b-input-group>
                                </b-form-group>
                            </b-form>
                        </b-container>
                    </b-card-body>
                </b-card>
            </b-col>

            <b-col sm="3">
                <b-button
                    variant="outline-success"
                    size="lg"
                    block
                    class="shadow-sm mb-3"
                    :href="currentUrl"
                    target="_blank"
                >Duplicate</b-button>

                <b-card class="shadow-sm mb-3" header-bg-variant="white" no-body>
                    <h5 slot="header" class="d-flex align-items-center">
                        Actions
                        <b-link
                            class="ml-auto"
                            :aria-expanded="showAction ? 'true' : 'false'"
                            aria-controls="action"
                            @click="showAction = !showAction"
                        >
                            <icon :name="showAction ? 'chevron-down' : 'chevron-right'" />
                        </b-link>
                    </h5>
                    <b-card-body class="p-0 m-0">
                        <b-collapse id="action" v-model="showAction" class="m-3">
                            <ul class="submission_properties">
                                <li>
                                    <icon class="mr-1" name="newspaper" />PMID:
                                    <span class="value">
                                        <b-link
                                            v-if="variomes"
                                            :href="`https://www.ncbi.nlm.nih.gov/pubmed/${variomes.publication.id}`"
                                            target="_blank"
                                        >{{variomes.publication.id}}</b-link>
                                    </span>
                                </li>
                                <li>
                                    <icon class="mr-1" name="key" />Status:
                                    <span class="value">{{this.submitted.status || '-'}}</span>
                                </li>
                                <li>
                                    <icon class="mr-1" name="user" />Creator: <span class="value">{{this.submitted.owner_name || '-'}}</span>
                                </li>
                                <li>
                                    <icon class="mr-1" name="calendar" />Last modification: <span class="value">{{this.submitted.last_modified || '-'}}</span>
                                </li>
                            </ul>

                            <div class="d-flex align-items-center">
                                <b-link id="delete-btn" class="text-danger" :disabled="!this.submitted.id" @click="onDelete()">
                                    <icon class="mr-1" name="trash" /> Delete
                                </b-link>
                                <b-button class="ml-auto" variant="outline-success" @click="onSubmitDraft">{{is_saved ? "Update" : "Save"}} Draft</b-button>
                            </div>

                            <b-button class="mt-3" block variant="success" @click="onSubmit">Save Evidence</b-button>
                        </b-collapse>
                    </b-card-body>
                </b-card>

                <b-card class="shadow-sm" header-bg-variant="white" no-body>
                    <h5 slot="header" class="d-flex align-items-center">
                        Keywords
                        <b-link
                            class="ml-auto"
                            :aria-expanded="showStat ? 'true' : 'false'"
                            aria-controls="statistic"
                            @click="showStat = !showStat"
                        >
                            <icon :name="showStat ? 'chevron-down' : 'chevron-right'" />
                        </b-link>
                    </h5>
                    <b-card-body class="p-0 m-0">
                        <b-collapse id="statistic" v-model="showStat" class="m-3">
                            <div v-if="variomes">
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.gene}[Title/Abstract]`"
                                    target="_blank"
                                >
                                    <b-badge
                                        class="bg-gene"
                                    >{{variomes.query.gene}} ({{variomes.publication.details.query_details.targetGeneCount}})</b-badge>
                                </b-link>
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.variant}[Title/Abstract]`"
                                    target="_blank"
                                >
                                    <b-badge
                                        class="bg-variant"
                                    >{{variomes.query.variant}} ({{variomes.publication.details.query_details.targetVariantCount}})</b-badge>
                                </b-link>
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.disease}[Title/Abstract]`"
                                    target="_blank"
                                >
                                    <b-badge
                                        class="bg-disease"
                                    >{{variomes.query.disease}} ({{variomes.publication.details.query_details.targetDiseaseCount}})</b-badge>
                                </b-link>
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.gene}[Title/Abstract] AND ${variomes.query.variant}[Title/Abstract] AND ${variomes.query.disease}[Title/Abstract]`"
                                    target="_blank"
                                >
                                    <b-badge
                                        class="bg-primary"
                                    >{{variomes.query.gene}} + {{variomes.query.variant}} + {{variomes.query.disease}}</b-badge>
                                </b-link>
                                <b-link
                                    :href="`https://www.ncbi.nlm.nih.gov/pubmed/?term=${variomes.query.gene}[Title/Abstract] AND ${variomes.query.variant}[Title/Abstract]`"
                                    target="_blank"
                                >
                                    <b-badge class="bg-info">{{variomes.query.gene}} + {{variomes.query.variant}}</b-badge>
                                </b-link>
                            </div>
                            <div v-else class="text-center">
                                <b-spinner label="Spinning" variant="primary"></b-spinner>Loading
                            </div>
                        </b-collapse>
                    </b-card-body>
                </b-card>
            </b-col>
        </b-row>

        <vue-simple-context-menu
            :elementId="'annotationMenu'"
            :options="options"
            :ref="'vueSimpleContextMenu'"
            @option-clicked="optionClicked"
        />
    </b-container>
</template>

<script>
import { mapGetters } from "vuex";
import variantInformations from "@/components/curation/widgets/VariantInformations";

import fields from "@/data/curation/summary/fields.json";
import inputs from "@/data/curation/evidence/options.json";
import store from "@/store";
import { HTTP } from "@/router/http";
import SearchBar from "@/components/widgets/SearchBar";

export default {
    name: "AddEvidence",
    components: {
        SearchBar,
        variantInformations
    },
    data() {
        return {
            disease_id: null,
            fields,
            inputs,
            options: [
                {
                    name: "Add textual evidence",
                    slug: "annotate"
                },
                {
                    name: "Copy selection",
                    slug: "copy"
                }
            ],
            required: true,
            selection: "",
            showAction: true,
            showStat: true,
            variomes: null,
            type_of_evidence: {
                value: null,
                label: null
            },
            filterLabel: null,
            variants: [],
            form: {
                variants: [],
                evidence: null,
                effect: null,
                tier_criteria: null,
                origin: null,
                support: null,
                comment: null,
                note: null,
                annotations: []
            },
            // server's response after submission
            submitted: {
                id: null
            }
        };
    },
    methods: {
        test() {
            console.log("test");
        },
        getSelectionText() {
            if (window.getSelection) {
                this.selection = window.getSelection().toString();
            } else {
                this.selection = "";
            }
        },
        handleRightClick(event) {
            if (this.selection.length > 0) {
                this.$refs.vueSimpleContextMenu.showMenu(event);
            }
        },
        optionClicked(event) {
            if (event.option.slug == "copy") {
                this.doCopy();
            } else if (event.option.slug == "annotate") {
                this.form.annotations.push(this.selection);
            }
        },
        doCopy() {
            this.$copyText(this.selection).then(
                function(e) {
                    alert("Copied");
                },
                function(e) {
                    alert("Can not copy");
                }
            );
        },
        removeAnnotation(index) {
            this.form.annotations.splice(index, 1);
        },
        onSubmitDraft() {
            const payload = {
                disease: this.disease_in_svip.disease_id,
                variants: [this.variant.id, ...this.form.variants.map(x => x.id)], // selected plus the other ones
                type_of_evidence: this.form.type_of_evidence,
                drug: this.form.drug,
                effect: this.form.effect,
                tier_level_criteria: this.form.tier_level_criteria,
                tier_level: this.form.tier_level,
                mutation_origin: this.form.mutation_origin,
                summary: this.form.summary,
                support: this.form.support,
                annotations: this.form.annotations,
                references: `${this.$route.query.source}:${this.$route.query.reference}`,
                status: 'draft'
            };

            // if they've previously submitted, make it an update
            // if this is a new submission, make it a post
            (this.is_saved
                    ? HTTP.put(`/curation_entries/${this.submitted.id}`, payload)
                    : HTTP.post(`/curation_entries/`, payload)
            )
                .then((result) => {
                    this.$snotify.success(`Draft ${this.is_saved ? 'updated' : 'saved'}!`);

                    // populate submitted with the results
                    const { id, status, owner_name, last_modified } = result.data;
                    this.submitted = {
                        id: id,
                        status: status,
                        owner_name: owner_name,
                        last_modified: new Date(last_modified).toLocaleString()
                    }
                })
                .catch((err, resp) => {
                    console.log("Error: ", err, resp);
                });
        },
        onSubmit() {
            this.required = !this.required;
        },
        onDelete() {
            if (confirm("Are you sure that you want to delete this entry?")) {
                HTTP.delete(`/curation_entries/${this.submitted.id}`)
                    .then((result) => {
                        this.$snotify.info("Entry deleted");
                        this.submitted = { id: null }
                    })
            }
        },
        setEvidence() {
            this.form.evidence = this.type_of_evidence.value;
            this.filterLabel = this.type_of_evidence.label;
        },
        noResponse() {
            // FIXME: what is this supposed to do? the return value of setTimeout isn't used
            setTimeout(function() {
                return this.variomes == null ? true : false;
            }, 1000);
        }
    },
    computed: {
        ...mapGetters({
            variant: "variant"
        }),
        currentUrl() {
            return window.location.href;
        },
        effects() {
            return this.form.evidence != null
                ? Object.keys(this.inputs[this.filterLabel][this.form.evidence])
                : [];
        },
        tier_criteria() {
            return this.form.evidence != null && this.form.effect != null
                ? this.inputs[this.filterLabel][this.form.evidence][this.form.effect]
                : [];
        },
        disease_in_svip() {
            return this.variant.svip_data.diseases.find(element => element.id == this.$route.params.disease_id);
        },
        is_saved() {
            return this.submitted.id != null;
        }
    },
    created() {
        HTTP.get(`variomes_single_ref`, {
            params: {
                id: this.$route.query.reference,
                gene: this.variant.gene.symbol,
                variant: this.variant.name,
                disease: this.disease_in_svip.name
            }
        })
            .then(response => {
                this.variomes = response.data;
            })
            .catch(err => {
                this.variomes = {
                    error: "Couldn't retrieve publication info, try again later."
                };
            });
    },
    beforeRouteEnter(to, from, next) {
        const { variant_id } = to.params;

        // ask the store to populate detailed information about this variant
        store.dispatch("getGeneVariant", { variant_id: variant_id }).then(() => {
            next();
        });
    }
};
</script>

<style>
.gene {
    color: #e3639f;
    font-weight: bold;
}
.variant {
    color: #4b7bef;
    font-weight: bold;
}
.disease {
    color: #3d811e;
    font-weight: bold;
}
.bg-gene {
    background-color: #e3639f !important;
}
.bg-variant {
    background-color: #4b7bef !important;
}
.bg-disease {
    background-color: #3d811e !important;
}
.evidence ::-moz-selection {
    /* Code for Firefox */
    color: white;
    background: #2c3e50;
}

.evidence ::selection {
    color: white;
    background: #2c3e50;
}

#delete-btn.disabled {
    color: gray !important; /* and thus begin the importance wars... */
}

.submission_properties {
    margin-bottom: 1em;
    list-style-type: none;
    padding: 0;
}
.submission_properties li { margin-bottom: 0.3em; }
.submission_properties .value {
    font-weight: bold;
}
</style>
