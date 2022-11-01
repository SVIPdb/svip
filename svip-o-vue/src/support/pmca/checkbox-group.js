import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import '@polymer/polymer/lib/elements/dom-repeat.js';
import './shared-style.js';
/**
 * `checkbox-group`
 * displays a checkbox group *
 * @customElement
 * @polymer
 **/

class CheckboxGroup extends PolymerElement {
    static get template() {
        return html`
            <style include="shared-style">
                :host {
                    box-sizing: border-box;
                    display: block;
                    width: 200px;
                    height: 300px;
                    background-color: inherited;
                    border-syle: solid;
                    border-color: gray;
                    border-weight: 1px;
                    font-family: Sans-serif;
                    font-size: 16px;
                    color: gray;
                    margin: 0px;
                }
                .category-div {
                    font-weight: bold;
                    padding-top: 8px;
                    padding-bottom: 2px;
                }
                .license-msg {
                    margin-top: 4px;
                    padding: 4px;
                    background-color: powderblue;
                    font-size: 14px;
                }
                .hidden {
                    display: none;
                }
                label {
                    #line-height: 1.4;
                }
            </style>

            <div style="margin-bottom:0px;">
                <button on-click="handle_display_all_clicked">Display all</button>
                <button on-click="handle_hide_all_clicked">Hide all</button>
            </div>
            <div class$="{{_get_class_for_license_restrictions(changecnt)}}">
                In accordance with license, annotated entities listed below cannot be highlighted in text
            </div>
            <dom-repeat items="{{_get_category_list(changecnt)}}" as="cat">
                <template>
                    <div class="category-div">{{_get_pretty_category(cat,this.items)}}</div>

                    <dom-repeat items="{{_get_category_item_list(cat,changecnt)}}">
                        <template>
                            <div>
                                <input
                                    on-change="handle_checkbox_change"
                                    type="checkbox"
                                    name="[[item.name]]"
                                    checked="[[item.checked]]" />
                                <label for="[[item.name]]">[[item.label]]</label>
                            </div>
                        </template>
                    </dom-repeat>
                </template>
            </dom-repeat>
        `;
    }

    static get properties() {
        return {
            data: {
                type: Array,
                value: [
                    {
                        name: 'Name 1',
                        count: 100,
                        checked: true,
                    },
                    {
                        name: 'Name 2',
                        count: 200,
                        checked: false,
                    },
                    {
                        name: 'Name 3',
                        count: 300,
                        checked: true,
                    },
                ],
            },
            item_details: {
                type: Object,
                value: {
                    'BMV': {
                        label: 'BMV - BioMedical Vocabulary',
                        category: 'COVoc Ontology',
                    },
                    'CE': {
                        label: 'CE - Conceptual Entities',
                        category: 'COVoc Ontology',
                    },
                    'CL': {
                        label: 'CL - Cell Lines',
                        category: 'COVoc Ontology',
                    },
                    'CT': {
                        label: 'CT - Clinical Trials',
                        category: 'COVoc Ontology',
                    },
                    'DG': {
                        label: 'DG - Drugs',
                        category: 'COVoc Ontology',
                    },
                    'DIS': {
                        label: 'DIS - Diseases&Syndromes',
                        category: 'COVoc Ontology',
                    },
                    'LOC': {
                        label: 'LOC - Geographic Locations',
                        category: 'COVoc Ontology',
                    },
                    'SP': {
                        label: 'SP - Organisms',
                        category: 'COVoc Ontology',
                    },
                    'PG': {
                        label: 'PG - Proteins&Genomes',
                        category: 'COVoc Ontology',
                    },
                    'ATC': {
                        label: 'A.T.C.',
                    },
                    'MESH': {
                        label: 'MeSH',
                    },
                    'UniProt small': {
                        label: 'UniProt (truncated)',
                    },
                },
            },
            nohighlight: {
                type: Boolean,
                value: false,
            },
            changecnt: {
                type: Number,
                value: 0, // change counter to trigger refresh
            },
        };
    }

    _get_class_for_license_restrictions() {
        return this.nohighlight ? 'license-msg' : 'license-msg hidden';
    }

    _get_pretty_category(cat) {
        if (cat == 'zzz_default') {
            var somevalue = 23335;
            if (this._get_category_list(somevalue).length <= 1) return 'Default terminologies';
            return 'Other terminologies';
        }

        return cat;
    }

    _get_category_list(anyvalue) {
        var catobj = {};

        for (var i = 0; i < this.data.length; i++) {
            var det = this._get_name_details(this.data[i]);

            var cat = det.category;
            if (!catobj[cat]) catobj[cat] = cat;
        }

        var list = [];

        for (var k in catobj) list.push(k);

        list.sort((a, b) => (a.toLowerCase() > b.toLowerCase() ? 1 : -1));
        return list;
    }

    _get_category_item_list(cat, somevalue) {
        var list = [];

        for (var i = 0; i < this.data.length; i++) {
            var det = this._get_name_details(this.data[i]);

            if (cat == det.category) list.push(det);
        }

        list.sort((a, b) => (a.label.toLowerCase() > b.label.toLowerCase() ? 1 : -1));
        return list;
    }

    _get_name_details(data_obj) {
        var name = data_obj.name; // define default returned object

        var details = {
            category: 'zzz_default',
            label: name,
            name: name,
            checked: data_obj.checked,
        };

        if (this.item_details && this.item_details[name]) {
            // replace default value with actual values when they are defined
            var found_det = this.item_details[name];
            if (found_det.category) details.category = found_det.category;
            if (found_det.label) details.label = found_det.label;
        }

        details.label = details.label + ' (' + data_obj.count + ')';
        return details;
    }

    handle_display_all_clicked() {
        this.set_checkboxes_checked(true);
    }

    handle_hide_all_clicked() {
        this.set_checkboxes_checked(false);
    }

    set_checkbox_checked(name, state) {
        var selector = "input[name='" + name + "']";
        var box = this.root.querySelector(selector);

        if (box) {
            box.checked = state;
            var pseudo_event = {
                target: {
                    name: name,
                    checked: state,
                },
            };
            this.handle_checkbox_change(pseudo_event);
        }
    }

    set_checkboxes_checked(state) {
        var boxes = this.root.querySelectorAll('input');

        for (var i = 0; i < boxes.length; i++) {
            this.data[i].checked = state;
            var box = boxes[i];
            box.checked = state;
        }

        this._dispatchEventStateChanged();
    }

    handle_checkbox_change(e) {
        var trg = e.target || e.srcElement;
        var name = trg.name;
        var state = trg.checked;

        for (var i = 0; i < this.data.length; i++) {
            var dt = this.data[i];

            if (dt.name == trg.name) {
                dt.checked = trg.checked;
                break;
            }
        }

        this._dispatchEventStateChanged();
    }

    _dispatchEventStateChanged() {
        this.changecnt++;
        var detail = {
            filters: this.data,
        };
        this.dispatchEvent(
            new CustomEvent('filter-state-change', {
                composed: true,
                detail: detail,
            })
        );
    }

    reset() {
        this.data = [];
    }
}

window.customElements.define('checkbox-group', CheckboxGroup);
