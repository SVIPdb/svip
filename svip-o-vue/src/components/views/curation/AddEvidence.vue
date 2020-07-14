<template>
    <b-container fluid>
        <b-row v-if="pageError">
            <b-col class="page-error">
                <h1>{{ pageError.title || "Something's gone wrong " }}</h1>
                <p>{{ pageError.message }}</p>
            </b-col>
        </b-row>
        <b-row v-else-if="!checkInRole('curators') && !checkInRole('reviewers')">
            <b-col class="page-error">
                <h1>Not Authorized</h1>
                <p>You may only access this page if you're a curator or reviewer.</p>
                <router-link to="/">return to homepage</router-link>
            </b-col>
        </b-row>
        <div v-else>
            <CuratorVariantInformations :variant="variant" :disease_id="disease_id" />

            <b-row>
                <b-col sm="9">
                    <!--
                    ===========================================================================================================
                    === ABSTRACT DISPLAY
                    ===========================================================================================================
                    -->

                    <VariomesAbstract
                        :variomes="variomes"
                        citable
                        @showmenu="handleRightClick"
                        style="margin-bottom: 1.5em;"
                    />

                    <!--
                    =======================================================================================================
                    === MAIN FORM
                    =======================================================================================================
                    -->
                    <b-card no-body style="margin-bottom: 1.5em;">
                        <b-card-body>
                            <b-container fluid>
                                <ValidationObserver ref="observer" tag="b-form" @submit.prevent>
                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.disease"
                                        label="Disease"
                                        sublabel="Type in a value and press 'enter' to create a new entry. User-created entries are in italics."
                                        inner-id="disease"
                                    >
                                        <DiseaseSearchBar
                                            id="disease"
                                            allow-create
                                            v-model="form.disease"
                                            :disabled="isViewOnly"
                                            :state="checkValidity(props, true)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.type_of_evidence"
                                        label="For which type of evidence?"
                                        inner-id="evidence"
                                        required
                                    >
                                        <b-form-select
                                            id="evidence"
                                            :required="required"
                                            v-model="form.type_of_evidence"
                                            @change="evidenceTypeChanged"
                                            :disabled="isViewOnly"
                                            :state="checkValidity(props)"
                                        >
                                            <optgroup
                                                v-for="(label,index) in Object.keys(inputs)"
                                                :key="index"
                                                :label="label"
                                            >
                                                <option
                                                    v-for="(option,n) in Object.keys(inputs[label])"
                                                    :key="n"
                                                    :value="option"
                                                >{{ option }}</option>
                                            </optgroup>
                                        </b-form-select>
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.drugs"
                                        :enabled="form.type_of_evidence === 'Predictive / Therapeutic' || form.type_of_evidence === 'Response to drug'"
                                        label="For which drug?"
                                        inner-id="drug"
                                        required
                                    >
                                        <DrugSearchBar
                                            id="drug"
                                            allow-create
                                            v-model="form.drugs"
                                            multiple
                                            :disabled="isViewOnly"
                                            :state="checkValidity(props, true)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.interactions"
                                        :enabled="form.type_of_evidence === 'Interaction'"
                                        label="For which gene or chemical compound?"
                                        inner-id="interactions"
                                        required
                                    >
                                        <GeneSearchBar
                                            id="interactions"
                                            allow-create
                                            v-model="form.interactions"
                                            multiple
                                            :disabled="isViewOnly"
                                            :state="checkValidity(props, true)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.effect"
                                        label="Effect of the variant"
                                        inner-id="effect"
                                        required
                                    >
                                        <b-form-select
                                            id="effect"
                                            v-model="form.effect"
                                            :disabled="isViewOnly"
                                            :options="effects"
                                            :state="checkValidity(props, true)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.tier_criteria"
                                        :enabled="form.type_of_evidence !== 'Excluded'"
                                        label="Select a Tier or Functional criteria"
                                        inner-id="tier_criteria"
                                        required
                                    >
                                        <b-form-select
                                            id="tier_criteria"
                                            v-model="form.tier_criteria"
                                            :disabled="isViewOnly"
                                            :options="tier_criteria"
                                            :state="checkValidity(props, true)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.mutation_origin"
                                        label="Origin of the mutation"
                                        inner-id="mutation_origin"
                                        required
                                    >
                                        <b-form-select
                                            id="mutation_origin"
                                            v-model="form.mutation_origin"
                                            :disabled="isViewOnly"
                                            :options="['Somatic', 'Germline', 'Both somatic and germline', 'Unknown']"
                                            :state="checkValidity(props)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.support"
                                        label="Support"
                                        inner-id="support"
                                        required
                                    >
                                        <b-form-select
                                            id="support"
                                            v-model="form.support"
                                            :disabled="isViewOnly"
                                            :options="['Strong', 'Moderate', 'Low', 'Other']"
                                            :state="checkValidity(props)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.summary"
                                        label="Complementary information"
                                        sublabel="(viewable by everyone)"
                                        inner-id="summary"
                                        :required="form.type_of_evidence === 'Excluded'"
                                    >
                                        <b-form-textarea
                                            id="summary"
                                            v-model="form.summary"
                                            :disabled="isViewOnly"
                                            rows="3"
                                            max-rows="5"
                                            :state="checkValidity(props)"
                                        />
                                    </ValidatedFormField>

                                    <ValidatedFormField
                                        v-slot="props"
                                        :modeled="form.comment"
                                        label="Personal comment"
                                        sublabel="(viewable by you and other curators)"
                                        inner-id="comment"
                                    >
                                        <b-form-textarea
                                            id="comment"
                                            v-model="form.comment"
                                            :disabled="isViewOnly"
                                            rows="3"
                                            max-rows="5"
                                            :state="checkValidity(props)"
                                        />
                                    </ValidatedFormField>

                                    <b-form-group
                                        label="Your textual evidences"
                                        label-cols-sm="4"
                                        label-cols-lg="3"
                                    >
                                        <span
                                            v-if="form.annotations && form.annotations.length > 0"
                                        >
                                            <b-input-group
                                                v-for="(annotation,index) in form.annotations"
                                                :key="index"
                                                class="mt-3"
                                            >
                                                <b-form-textarea
                                                    rows="3"
                                                    disabled
                                                    :value="annotation"
                                                    no-resize
                                                />
                                                <b-input-group-append>
                                                    <b-button
                                                        variant="danger"
                                                        @click="removeAnnotation(index)"
                                                    >
                                                        <icon name="minus" />
                                                    </b-button>
                                                </b-input-group-append>
                                            </b-input-group>
                                        </span>
                                        <b-input-group v-else>
                                            <i
                                                class="text-muted"
                                            >(Select text in the citation summary and right-click to add a textual evidence.)</i>
                                        </b-input-group>
                                    </b-form-group>
                                </ValidationObserver>
                            </b-container>
                        </b-card-body>
                    </b-card>
                </b-col>

                <!--
                ===========================================================================================================
                === SIDEBAR
                ===========================================================================================================
                -->
                <b-col sm="3">
                    <b-button
                        variant="outline-success"
                        size="lg"
                        block
                        class="shadow-sm mb-3"
                        :href="duplicateUrl"
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
                                        <icon class="mr-1" name="newspaper" />
                                        {{ source }}:
                                        <span class="value">
                                            <b-link v-bind="pubmedURL(reference)">{{ reference }}</b-link>
                                        </span>
                                    </li>
                                    <li>
                                        <icon class="mr-1" name="key" />Status:
                                        <span class="value">{{this.form.status || '-'}}</span>
                                    </li>
                                    <li>
                                        <icon class="mr-1" name="user" />Creator:
                                        <span class="value">{{this.form.owner_name || '-'}}</span>
                                    </li>
                                    <li>
                                        <icon class="mr-1" name="calendar" />Last modification:
                                        <span
                                            class="value"
                                        >{{this.form.last_modified || '-'}}</span>
                                    </li>
                                    <li>
                                        <icon class="mr-1" name="history" />History:
                                        <span class="value">
                                            <b-link
                                                v-if="form.id"
                                                @click="showHistory()"
                                            >show revisions</b-link>
                                        </span>
                                    </li>
                                </ul>

                                <div class="d-flex align-items-center">
                                    <b-link
                                        id="delete-btn"
                                        class="text-danger"
                                        :disabled="!form.id || form.status === 'submitted'"
                                        @click="onDelete()"
                                    >
                                        <icon class="mr-1" name="trash" />Delete
                                    </b-link>
                                    <b-button
                                        class="ml-auto"
                                        variant="outline-success"
                                        @click="onSubmitDraft"
                                        :disabled="form.status === 'submitted'"
                                    >{{is_saved ? "Update" : "Save"}} Draft</b-button>
                                </div>

                                <b-button
                                    class="mt-3"
                                    block
                                    variant="success"
                                    :disabled="form.status === 'submitted'"
                                    @click="onSubmit"
                                >Save Evidence</b-button>
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
                                <div
                                    v-if="variomes && variomes.publications && variomes.publications.length > 0"
                                >
                                    <b-link
                                        v-for="(entry, idx) in keywordSet" :key="idx"
                                        v-bind="pubmedURL(entry.url)"
                                    >
                                        <b-badge
                                            :class="entry.class"
                                        >{{ entry.label }}{{ entry.count !== undefined ? ` (${entry.count})` : ''}}</b-badge>
                                    </b-link>
                                </div>
                                <div
                                    v-else-if="variomes"
                                    class="text-muted text-center font-italic"
                                >
                                    <icon
                                        name="exclamation-triangle"
                                        scale="1.5"
                                        style="vertical-align: text-bottom; margin-right: 5px;"
                                    />An error occurred while retrieving this PMID
                                </div>
                                <div v-else class="text-center">
                                    <b-spinner label="Spinning" variant="primary" />loading...
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

            <b-modal
                ref="history-modal"
                static
                lazy
                scrollable
                size="lg"
                :title="`Entry #${form.id || '???'} History`"
            >
                <div style="padding-bottom: 6em;">
                    <EvidenceHistory v-if="form.id" :entry_id="form.id" />
                    <div v-else>Error: no curation entry selected</div>
                </div>
            </b-modal>
        </div>
    </b-container>
