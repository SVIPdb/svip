import { html, PolymerElement } from "@polymer/polymer/polymer-element.js";
import "@polymer/polymer/lib/elements/dom-repeat.js";
import "@polymer/polymer/lib/elements/dom-if.js";
import "./pubmed-section-v2.js";
import "./shared-style.js";
/**
 * `pubmed-viewer-v2`
 *
 *
 * @customElement
 * @polymer
 * @demo demo/pubmed-viewer-v2.html
 */

class PubmedViewerV2 extends PolymerElement {
    static get template() {
        return html`
            <style include="shared-style">
                :host {
                    display: block;
                    margin: 2px;
                    padding: 2px;
                    padding-left: 16px;
                    padding-right: 16px;
                    border: 1px solid lightgray;
                    overflow: scroll;
                    background-color: inherited;
                }

                .viewer-hdr {
                    font-family: Sans-serif;
                    font-size: 12px;
                    color: gray;
                    display: flex;
                    flex-direction: row;
                    flex-wrap: nowrap;
                    justify-content: space-between;
                }
            </style>

            <div class="viewer-hdr">
                <span>
                    <input
                        type="checkbox"
                        on-change="_handle_checkbox_change"
                        checked="[[showlinks]]"
                    /><span>Show concept links</span>
                </span>
                <span style="padding-top:5px;">PMCA viewer v1.2</span>
            </div>
            <hr />
            <p>
                <span>[[publi.medline_ta]]</span> -
                <span>[[publi.publication_date]]</span> -
                <span
                    >[[publi.volume]]([[publi.issue]]):[[publi.medline_pgn]].</span
                >
                <template is="dom-if" if="{{_hasValue(publi.pmcid)}}">
                    <span> - PMCID: </span
                    ><a
                        target="_blank"
                        href="https://www.ncbi.nlm.nih.gov/pmc/articles/[[publi.pmcid]]/"
                        >[[publi.pmcid]]</a
                    >
                </template>
                <template is="dom-if" if="{{_hasValue(publi.pmid)}}">
                    <span> - PMID: </span
                    ><a
                        target="_blank"
                        href="https://www.ncbi.nlm.nih.gov/pubmed/?term=[[publi.pmid]]"
                        >[[publi.pmid]]</a
                    >
                </template>
                <template is="dom-if" if="{{_hasValue(publi.doi)}}">
                    <span> - DOI: </span
                    ><a target="_blank" href="https://dx.doi.org/[[publi.doi]]"
                        >[[publi.doi]]</a
                    >
                </template>
            </p>
            <p>
                Author(s):
                <dom-repeat items="[[publi.authors]]">
                    <template>
                        [[item.last_name]] [[item.initials]]
                        <sup>{{_getPmcaAffiliationLabels(item)}}</sup>
                        {{_getSeparator(index,publi.authors)}}
                    </template>
                </dom-repeat>
            </p>
            <p>
                Affiliation(s):
                <dom-repeat items="[[publi.affiliations]]">
                    <template>
                        <div class="publi-affiliation-div">
                            <span class="publi-affiliation-label"
                                >{{_getPmcaAffiliationLabel(index)}}</span
                            >
                            [[item.name]]
                        </div>
                    </template>
                </dom-repeat>
            </p>

            <dom-repeat items="[[publi.body_sections]]">
                <template>
                    <div class$="{{_getClassForSectionLabelAndTitle(item)}}">
                        {{_getTextForSectionLabelAndTitle(item)}}
                        <span class$="{{_getClassForDebug(debug)}}"
                            >id: [[item.id]]</span
                        >
                    </div>

                    <pubmed-section-v2
                        nohighlight="[[nohighlight]]"
                        showlinks="[[showlinks]]"
                        debug="[[debug]]"
                        data="[[item]]"
                        fsccount="[[fsccount]]"
                        filters="[[filters]]"
                    ></pubmed-section-v2>
                </template>
            </dom-repeat>

            <template is="dom-if" if="{{_hasFloatSections(publi)}}">
                <hr />
                <i>Floating sections</i>
                <hr />

                <dom-repeat items="[[publi.float_sections]]">
                    <template>
                        <div
                            class$="{{_getClassForSectionLabelAndTitle(item)}}"
                        >
                            {{_getTextForSectionLabelAndTitle(item)}}
                            <span class$="{{_getClassForDebug(debug)}}"
                                >id: [[item.id]]</span
                            >
                        </div>

                        <pubmed-section-v2
                            nohighlight="[[nohighlight]]"
                            debug="[[debug]]"
                            data="[[item]]"
                            fsccount="[[fsccount]]"
                            filters="[[filters]]"
                        ></pubmed-section-v2>
                    </template>
                </dom-repeat>
            </template>

            <template
                is="dom-if"
                if="{{_hasBackSections(publi, showbacksections)}}"
            >
                <hr />
                <i>Back sections</i>
                <hr />

                <dom-repeat items="[[publi.back_sections]]">
                    <template>
                        <div
                            class$="{{_getClassForSectionLabelAndTitle(item)}}"
                        >
                            {{_getTextForSectionLabelAndTitle(item)}}
                            <span class$="{{_getClassForDebug(debug)}}"
                                >id: [[item.id]]</span
                            >
                        </div>

                        <pubmed-section-v2
                            nohighlight="[[nohighlight]]"
                            debug="[[debug]]"
                            data="[[item]]"
                            fsccount="[[fsccount]]"
                            filters="[[filters]]"
                        ></pubmed-section-v2>
                    </template>
                </dom-repeat>
            </template>
        `;
    }

