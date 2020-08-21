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
                                <b-row class="pb-2">
                                    <b-col cols="3">Disease</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">For which type of evidence?</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">For which drug?</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">For which interactor?</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Effect of the variant</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Tier or Functional criteria</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Origin of the mutation</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Associated Mendelian disease(s)</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Support</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Summary</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Personnal comment</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>

                                <b-row class="pb-2">
                                    <b-col cols="3">Your textual evidences</b-col>
                                    <b-col cols="8">...</b-col>
                                </b-row>
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
                                        <icon class="mr-1" name="user" />Creator:
                                        <span class="value">{{this.form.owner_name || '-'}}</span>
                                    </li>
                                    <li>
                                        <icon class="mr-1" name="calendar" />Last modification:
                                        <span
                                            class="value"
                                        >{{this.form.last_modified || '-'}}</span>
                                    </li>
                                </ul>

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

        </div>
    </b-container>
</template>

<script>
import { mapGetters } from "vuex";
import BroadcastChannel from "broadcast-channel";
import CuratorVariantInformations from "@/components/widgets/curation/CuratorVariantInformations";
import inputs from "@/data/curation/evidence/options.json";
import store from "@/store";
import { HTTP } from "@/router/http";
import { extend, ValidationObserver } from "vee-validate";
import DrugSearchBar from "@/components/widgets/searchbars/DrugSearchBar";
import ValidatedFormField from "@/components/widgets/curation/ValidatedFormField";
import { required } from "vee-validate/dist/rules";
import EvidenceHistory from "@/components/widgets/curation/EvidenceHistory";
import { checkInRole } from "@/directives/access";
import dayjs from "dayjs";
import DiseaseSearchBar from "@/components/widgets/searchbars/DiseaseSearchBar";
import VariomesAbstract from "@/components/widgets/curation/VariomesAbstract";
import { pubmedURL } from "@/utils";
import ulog from 'ulog';
import InteractorSearchBar from "@/components/widgets/searchbars/InteractorSearchBar";

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
        CuratorVariantInformations
    },
    data() {
        return {
            inputs,
            // if non-null, displays pageError instead of the contents of the page; use this for fatal errors
            pageError: null,
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
                associated_mendelian_diseases: null,
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
        load() {
            // optionally loads curation entry data from the server; always kicks off loading variome data
            // 1. for new entries, the citation source and reference will come from the querystring
            // 2. for existing entries, the source and reference come from the entry data

            const { evidence_id } = this.$route.params;

            HTTP.get(`/curation_entries/${evidence_id}`)
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
        },
    },
    computed: {
        ...mapGetters({
            variant: "variant"
        }),
        keywordSet() {
            if (!this.variomes) return [];

            const { gene, variant, disease } = {
                gene: this.variomes.normalized_query.genes[0].preferred_term,
                variant: this.variomes.normalized_query.variants[0].preferred_term,
                disease: this.variomes.normalized_query.diseases && this.variomes.normalized_query.diseases[0].preferred_term
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
                disease && {
                    class: "bg-disease",
                    url: `?term=${disease}[Title/Abstract]`,
                    label: disease,
                    count: counts.query_disease_count.all
                },
                disease && {
                    class: "bg-primary",
                    url: `?term=${gene}[Title/Abstract] AND ${variant}[Title/Abstract] AND ${disease}[Title/Abstract]`,
                    label: `${gene} + ${variant} + ${disease}`
                },
                {
                    class: "bg-info",
                    url: `?term=${gene}[Title/Abstract] AND ${variant}[Title/Abstract]`,
                    label: `${gene} + ${variant}`
                }
            ].filter(x => x);
        },
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        },
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