</template>

<script>
import { mapGetters } from "vuex";
import BroadcastChannel from "broadcast-channel";
import CuratorVariantInformations from "@/components/curation/widgets/CuratorVariantInformations";
import inputs from "@/data/curation/evidence/options.json";
import store from "@/store";
import { HTTP } from "@/router/http";
import { extend, ValidationObserver } from "vee-validate";
import DrugSearchBar from "@/components/widgets/DrugSearchBar";
import GeneSearchBar from "@/components/widgets/GeneSearchBar";
import ValidatedFormField from "@/components/curation/widgets/ValidatedFormField";
import { required } from "vee-validate/dist/rules";
import EvidenceHistory from "@/components/curation/widgets/EvidenceHistory";
import { checkInRole } from "@/directives/access";
import dayjs from "dayjs";
import DiseaseSearchBar from "@/components/widgets/DiseaseSearchBar";
import VariomesAbstract from "@/components/curation/widgets/VariomesAbstract";
import { pubmedURL } from "@/utils";
import ulog from 'ulog';

const log = ulog('Curation:AddEvidence')

// options.json's top-level organization by separator makes it difficult to index the structure
// by just what we store in the database, since you also need to know (unstored) the top-level category.
// here we flatten the internal elements, since they're still indicative of the structure.
const effect_set = Object.values(inputs).reduce(
    (acc, x) => Object.assign(acc, x),
    {}
);

