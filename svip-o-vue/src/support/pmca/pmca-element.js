import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import './list-browser.js';
import './pubmed-viewer-v2.js';
import './checkbox-group.js';

import CandyProxy from '@/support/pmca/proxy-data-access';
import DataParser from '@/support/pmca/proxy-data-parser';

// what should this function do?
function getBaseHref() {
    return '';
}

/**
 * @customElement
 * @polymer
 */

class PmcaElement extends PolymerElement {
    static get template() {
        return html`
            <!-- <script>
      window.addEventListener('popstate', function(e) {
        console.log('popstate event:', e, location);
      });
      window.addEventListener('load', function(e) {
        console.log('load event:', e, location);
        //handleLoad(e);
      });
    </script> -->

            <style>
                :host {
                    box-sizing: border-box;
                    margin: 0px;
                    height: 100%;
                    width: 100%;
                    padding: 2px;
                    display: flex;
                    flex-direction: row;
                }

                col1 {
                    flex-grow: 1;
                    padding-right: 2px;
                    overflow: auto;
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                }

                col2 {
                    min-width: 250px;
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                }

                /*------------ col 1 row 1 ------------------*/
                .content11 {
                    xxheight: 200px;
                    overflow: auto;
                    padding: 2px;
                    __border: 1px solid red;
                }

                /*------------ col 1 row 2 ------------------*/
                pubmed-viewer-v2 {
                    box-sizing: border-box;
                    margin: 0px;
                    width: 100%;
                    height: 100%;
                    background-color: #f5f5f5;
                }

                .content12 {
                    flex-grow: 1;
                    overflow: auto;
                    padding-top: 20px;
                    padding-bottom: 20px;
                    padding-left: 36px;
                    padding-right: 36px;
                    __border: 1px solid blue;
                }

                /*------------ col 2 row 1 ------------------*/
                .content21 {
                    __flex-grow: 1;
                    height: 360px;
                    overflow: auto;
                    width: 100%;
                    padding: 2px;
                    __border-left: 1px solid lightgray;
                    __border-right: 1px solid lightgray;
                    border-bottom: 1px solid lightgray;
                    font-size: 12px;
                }

                /*------------ col 2 row 2 ------------------*/
                list-browser {
                    box-sizing: border-box;
                    margin: 0px;
                    width: 100%;
                }

                .content22 {
                    __height: 300px;
                    flex-grow: 1;
                    overflow: auto;
                    width: 100%;
                    padding: 2px;
                    border: none;
                    __border: 1px solid red;
                    font-size: 12px;
                }

                /*------------------------------*/
            </style>

            <col1>
                <div class="content11" id="pmcid-selection-div" style="display:none;">
                    <label for="pmcid_in">Choose or type a PMCID</label>
                    <input
                        id="pmcid_in"
                        type="list"
                        value=""
                        list="pmcid-list"
                        autocomplete="off"
                        on-change="handleSelectPmcid"
                        on-click="handleClickPS" />
                    <datalist id="pmcid-list">
                        <option value="6622523"></option>
                        <option value="4235888"></option>
                        <option value="4909023"></option>
                        <option value="4476985"></option>
                        <option value="5244436"></option>
                        <option value="4094256"></option>
                        <option value="4235888"></option>
                        <option value="4909023"></option>
                        <option value="4476985"></option>
                        <option value="5244436"></option>
                        <option value="4094256"></option>
                        <option value="6066757"></option>
                        <option value="5364449"></option>
                        <option value="3265130"></option>
                    </datalist>

                    <button on-click="handleClickCC">Custom config</button>
                </div>
                <pubmed-viewer-v2 class="content12"></pubmed-viewer-v2>
            </col1>

            <col2>
                <checkbox-group class="content21"></checkbox-group>
                <list-browser class="content22"></list-browser>
            </col2>
        `;
    }