    static get properties() {
        return {
            publi: {
                type: Object,
            },
            debug: {
                type: Boolean,
                value: false,
            },
            showbacksections: {
                type: Boolean,
                value: false,
            },
            showlinks: {
                type: Boolean,
                value: false,
            },
            nohighlight: {
                type: Boolean,
                value: false,
            },
            fsccount: {
                type: Number,
                value: 0,
            },
            // filter state change counter
            filters: {
                type: Array,
                value: null,
            },
        };
    }

    _handle_checkbox_change(e) {
        var trg = e.target || e.srcElement;
        console.log("checked:", trg.checked);
        this.showlinks = trg.checked;
    } // The label provided n the affiliation object is not reliable,
    // we just use the position in the array + 1

    _getPmcaAffiliationLabel(i) {
        return String(i + 1);
    }

    _getClassForSectionLabelAndTitle(item) {
        return item.title == "Title" ? "" : "publi-h" + item.level;
    }

    _hasFloatSections(item) {
        return item.float_sections && item.float_sections.length > 0;
    }

    _hasBackSections(item) {
        if (typeof item == "undefined") return false;
        return (
            this.showbacksections &&
            item.back_sections &&
            item.back_sections.length > 0
        );
    }

    _getTextForSectionLabelAndTitle(item) {
        return item.title == "Title"
            ? ""
            : (item.label + " " + item.title).trim();
    }

    _getClassForDebug() {
        return this.debug ? "publi-debug-info" : "publi-debug-info-hidden";
    }

    _getPmcaAffiliationLabels(author) {
        var result = "";
        if (author.affiliations == null) return result;

        for (var i = 0; i < author.affiliations.length; i++) {
            var id = author.affiliations[i];

            for (var a = 0; a < this.publi.affiliations.length; a++) {
                var aff = this.publi.affiliations[a];
                var pmcaLabel = String(a + 1);
                if (aff.id == id) result = result + " " + pmcaLabel; // because aff.label is not reliable
            }
        }

        return result.trim();
    }

    _getSeparator(index, arr) {
        var last = arr.length - 1;
        return index < last ? "," : ".";
    }

    _isTitle(x) {
        return x == "Title";
    }

    _hasValue(x) {
        return x && x.length > 0;
    }

    _isLastIndex(index, array) {
        return index + 1 == array.length;
    }

    selectPsg(id, withScroll) {
        var sctList = this.root.querySelectorAll("pubmed-section-v2");

        for (var s = 0; s < sctList.length; s++) {
            var sctEl = sctList[s];
            sctEl.selectPsg(id, withScroll);
        }
    }

    applyFilterState(f) {
        this.filters = f; // contain the actual filtering criteria that changed

        this.fsccount++; // triggers rerendering of pubmed-section elements (non deep object change)
    }

    addAnnotations(seeds) {
        if (seeds == undefined || seeds == null) return;
        var new_annotations = [];
        var searched_props = ["text", "caption", "footer"];

        for (var i = 0; i < seeds.length; i++) {
            var seed = seeds[i];

            for (var s = 0; s < this.publi.body_sections.length; s++) {
                var section = this.publi.body_sections[s];

                for (var c = 0; c < section.contents.length; c++) {
                    var cnt = section.contents[c];
                    var search_value = seed.concept_form;

                    for (var p = 0; p < searched_props.length; p++) {
                        var prop = searched_props[p];
                        var textual_content = cnt[prop];
                        if (textual_content == undefined) continue;
                        var offset = -1;

                        while (true) {
                            var offset = textual_content.indexOf(
                                search_value,
                                offset + 1
                            );
                            if (offset == -1) break;
                            var annot =
                                this.createAnnotationFromSeedContentOffset(
                                    seed,
                                    cnt,
                                    offset
                                ); //console.log("adding", annot);

                            new_annotations.push(annot);
                        }
                    }
                }
            }
        }

        this.publi.annotations = this.publi.annotations.concat(new_annotations);
        DataParser.parsePublicationData(this.publi);
        this.fsccount++;
    }

    createAnnotationFromSeedContentOffset(seed, cnt, offset) {
        var annot = {
            concept_offset: 0,
            concept_form: seed.concept_form,
            concept_id: seed.concept_id,
            concept_length: seed.concept_form.length,
            concept_source: seed.concept_source,
            special_id: seed.special_id,
            type: seed.type,
            preferred_term: seed.preferred_term,
            version: seed.version,
            passage: seed.concept_form,
            passage_length: seed.concept_form.length,
            content_id: cnt.id,
            field: cnt.tag,
            passage_offset: offset,
            concept_offset_in_section: offset, // id and psg_id values are set later
        };
        return annot;
    }

    reset() {
        this.publi = {
            authors: [],
            affiliations: [],
            body_sections: [],
            annotations: [],
        };
        this.debug = false;
        this.showbacksections = false;
        this.fsccount = 0;
        this.filters = null;
    }
}

window.customElements.define("pubmed-viewer-v2", PubmedViewerV2);
