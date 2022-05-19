<template>
    <b-container fluid class="pt-3">
        <b-row>
            <b-col md="12">
                <h1>Submit Variants</h1>

                <p>
                    You can submit variants for us to add to the SVIP database
                    here. Submitted variants are entered into a queue, which
                    will be processed when the variant harvesting pipeline is
                    run.
                </p>

                <p>
                    You can check the status of all submitted variants,
                    including your own, on the "Submission Queue" tab below.
                </p>
            </b-col>
        </b-row>

        <b-row>
            <b-col md="12">
                <b-card no-body>
                    <b-tabs card :class="`svip-details-tabs`">
                        <b-tab title="Submit Variants">
                            <div class="m-3">
                                <b-form-radio-group v-model="submitMode">
                                    <b-form-radio value="single"
                                        >Submit a single variant</b-form-radio
                                    >
                                    <b-form-radio value="vcf"
                                        >Upload a VCF with multiple
                                        variants</b-form-radio
                                    >
                                </b-form-radio-group>
                            </div>

                            <div class="m-3" v-if="submitMode === 'single'">
                                <hr />
                                <h4>Option 1. Individual Variant</h4>

                                <b-form @submit.stop.prevent="submitVariant">
                                    <b-row class="p-0 m-0">
                                        <b-col md="4" class="p-0">
                                            <b-form-group label="Chromosome">
                                                <b-form-select
                                                    v-model="chromosome"
                                                    :options="chromosomes"
                                                />
                                            </b-form-group>

                                            <b-form-group
                                                label="Position (GRCh37)"
                                                description="the position within the selected chromosome"
                                            >
                                                <b-input
                                                    type="number"
                                                    v-model="pos"
                                                />
                                            </b-form-group>

                                            <b-form-group
                                                label="Ref"
                                                description="The reference base(s) at the position, in VCF (v4.0) format"
                                            >
                                                <b-input
                                                    type="text"
                                                    v-model="ref"
                                                />
                                            </b-form-group>

                                            <b-form-group label="Alt">
                                                <b-input
                                                    type="text"
                                                    v-model="alt"
                                                />
                                                <b-form-text>
                                                    The changed base(s) at the
                                                    position, in VCF (v4.0)
                                                    format.<br />
                                                    Use a period (.) to indicate
                                                    a deletion, and commas to
                                                    indicate multiple mappings.
                                                </b-form-text>
                                            </b-form-group>

                                            <b-form-group>
                                                <b-checkbox
                                                    v-model="canonical_only"
                                                >
                                                    Include only VEP variants
                                                    marked 'CANONICAL' in the
                                                    results.
                                                </b-checkbox>
                                            </b-form-group>
                                        </b-col>

                                        <b-col md="4" class="p-0 pl-4">
                                            <b-card class="bg-light">
                                                <b-form
                                                    @submit.stop.prevent="
                                                        mapHGVS
                                                    "
                                                    class="mb-4"
                                                >
                                                    <b-form-group
                                                        label="Map HGVS to Pos/Ref/Alt"
                                                    >
                                                        <template
                                                            slot="description"
                                                        >
                                                            <div>
                                                                Convert this
                                                                HGVS string
                                                                (either genomic
                                                                or coding)
                                                                identifying a
                                                                SNP to VCF
                                                                format, filling
                                                                the fields with
                                                                the result.
                                                            </div>
                                                            <div class="mt-2">
                                                                Coding HGVS
                                                                strings will be
                                                                converted to
                                                                genomic strings.
                                                            </div>
                                                        </template>

                                                        <b-form-input
                                                            type="text"
                                                            name="hgvs_str"
                                                            placeholder="e.g., NM_001637.3:c.1582G>A"
                                                            v-model="hgvs_str"
                                                        />
                                                    </b-form-group>

                                                    <div
                                                        class="d-flex align-items-center"
                                                    >
                                                        <b-button
                                                            variant="warning"
                                                            type="submit"
                                                            :disabled="
                                                                !hgvs_str ||
                                                                loading_hgvs
                                                            "
                                                        >
                                                            Convert HGVS to
                                                            Variant
                                                        </b-button>
                                                        <b-spinner
                                                            v-if="loading_hgvs"
                                                            class="ml-2"
                                                            small
                                                        />
                                                    </div>
                                                </b-form>
                                            </b-card>
                                        </b-col>
                                    </b-row>

                                    <b-row class="p-0 m-0">
                                        <b-col md="8" class="p-0">
                                            <hr />
                                            <CreateCurationRequest
                                                v-model="curationReq"
                                            />
                                            <b-button
                                                variant="success"
                                                type="submit"
                                                :disabled="!all_fields_valid"
                                                >Submit Variant</b-button
                                            >
                                        </b-col>
                                    </b-row>
                                </b-form>
                            </div>

                            <div class="m-3" v-if="submitMode === 'vcf'">
                                <hr />
                                <h4>
                                    Option 2. Upload a VCF w/Multiple Variants
                                </h4>
                                <b-form @submit.stop.prevent="uploadVCF">
                                    <b-form-group label="VCF File">
                                        <b-form-file v-model="vcf_file" />
                                    </b-form-group>

                                    <b-form-group>
                                        <b-checkbox v-model="canonical_only">
                                            Include only VEP variants marked
                                            'CANONICAL' in the results.
                                        </b-checkbox>
                                    </b-form-group>

                                    <hr />

                                    <CreateCurationRequest
                                        v-model="curationReq"
                                    />

                                    <b-button
                                        variant="info"
                                        type="submit"
                                        :disabled="!vcf_file"
                                        >Upload VCF</b-button
                                    >
                                </b-form>
                            </div>
                        </b-tab>
                        <b-tab title="Submission Queue">
                            <template slot="title">
                                Submission Queue
                                <b-badge v-if="numRowsInQueue !== null">{{
                                    numRowsInQueue
                                }}</b-badge>
                            </template>
                            <SubmissionQueue
                                has-header
                                header-title="SUBMITTED VARIANTS"
                                cardHeaderBg="secondary"
                                cardTitleVariant="white"
                                small
                                @data-loaded="
                                    (data) => {
                                        numRowsInQueue = data.count;
                                    }
                                "
                            />
                        </b-tab>
                    </b-tabs>
                </b-card>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import PagedTable from "@/components/widgets/PagedTable";