    static get properties() {
        return {
            extraAnnotations: {
                type: Array,
                value: null,
            },
            defaultForAllFilters: {
                type: Boolean,
                value: true,
            },
            stateForFilters: {
                type: Object,
                value: null,
            },
            withCovoc: {
                type: Boolean,
                value: false,
            },
            pmcid: {
                type: String,
                value: '0',
            },
        };
    } // polymer says: required cos listening to event thrown by native element

    constructor() {
        super();
        this._boundListener = this.fillViewer.bind(this);
    } // polymer says: required cos listening to event thrown by native element

    connectedCallback() {
        super.connectedCallback();
        window.addEventListener('popstate', this._boundListener);
        window.addEventListener('load', this._boundListener);
        console.log('window event listeners added');
    } // polymer says: required cos listening to event thrown by native element

    disconnectedCallback() {
        super.disconnectedCallback();
        window.removeEventListener('popstate', this._boundListener);
        window.removeEventListener('load', this._boundListener);
        console.log('window event listeners removed');
    }

    ready() {
        super.ready();
        this.addEventListener('filter-state-change', this.handleFilterStateChange);
        this.addEventListener('list-browser-selected-index-changed', this.handleListSelection);
        this.addEventListener('passagetouched', this.handleAnnotationTouched);
    }

    getPmcidFromUrl_old() {
        // if pathElements looks like /stuff/.../pmcid/6622523/...
        var loc = location || window.location;
        var pathElements = loc.pathname.split('/'); //console.log("getPmcidFromUrl - loc.pathname: ", loc.pathname);

        var pmcidValueIsExpected = false;

        for (var i = 0; i < pathElements.length; i++) {
            var el = pathElements[i];

            if (pmcidValueIsExpected && el != '') {
                //console.log("getPmcidFromUrl - pmcid found, returning: ", el);
                return el;
            }

            if (el == 'pmcid') pmcidValueIsExpected = true;
        }

        return '0';
    }

    getPmcidFromUrl() {
        var loc = location || window.location;
        if (loc.search == null || loc.search == '') return '0';
        var params = loc.search.substr(1).split('&');

        for (var i = 0; i < params.length; i++) {
            var nv = params[i].split('=');
            if (nv[0].toLowerCase() == 'pmcid' && nv.length == 2) return nv[1];
        }

        return '0';
    }

    getOptionsFromUrl() {
        var options = {
            selector: false,
            debug: false,
            service: 'candy',
            showbacksections: false,
        };
        var loc = location || window.location;
        if (loc.search == null || loc.search == '') return options;
        var params = loc.search.substr(1).split('&');

        for (var i = 0; i < params.length; i++) {
            var nv = params[i].split('=');
            if (nv[0].toLowerCase() == 'selector') options.selector = true;
            if (nv[0].toLowerCase() == 'showbacksections') options.showbacksections = true;
            if (nv[0].toLowerCase() == 'debug') options.debug = true;
            if (nv[0].toLowerCase() == 'service' && nv.length == 2) options.service = nv[1].toLowerCase();
        }

        return options;
    }

    fillViewerWithIdAndOptions(pmcid, options) {
        if (options == undefined)
            options = {
                selector: false,
                debug: false,
                service: 'candy',
                showbacksections: false,
            };
        if (options.selector == undefined) options.selector = false;
        if (options.debug == undefined) options.debug = false;
        if (options.showbacksections == undefined) options.showbacksections = false;
        if (options.service == undefined) options.service = 'candy';
        this.displaySelector(options.selector); // In order to make life easier on re-calling this method after changing some other property
        // we save the pmcid in the corresponding property

        this.pmcid = pmcid;
        if (pmcid == '0') return;
        var promise = CandyProxy.getPromisedAnnotatedPublication(pmcid, options.service, this.withCovoc);
        var pv = this.root.querySelector('pubmed-viewer-v2');
        var lb = this.root.querySelector('list-browser');
        var af = this.root.querySelector('checkbox-group');
        var me = this;

        return promise
            .then(function (annotatedPubli) {
                var nohighlight = annotatedPubli.PMC_set && annotatedPubli.PMC_set == 'author_manuscripts';
                pv.nohighlight = nohighlight;
                pv.publi = annotatedPubli;
                pv.addAnnotations(me.extraAnnotations);
                pv.debug = options.debug;
                pv.showbacksections = options.showbacksections;
                var annotations = DataParser.getIdLabelListFromAnnotations(annotatedPubli);
                lb.data = annotations;
                lb.fillList();
                var filters = DataParser.getPropertyValuesFromAnnotations(
                    annotatedPubli.annotations,
                    'concept_source'
                );
                me.setFiltersStates(filters);
                af.nohighlight = nohighlight;
                af.data = filters;

                af._dispatchEventStateChanged(); //console.log("publi", annotatedPubli, "filters", filters);
            })
            .catch(function (reason) {
                console.log('error reason', reason);
                alert('Sorry, an error occured. See console for details');
            });
    }

