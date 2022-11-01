import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import './extra_modules/elix/src/FilterListBox.js';
import './shared-style.js';
/**
 * `list-browser`
 *
 *
 * @customElement
 * @polymer
 * @demo demo/list-browser-demo.html
 */

class ListBrowser extends PolymerElement {
    static get template() {
        return html`
      <style include="shared-style">
        :host {
          box-sizing: border-box;
          border-style:solid;
          border-color: lightgray;
          border-width: thin;
          margin: 0px;
          background-color: white;
          height: inherit;
          width: inherit;
          display: flex;
          flex-flow: column;
          font-family: Sans-serif;
          font-size: 16px;
        }
        first-row {
          height: auto;
          width: inherit;
          padding-left:4px;
          padding-top:4px;
          padding-right: 4px;
          padding-bottom:4px;
          color:gray;
        }
        elix-filter-list-box {
          box-sizing: border-box;
          flex: 1;
          #height:100%;
          width: 100%;
          padding:2px;
          border:none;
          border-top:inherit;
          overflow-y: scroll;  /* REQUIRED for firefox */
        }
        input {
          max-width: 100px;
        }
      </style>
      <first-row>
        Search: <input class="filter-input" value="" on-input="_handleFilterChange"></input>
        <button on-click="_handleClearFilter">Clear</button>
      </first-row>
      <elix-filter-list-box/>

    `;
    }

    static get properties() {
        return {
            data: {
                type: Array,
                value: null,
            },
        };
    }

    ready() {
        super.ready();
        var listbox = this.root.querySelector('elix-filter-list-box');
        listbox.addEventListener('selected-index-changed', this._handleSelectedIndexChanged);
    }

    clearList() {
        var listbox = this.root.querySelector('elix-filter-list-box');
        var children = listbox.querySelectorAll('list-item-div');

        for (var i = 0; i < children.length; i++) listbox.removeChild(children[i]);
    }

    fillList(filters) {
        this.clearList();
        if (this.data == null) return;
        var listbox = this.root.querySelector('elix-filter-list-box');

        for (var i = 0; i < this.data.length; i++) {
            var item = this.data[i];
            if (this._filterOut(item, filters)) continue;
            var div = document.createElement('list-item-div');
            div.appendChild(document.createTextNode(item.label));
            div.setAttribute('customid', item.id);
            listbox.appendChild(div);
        }
    }

    _filterOut(annot, filters) {
        if (filters == undefined || filters == null) return false;

        for (var i = 0; i < filters.length; i++) {
            var filter = filters[i];
            if (filter.name == annot.concept_source) return filter.checked == false;
        }

        return false;
    }

    setSelectedItem(id) {
        var listbox = this.root.querySelector('elix-filter-list-box');
        var children = listbox.querySelectorAll('list-item-div');

        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            var childId = child.getAttribute('customid'); //console.log("childId",childId, id);

            if (childId == id) {
                if (child.style.display == 'none') this._handleClearFilter();
                listbox.selectedItem = child;
                listbox.scrollSelectionIntoView();
                return;
            }
        }

        listbox.selectedIndex = -1;
    }

    getSelectedItemId() {
        var listbox = this.root.querySelector('elix-filter-list-box');
        var slct = listbox.selectedItem;
        if (slct == undefined || slct == null) return null;
        return slct.getAttribute('customid');
    }

    _handleSelectedIndexChanged(e) {
        var idx = this.selectedIndex;
        var item = this.selectedItem;
        var detail = {
            selectedIndex: idx,
            selectedItem: null,
        };
        if (idx > -1)
            detail.selectedItem = {
                id: item.getAttribute('customid'),
                label: item.textContent,
            };
        this.dispatchEvent(
            new CustomEvent('list-browser-selected-index-changed', {
                composed: true,
                detail: detail,
            })
        ); //console.log("my event data", detail);
    }

    _handleFilterChange() {
        var filter = this.root.querySelector('.filter-input');
        var listbox = this.root.querySelector('elix-filter-list-box'); //console.log(filter.value);

        listbox.filter = filter.value;
    }

    _handleClearFilter() {
        var filter = this.root.querySelector('.filter-input');

        if (filter.value) {
            filter.value = '';

            this._handleFilterChange();
        }
    }

    reset() {
        this.clearList();
        this.data = null;
    }
}

window.customElements.define('list-browser', ListBrowser);