import SubmissionQueue from "@/components/widgets/submission/SubmissionQueue";
import { HTTP } from "@/router/http";
import BroadcastChannel from "broadcast-channel";
import ulog from "ulog";
import CreateCurationRequest from "@/components/widgets/submission/CreateCurationRequest";

const log = ulog("SubmitVariants");
// eslint-disable-next-line
const re_email =
    /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;

export default {
    name: "SubmitVariants",
    components: { CreateCurationRequest, SubmissionQueue },
    data() {
        return {
            submitMode: null,

            // look up HGVS string
            hgvs_str: null,
            loading_hgvs: false,

            // submit single variant
            chromosome: null,
            pos: null,
            ref: null,
            alt: null,

            // upload VCF
            vcf_file: null,

            // shared between single/VCF
            curationReq: null, // info about the curation request to create, if specified
            canonical_only: false,

            // used to communicate submission changes across tabs to the evidencecard component
            channel: new BroadcastChannel("submission-update"),
            numRowsInQueue: null,
        };
    },
    computed: {
        chromosomes() {
            return Array.from({ length: 22 })
                .map((_, idx) => (idx + 1).toString())
                .concat(["X", "Y", "MT"]);
        },
        all_fields_valid() {
            console.log("curationReq", this.curationReq);
            return (
                this.chromosome !== null &&
                this.chromosomes.includes(this.chromosome) &&
                this.pos !== null &&
                !isNaN(Number.parseInt(this.pos)) &&
                this.ref !== null &&
                this.alt !== null &&
                (this.curationReq === null ||
                    (this.curationReq.for_curation_request === true
                        ? this.curationReq.requestor !== null &&
                          this.curationReq.requestor.match(re_email) &&
                          this.curationReq.icdo_morpho !== null &&
                          this.curationReq.icdo_topo !== null &&
                          this.curationReq.icdo_topo.length > 0
                        : true))
            );
        },
    },
    methods: {
        mapHGVS() {
            this.loading_hgvs = true;
            HTTP.get(`/submitted_variants/map_hgvs?hgvs_str=${this.hgvs_str}`)
                .then((result) => {
                    const data = result.data;

                    this.chromosome = data.chromosome;
                    this.pos = data.pos;
                    this.ref = data.ref;
                    this.alt = data.alt;
                    this.hgvs_str = data.full_result;

                    this.$snotify.success("HGVS string parsed!");
                })
                .catch((err) => {
                    if (err.response) {
                        if (err.response.status === 400) {
                            this.$snotify.error(
                                `Error: ${err.response.data.error}`
                            );
                            return;
                        }
                        if (err.response.status >= 500) {
                            this.$snotify.error(
                                "Server error occurred while mapping HGVS"
                            );
                        }
                    }

                    // TODO: deal with the server's error response in err.response.data
                    //  to bind error messages to form elements.
                    log.warn("Error when looking up HGVS string: ", err);
                })
                .finally(() => {
                    this.loading_hgvs = false;
                });
        },
        submitVariant() {
            const payload = {
                chromosome: this.chromosome,
                pos: this.pos,
                ref: this.ref,
                alt: this.alt,
                canonical_only: this.canonical_only,
                ...(this.curationReq ? this.curationReq : {}),
            };

            HTTP.post(`/submitted_variants/`, payload)
                .then((result) => {
                    this.$snotify.success("Submission added to queue!");

                    // refresh curation lists on other pages
                    this.channel.postMessage(`Refreshed ID ${result.data.id}`);
                })
                .catch((err) => {
                    if (err.response) {
                        if (err.response.status === 400) {
                            const failedKeys = Object.keys(
                                err.response.data
                            ).join(", ");
                            this.$snotify.error(
                                `Validation failed for these fields: ${failedKeys}`
                            );
                            return;
                        }
                        if (err.response.status >= 500) {
                            this.$snotify.error(
                                "Server error occurred while saving"
                            );
                        }
                    }

                    // TODO: deal with the server's error response in err.response.data
                    //  to bind error messages to form elements.
                    log.warn("Error when saving: ", err);
                });
        },
        uploadVCF() {
            const payload = new FormData();
            payload.append("vcf_file", this.vcf_file);
            payload.append("canonical_only", this.canonical_only);

            if (this.curationReq) {
                Object.entries(this.curationReq).forEach(([k, v]) => {
                    payload.append(k, v);
                });
            }

            HTTP.post(`/submitted_variant_batches/`, payload, {
                headers: { "Content-Type": "multipart/form-data" },
            })
                .then((result) => {
                    this.$snotify.success("Submission batch added to queue!");
                    this.vcf_file = null;

                    // refresh curation lists on other pages
                    this.channel.postMessage(`Refreshed ID ${result.data.id}`);
                })
                .catch((err) => {
                    if (err.response) {
                        if (err.response.status === 400) {
                            const failedKeys = Object.keys(
                                err.response.data
                            ).join(", ");
                            this.$snotify.error(
                                `Validation failed for these fields: ${failedKeys}`
                            );
                            return;
                        }
                        if (err.response.status >= 500) {
                            this.$snotify.error(
                                "Server error occurred while saving"
                            );
                        }
                    }

                    // TODO: deal with the server's error response in err.response.data
                    //  to bind error messages to form elements.
                    log.warn("Error when saving: ", err);
                });
        },
    },
};
</script>

<style scoped></style>