    fillViewer() {
        var options = this.getOptionsFromUrl();
        var pmcid = this.getPmcidFromUrl();
        this.fillViewerWithIdAndOptions(pmcid, options);
    }

    handleFilterStateChange(e) {
        var filters = e.detail.filters;
        var viewer = this.root.querySelector('pubmed-viewer-v2');
        viewer.applyFilterState(filters);
        var lb = this.root.querySelector('list-browser');
        var selectedId = lb.getSelectedItemId();
        lb.fillList(filters);
        setTimeout(function () {
            lb.setSelectedItem(selectedId);
        }, 200); // re-select item if still in list
        //console.log("filter state changed", selectedId, filters);
    }

    handleListSelection(e) {
        var item = e.detail.selectedItem;
        var viewer = this.root.querySelector('pubmed-viewer-v2');
        var id = item == undefined || item == null ? null : item.id; //console.log("selection changed",id, viewer);

        viewer.selectPsg(id, true);
    }

    handleAnnotationTouched(e) {
        //console.log("annotation touched",e);
        var someid = e.detail.id; //var id = someid.substr(3);

        var id = someid;
        var lb = this.root.querySelector('list-browser');
        lb.setSelectedItem(id);
        var viewer = this.root.querySelector('pubmed-viewer-v2');
        viewer.selectPsg(id, false);
    }

    handleSelectPmcid(event) {
        var el = event.target || event.srcElement; //console.log("event source el.value , el", el.value, el);

        this.displayPmcid(el.value);
    } // useful to get full list of options visible without deleting value

    handleClickPS(event) {
        var el = event.target || event.srcElement;
        el.value = '';
    } // // unused
    // handleClickAA() {
    //   var a1 = {concept_form:"mixture",concept_id:"PseudoCpt1",concept_source:"Pseudo", preferred_term: "MIX",
    //             special_id:"SpecialId1", type: "Artificial", version: "2020-01-06",
    //             concept_offset:0, concept_length:3, passage:"the", passage_length:3,
    //             concept_offset_in_section:-1, passage_offset:-1, id:-1, psg_id:-1
    //           };
    //   var a2 = {concept_form:"extensively throughout the world",concept_id:"PseudoCpt2",concept_source:"Pseudo", preferred_term: "EVERYWHERE",
    //             special_id:"SpecialId2", type: "Artificial", version: "2020-01-06",
    //             concept_offset:0, concept_length:3, passage:"the", passage_length:3,
    //             concept_offset_in_section:-1, passage_offset:-1, id:-1, psg_id:-1
    //           };
    //   this.addAnnotations([a1,a2]);
    // }

    handleClickCC() {
        var highlighted_src_1 = 'OnTheFlyAnnot';
        var highlighted_src_2 = 'DynamicAnnot';
        var a1 = {
            concept_form: 'mixture',
            concept_id: 'PseudoCpt1',
            concept_source: highlighted_src_1,
            preferred_term: 'MIX1',
            special_id: 'SpecialId1',
            type: 'Artificial1',
            version: '2020-01-06',
        };
        var a2 = {
            concept_form: 'agricultural',
            concept_id: 'PseudoCpt2',
            concept_source: highlighted_src_2,
            preferred_term: 'MIX2',
            special_id: 'SpecialId2',
            type: 'Artificial2',
            version: '2020-01-06',
        };
        this.extraAnnotations = [a1, a2];
        this.defaultForAllFilters = false;
        this.stateForFilters = {
            names: [highlighted_src_1, highlighted_src_2],
            state: true,
        };
        this.displayPmcid('4909023');
    }