// used to extract tier_level and tier_level_criteria (fields in the model) from the combined string tier_criteria
const tier_criteria_parser = /(?<tier_level_criteria>.+) \((?<tier_level>.+)\)/;

extend("required", {
    ...required,
    message: "This field is required"
});

export default {
    name: "AddEvidence",
    components: {
        VariomesAbstract,
        DiseaseSearchBar,
        EvidenceHistory,
        ValidatedFormField,
        DrugSearchBar,
        GeneSearchBar,
        CuratorVariantInformations,
        ValidationObserver
    },
    data() {
        return {
            inputs,
            // if non-null, displays pageError instead of the contents of the page; use this for fatal errors
            pageError: null,
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
            enableRequired: false,
            selection: "",
            showAction: true,
            showStat: true,

            // used to communicate curation changes across tabs to the evidencecard component
            channel: new BroadcastChannel("curation-update"),

            source: null, // usually "PMID"; either populated by the querystring or by loading an entry
            reference: null, // the PMID of the reference, populated like 'source' above
            variomes: null,

            form: {
                // these fields are empty or populated on submission/load
                id: null,
                status: null,
                owner_name: null,
                last_modified: null,

                // these fields are bound to form elements and populated on load
                disease: null,
                variant: null,
                extra_variants: [],
                type_of_evidence: null,
                drugs: [],
                interactions: [],
                effect: null,
                tier_criteria: null,
                mutation_origin: null,
                support: null,
                summary: null,
                comment: null,
                annotations: []
            }
        };
    },
    methods: {
        checkInRole,
        pubmedURL,

        handleRightClick({ event, selection }) {
            this.selection = selection;
            if (this.selection.length > 0) {
                this.$refs.vueSimpleContextMenu.showMenu(event);
            }
        },
        optionClicked(event) {
            if (event.option.slug === "copy") {
                this.$copyText(this.selection).then(
                    () => {
                        this.$snotify.info("Copied text");
                    },
                    () => {
                        this.$snotify.warn("Couldn't copy it");
                    }
                );
            } else if (event.option.slug === "annotate") {
                if (this.isViewOnly) {
                    this.$snotify.warning("Can't alter a submitted entry");
                    return;
                }

                this.$snotify.info("Added selection to annotations", {
                    position: "centerBottom"
                });
                this.form.annotations.push(this.selection);
            }
        },

        evidenceTypeChanged() {
            // when the type of evidence changes, we clear its dependent fields
            // (otherwise, they might still hold values despite not appearing to due their options changing)
            this.form.drugs = [];
            this.form.effect = null;
            this.form.tier_criteria = null;
        },
        loadVariomeData() {
            // FIXME: we should ensure that we have a variant before we fire this off somehow...
            HTTP.get(`variomes_single_ref`, {
                params: {
                    id: this.reference.trim(),
                    genvars: `${this.variant.gene.symbol} (${this.variant.name})`,
                    disease: this.form.disease && this.form.disease.name
                }
            })
                .then(response => {
                    this.variomes = response.data;
                })
                .catch(err => {
                    log.error(err);
                    this.variomes = {
                        error:
                            "Couldn't retrieve publication info, try again later."
                    };
                });
        },
        removeAnnotation(index) {
            if (this.isViewOnly) {
                this.$snotify.warning("Can't alter a submitted entry");
                return;
            }

            this.form.annotations.splice(index, 1);
        },
        load() {
            // optionally loads curation entry data from the server; always kicks off loading variome data
            // 1. for new entries, the citation source and reference will come from the querystring
            // 2. for existing entries, the source and reference come from the entry data

            const { action } = this.$route.params;

            if (action === "add") {
                const { source, reference } = this.$route.query;

                if (!source || !reference) {
                    this.pageError = {
                        message:
                            "Required querystring params 'source' and/or 'reference' are missing."
                    };
                    return;
                }

                this.source = source.trim();
                this.reference = reference.trim();
                this.loadVariomeData();
            } else {
                HTTP.get(`/curation_entries/${action}`)
                    .then(response => {
                        this.rehydrate(response.data); // populates source, reference from the response
                        this.loadVariomeData(); // and finally load the data
                    })
                    .catch(err => {
                        if (err.response && err.response.status === 404) {
                            // the curation entry doesn't exist, so we redirect to the 404 page
                            this.$router.push({ name: "not-found" });
                        } else {
                            // pass the error on unchanged
                            throw err;
                        }
                    });
            }
        },
        rehydrate(data) {
            // given some fetched data, populates all our local fields with the server's data for this entry
            // populate form + hidden fields with results

            // some of the fields have to be specially handled, so we remove them from the server's payload
            const {
                variant,
                formatted_variants,
                last_modified,
                tier_level,
                tier_level_criteria,
                annotations,
                references,
                ...rest
            } = data;

            // repopulating variants is annoying since they're split up between the 'main' variant
            // and the extra variants in the "add variants" box.
            // we'll go with the convention that the first one is the 'main' variant and the rest, if any, are the
            // extra variants
            const extra_variants = formatted_variants;
            this.variant.id = variant.id;

            // repopulate the form, which will bind the elements in the page
            this.form = {
                ...rest,
                extra_variants: extra_variants,
                tier_criteria: tier_level
                    ? `${tier_level_criteria} (${tier_level})`
                    : tier_level_criteria,
                annotations: annotations || [],
                last_modified: dayjs(last_modified).format("DD.MM.YYYY, h:mm a")
            };

            // also populate source and ID, which we need to populate the publication info
            [this.source, this.reference] = references.trim().split(":");
        },
        async submit(isDraft) {
            // manually validate all the fields before we go any further
            if (!isDraft) {
                // use the validation observer to validate every provider at once
                // this will update the UI with 'this is required' as well
                const isValid = await this.$refs.observer.validate();

                if (!isValid) {
                    return;
                }
            }

            // we need to unpack the form field 'tier_criteria' into 'tier_level' and 'tier_level_criteria'
            const matched = tier_criteria_parser.exec(this.form.tier_criteria);
            const { tier_level, tier_level_criteria } = matched
                ? matched.groups
                : {
                    tier_level: null,
                    tier_level_criteria: this.form.tier_criteria
                };

            const payload = {
                disease: this.form.disease, // this.form.disease.id,
                variant: this.variant.id,
                extra_variants: this.form.extra_variants
                    ? this.form.extra_variants.map(x => x.id)
                    : [], // selected plus the other ones

                type_of_evidence: this.form.type_of_evidence,
                drugs: this.form.drugs || [],
                interactions: this.form.interactions || [],
                effect: this.form.effect,
                tier_level_criteria: tier_level_criteria,
                tier_level: tier_level,
                mutation_origin: this.form.mutation_origin,
                summary: this.form.summary,
                support: this.form.support,
                comment: this.form.comment,
                annotations: this.form.annotations,

                references: `${this.source}:${this.reference}`,
                status: isDraft ? "draft" : "saved"
            };

            // if they've previously submitted, make it an update
            // if this is a new submission, make it a post
            (this.is_saved
                ? HTTP.put(`/curation_entries/${this.form.id}`, payload)
                : HTTP.post(`/curation_entries/`, payload)
            )
                .then(result => {
                    this.$snotify.success(
                        `${isDraft ? "Draft" : "Entry"} ${
                            this.is_saved ? "updated" : "saved"
                        }!`
                    );

                    // refresh curation lists on other pages
                    this.channel.postMessage(`Refreshed ID ${result.data.id}`);

                    // it takes a while for a navigation change (below) to update the UI, so we'll prematurely
                    // update it here with the server's response (and then overwrite it when the nav change comes
                    // through, but that's fine)
                    this.rehydrate(result.data);

                    // if we were adding a new entry, redirect to the page for this new entry
                    // otherwise, we're presumbaly already on the right page
                    if (this.$route.params.action === "add") {
                        this.$router.replace({
                            name: "add-evidence",
                            params: {
                                ...this.$route.params,
                                action: result.data.id
                            }
                        });
                    }
                })
                .catch((err) => {
                    if (err.response) {
                        if (err.response.status == 403) {
                            this.$snotify.error(
                                "Submitted entries can't be changed!"
                            );
                            return;
                        }
                        if (err.response.status == 400) {
                            const failedKeys = Object.keys(
                                err.response.data
                            ).join(", ");
                            this.$snotify.error(
                                `Validation failed for these fields: ${failedKeys}`
                            );
                            return;
                        }
                    }

                    // TODO: deal with the server's error response in err.response.data
                    //  to bind error messages to form elements.
                    log.warn("Error when saving: ", err);
                });
        },
        onSubmitDraft() {
            this.submit(true);
        },
        onSubmit() {
            this.submit(false);
        },
        onDelete() {
            if (confirm("Are you sure that you want to delete this entry?")) {
                HTTP.delete(`/curation_entries/${this.form.id}`).then(
                    result => {
                        // refresh curation lists on other pages
                        this.channel.postMessage(
                            `Deleted ID ${result.data.id}`
                        );

                        this.$snotify.info("Entry deleted");
                        this.form.id = null;
                        this.pageError = {
                            title: "Entry Deleted",
                            message: "You may now close this window/tab."
                        };
                    }
                );
            }
        },
        checkValidity(props, withoutChange) {
            return props.invalid && (withoutChange || !props.changed)
                ? false
                : null;
        },
        showHistory() {
            this.$refs["history-modal"].show();
        }
    },
    computed: {
        ...mapGetters({
            variant: "variant"
        }),
        duplicateUrl() {
            const [source, reference] = this.form.references
                ? this.form.references.split(":")
                : [this.source, this.reference];

            return this.$router.resolve({
                name: "add-evidence",
                params: {
                    ...this.$route.params,
                    action: "add"
                },
                query: {
                    source,
                    reference
                }
            }).href;
        },
        keywordSet() {
            if (!this.variomes) return [];

            const { gene, variant, disease } = {
                gene: this.variomes.query.genes_variants[0].gene,
                variant: this.variomes.query.genes_variants[0].variant,
                disease: this.variomes.query.diseases[0]
            };
            const counts = this.variomes.publications[0].details.query_details;

            return [
                {
                    class: "bg-gene",
                    url: `?term=${gene}[Title/Abstract]`,
                    label: gene,
                    count: counts.query_gene_count.all
                },
                {
                    class: "bg-variant",
                    url: `?term=${variant}[Title/Abstract]`,
                    label: variant,
                    count: counts.query_variant_count.all
                },
                {
                    class: "bg-disease",
                    url: `?term=${disease}[Title/Abstract]`,
                    label: disease,
                    count: counts.query_disease_count.all
                },
                {
                    class: "bg-primary",
                    url: `?term=${gene}[Title/Abstract] AND ${variant}[Title/Abstract] AND ${disease}[Title/Abstract]`,
                    label: `${gene} + ${variant} + ${disease}`
                },
                {
                    class: "bg-info",
                    url: `?term=${gene}[Title/Abstract] AND ${variant}[Title/Abstract]`,
                    label: `${gene} + ${variant}`
                }
            ];
        },
        effects() {
            // return this.form.type_of_evidence != null
            //     ? Object.keys(this.inputs[this.filterLabel][this.form.type_of_evidence])
            //     : [];
            return this.form.type_of_evidence &&
                effect_set[this.form.type_of_evidence]
                ? Object.keys(effect_set[this.form.type_of_evidence])
                : [];
        },
        tier_criteria() {
            return this.form.type_of_evidence && this.form.effect
                ? effect_set[this.form.type_of_evidence][this.form.effect]
                : [];
        },
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        },
        is_saved() {
            return this.form.id != null;
        },
        isViewOnly() {
            return this.form.id && this.form.status === "submitted";
        }
    },
    mounted() {
        this.load();
    },
    watch: {
        $route: "load"
    },
    beforeRouteEnter(to, from, next) {
        store
            .dispatch("getGeneVariant", { variant_id: to.params.variant_id })
            .then(() => {
                next();
            });
    },
    beforeRouteUpdate(to, from, next) {
        store
            .dispatch("getGeneVariant", { variant_id: to.params.variant_id })
            .then(() => {
                next();
            });
    }
};
</script>

<style>
.page-error {
    text-align: center;
    margin-top: 3em;
}

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
.submission_properties li {
    margin-bottom: 0.3em;
}
.submission_properties .value {
    font-weight: bold;
}
</style>