    displaySelector(state) {
        var el = this.root.querySelector('#pmcid-selection-div');
        el.style.display = state ? 'block' : 'none';
    }

    displayPmcid_old(id) {
        var loc = location || window.location;
        var params = loc.search;
        var url = getBaseHref() + 'pmcid/' + id + params; //event.preventDefault();

        history.pushState(null, '', url);
        window.dispatchEvent(new Event('popstate'));
    }

    displayPmcid(id) {
        var loc = location || window.location;
        var new_params = '?pmcid=' + id;
        var params = loc.search.substr(1).split('&');
        console.log('old params:', loc.search);

        for (var i = 0; i < params.length; i++) {
            var nv = params[i].split('=');
            if (nv[0].toLowerCase() == 'selector') new_params += '&selector';
            if (nv[0].toLowerCase() == 'debug') new_params += '&debug';
            if (nv[0].toLowerCase() == 'showbacksections') new_params += '&showbacksections';
            if (nv[0].toLowerCase() == 'service' && nv.length == 2)
                new_params += '&service=' + nv[1].toLowerCase();
        }

        var url = getBaseHref() + 'index.html' + new_params;
        console.log('new params:', new_params, url);
        history.pushState(null, '', url);
        window.dispatchEvent(new Event('popstate'));
    }

    setFiltersStates(filters) {
        // set default checked value if exists
        if (this.defaultForAllFilters == true || this.defaultForAllFilters == false) {
            for (var i = 0; i < filters.length; i++) {
                filters[i].checked = this.defaultForAllFilters;
            }
        } // override default for some filter names if defined so

        if (this.stateForFilters != undefined && this.stateForFilters != null) {
            var names = [this.stateForFilters.names];
            if (this.stateForFilters.names instanceof Array) names = this.stateForFilters.names;

            for (var i = 0; i < filters.length; i++) {
                if (names.includes(filters[i].name)) filters[i].checked = this.stateForFilters.state;
            }
        }
    }

    reset() {
        this.extraAnnotations = null;
        this.defaultForAllFilters = true;
        this.withCovoc = false;

        null;

        this.root.querySelector('pubmed-viewer-v2').reset();
        this.root.querySelector('list-browser').reset();
        this.root.querySelector('checkbox-group').reset();
    } // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // functions below can be used to change the state of the viewer programmatically
    // after the pmcid is already displayed (experimental)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // // experimental / do not use
    // setAllFilters(state) {
    //   if (state==true || state==false) {
    //     var af = this.root.querySelector("checkbox-group");
    //     af.set_checkboxes_checked(state);
    //   }
    // }
    //
    // // experimental / do not use
    // setFilters(cpt_source, state) {
    //   if (state==true || state==false) {
    //     var sources = [cpt_source];
    //     if (cpt_source instanceof Array) sources = cpt_source;
    //     var af = this.root.querySelector("checkbox-group");
    //     for (var i=0;i< sources.length;i++) {
    //       af.set_checkbox_checked(sources[i], state);
    //     }
    //   }
    // }
    //
    // // experimental / do not use
    // addAnnotations(annotations) {
    //   var viewer = this.root.querySelector("pubmed-viewer-v2");
    //   viewer.addAnnotations(annotations);
    //
    //   var lb = this.root.querySelector("list-browser");
    //   var idlabels = DataParser.getIdLabelListFromAnnotations(viewer.publi);
    //   lb.data=idlabels;
    //   lb.fillList();
    //
    //   var af = this.root.querySelector("checkbox-group");
    //   var filters = DataParser.getPropertyValuesFromAnnotations(viewer.publi.annotations,"concept_source");
    //   af.data=filters;
    // }
}

window.customElements.define('pmca-element', PmcaElement);
