import { html, PolymerElement } from "@polymer/polymer/polymer-element.js";
import "@polymer/polymer/lib/elements/dom-repeat.js";
import "./shared-style.js";
/**
 * `pubmed-section-v2`
 * displays a pubmed publication section sith some optional highlighted text
 *
 * @customElement
 * @polymer
 * @demo demo/index.html
 */

class PubmedSectionV2 extends PolymerElement {
    static get template() {
        return html`
      <style include="shared-style">
        :host {
          display: block;
          height: auto;
          background-color: inherited;
        }

        .minilink { font-weight: normal; font-size: xx-small; text-decoration: none;}

        .passage  {
           color:darkblue;
        }
        .concept  {
          color: #078878;
          font-weight: bold;
          text-decoration: underline;
        }

        .normal {
          color: gray;
        }

        .normal-nohighlight {
          color: gray;
        }

        .normal-nohighlight[selected] {
          background-color: unset;
        }

        span {
          line-height: 1.9;
          padding:2px;
        }

        span[selected] {
          background-color: rgb(178, 215, 255);
        }


      </style>

      <dom-repeat items="{{data.contents}}" as="content">

        <template>

          <template is="dom-if" if="{{_tagIsParagraph(content.tag)}}">
            <div class="publi-contents-wrapper" >

              <div class$="{{_getClassForTitle(data.title)}}" on-mouseup="_handleOnMouseUp">
                <dom-repeat items="{{_turnContentIntoNodes(content,'text', fsccount)}}" as="node" >
                  <template><span class$="{{_getClass(node)}}" title$="{{_getInfo(node)}}">[[node.content]]</span>
                    <template is="dom-if" if="[[showlinks]]">
                        <dom-repeat items="{{_getLinks(node)}}" as="lnk" >
                          <template><sub><a class="minilink" target="_blank" href$="[[lnk.url]]"> [[lnk.label]] </a> </sub></template>
                        </dom-repeat>
                      </template>
                    </template>
                </dom-repeat>
                <span class$="{{_getClassForDebug()}}">id:[[content.id]] - tag:[[content.tag]]</span>
              </div>

            </div>
          </template>


          <template is="dom-if" if="{{_tagIsFigure(content.tag)}}">
            <div class="publi-contents-wrapper publi-figure-wrapper" >
              <div class="publi-label-style">
                [[content.label]]
                <span class$="{{_getClassForDebug()}}">
                  id:[[content.id]] - tag:[[content.tag]] - media:[[content.media]] - graphics:[[content.graphics]]
                </span>
              </div>
              <template is="dom-if" if="{{content.xref_id!=''}}">
                <div><a href="[[content.xref_url]]" target="_blank">[[content.xref_url]]</a></div>
              </template>
              <div class="publi-caption-style" on-mouseup="_handleOnMouseUp">
                <dom-repeat items="{{_turnContentIntoNodes(content,'caption', fsccount)}}" as="node" >
                  <template><span class$="{{_getClass(node)}}" title$="{{_getInfo(node)}}">[[node.content]]</span></template>
                </dom-repeat>
              </div>
            </div>
          </template>

          <template is="dom-if" if="{{_tagIsTable(content.tag)}}">
          <div class="publi-contents-wrapper publi-table-wrapper" >
              <div class="publi-label-style">
                [[content.label]]
                <span class$="{{_getClassForDebug()}}">
                  id:[[content.id]] - tag:[[content.tag]] - media:[[content.media]] - graphics:[[content.graphics]]
                </span>
              </div>
              <div class="publi-caption-style" on-mouseup="_handleOnMouseUp">
                <dom-repeat items="{{_turnContentIntoNodes(content,'caption', fsccount)}}" as="node">
                  <template><span class$="{{_getClass(node)}}" title$="{{_getInfo(node)}}">[[node.content]]</span></template>
                </dom-repeat>
              </div>
              <div class="publi-link-style"><a href="[[content.xref_url]]" target="_blank">[[content.xref_url]]</a></div>
              <div class="publi-table-style" inner-h-t-m-l="{{_buildHTML(content,fsccount)}}" on-mouseup="_handleOnMouseUp"></div>
              <div class="publi-footer-style" on-mouseup="_handleOnMouseUp">
                <dom-repeat items="{{_turnContentIntoNodes(content,'footer', fsccount)}}" as="node">
                  <template><span class$="{{_getClass(node)}}" title$="{{_getInfo(node)}}">[[node.content]]</span></template>
                </dom-repeat>
              </div>
            </div>
          </template>

          <template is="dom-if" if="{{_tagIsListItem(content.tag)}}">
            <div class="publi-contents-wrapper publi-list-item-wrapper">
              <div>
                [[content.text]]
                  <span class$="{{_getClassForDebug()}}">
                    id:[[content.id]] - tag:[[content.tag]]
                  </span>
              </div>
            </div>
          </template>

          <template is="dom-if" if="{{_tagIsElse(content.tag)}}">
            <div class="publi-contents-wrapper" >
              <div>
                [[content.text]]
                  <span class$="{{_getClassForDebug()}}">
                    Other element id:[[content.id]] - tag:[[content.tag]]
                  </span>
              </div>
            </div>
          </template>

          </div>

        </template>


      </dom-repeat>


      <!-- <div on-mouseup="_handleOnMouseUp">
          <dom-repeat items="{{_turnDataIntoNodes(data)}}">
            <template><span class$="{{_getClass(item)}}" title$="{{_getTitle(item)}}">[[item.content]]</span></template>
          </dom-repeat>
      </div> -->

    `;
    }

    static get properties() {
        return {
            data: {
                type: Object,
            },
            debug: {
                type: Boolean,
                value: false,
            },
            nohighlight: {
                type: Boolean,
                value: false,
            },
            showlinks: {
                type: Boolean,
                value: true,
            },
            fsccount: {
                type: Number,
                value: 0,
            },
            filters: {
                type: Array,
                value: null,
            },
        };
    }

    _getClassForDebug() {
        return this.debug ? "publi-debug-info" : "publi-debug-info-hidden";
    }

    _getClassForTitle(x) {
        return x == "Title" ? "publi-title" : "publi-para";
    }

    _tagIsParagraph(x) {
        return x == "p";
    }

    _tagIsFigure(x) {
        return x == "fig";
    }

    _tagIsTable(x) {
        return x == "table";
    }

    _tagIsListItem(x) {
        return x == "list-item";
    }

    _tagIsElse(x) {
        if (x == "p") return false;
        if (x == "fig") return false;
        if (x == "table") return false;
        if (x == "list-item") return false;
        return true;
    }

    _getLng(x) {
        return x.length;
    }

    _handleOnMouseUp(e) {
        var txt = "";

        if (window.getSelection) {
            txt = window.getSelection();
        } else if (document.getSelection) {
            txt = document.getSelection();
        } else if (document.selection) {
            txt = document.selection.createRange().text;
        } //console.log("Selected text is " + txt);

        if (txt != "") {
            // user trying to define new psg
            //console.log("Selected text is " + txt);
            this.dispatchEvent(
                new CustomEvent("passageselected", {
                    composed: true,
                    detail: {
                        content: txt,
                    },
                })
            );
            return;
        } else {
            // user trying to select existing psg
            var el = e.target || e.srcElement;

            if (el.title) {
                var titleText = el.title;
                var titleIds = titleText.split(" ");

                for (var i = 0; i < titleIds.length; i++) {
                    var id = titleIds[i]; //if (id.startsWith("psg")) {

                    if (id.startsWith("ann")) {
                        this.dispatchEvent(
                            new CustomEvent("passagetouched", {
                                composed: true,
                                detail: {
                                    id: id,
                                },
                            })
                        );
                        return;
                    }
                }
            }
        }
    }

    _getClass(item) {
        if (this.nohighlight) return "normal-nohighlight";
        if (item.tags.indexOf("concept") > -1) return "concept";
        if (item.tags.indexOf("passage") > -1) return "passage";
        return "normal";
    }

    _getInfo(item) {
        var cloned_ids = item.ids.slice(0);
        var ids_and_cpts = cloned_ids.concat(item.cpts); //cloned_ids.sort();

        return ids_and_cpts.join(" ");
    }

    _getLinks(item) {
        var links = [];

        for (var i = 0; i < item.cpts.length; i++) {
            var cpt = item.cpts[i];
            var dbac = cpt.split(":");

            if (dbac[0] == "MeSH") {
                links.push({
                    label: dbac[0],
                    url: "https://www.ncbi.nlm.nih.gov/mesh/?term=" + dbac[1],
                });
            } else if (dbac[0] == "GO") {
                links.push({
                    label: dbac[0],
                    url:
                        "http://amigo.geneontology.org/amigo/term/" +
                        dbac[1] +
                        ":" +
                        dbac[2],
                });
            } else if (dbac[0] == "Drugbank") {
                links.push({
                    label: dbac[0],
                    url: "https://www.drugbank.ca/drugs/" + dbac[1],
                });
            } else if (dbac[0] == "neXtProt") {
                links.push({
                    label: dbac[0],
                    url: "https://www.nextprot.org/entry/" + dbac[1],
                });
            }
        }

        return links;
    }

    _filterOut(annot) {
        if (this.filters == null) return false;

        for (var i = 0; i < this.filters.length; i++) {
            var filter = this.filters[i];
            if (filter.name == annot.concept_source)
                return filter.checked == false;
        }

        return false;
    }

    _buildHTML(content, fsccount) {
        var new_xml = "";

        var spans = this._turnContentIntoNodes(content, "Content", fsccount);

        for (var i = 0; i < spans.length; i++) {
            var span = spans[i];
            var tag =
                '<span class="' +
                this._getClass(span) +
                '" title="' +
                this._getInfo(span) +
                '">';
            var element = tag + span.content + "</span>";
            new_xml += element;
        }

        return new_xml;
    } // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Function based on the new structure
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // For a given content to be turned into span nodes we must be able to get
    // - the text of the contents and its id
    // - a function returning efficiently the list of annotations related to this contents (by id)
    // We then can rewrite and adapt the old function below
    // content:  is the section content Object
    // tc_field: is the name of the content property which contain the annotated text (text, caption, footer, content)
    // fsccount: a counter triggering the rendering of the template (yes...) each time its value changes

    _turnContentIntoNodes(content, tc_field, fsccount) {
        //console.log("filters", this.fsccount, this.filters, "running _turnContentIntoNodes()");
        //console.log('content', content);
        var tc_field = tc_field.toLowerCase();
        var tc = tc_field == "content" ? content["xml"] : content[tc_field];
        var passageMap = content.annotations;
        var changes = [];
        var cnt_id = "cnt:" + content.id;
        changes.push({
            tag: "normal",
            id: cnt_id,
            action: "open",
            position: 0,
        });
        changes.push({
            tag: "normal",
            id: cnt_id,
            action: "close",
            position: tc.length,
        });

        for (var psg_key in passageMap) {
            var psgAnnotations = passageMap[psg_key];
            var actual_idx = 0;

            for (var idx = 0; idx < psgAnnotations.length; idx++) {
                var annot = psgAnnotations[idx];
                if (this._filterOut(annot)) continue; //console.log('tc_field', tc_field, 'annot.subfield', annot.subfield, annot.id);

                if (annot.subfield && tc_field != annot.subfield.toLowerCase())
                    continue;

                if (actual_idx == 0) {
                    changes.push({
                        tag: "passage",
                        id: psg_key,
                        action: "open",
                        position: annot.passage_offset,
                    });
                    changes.push({
                        tag: "passage",
                        id: psg_key,
                        action: "close",
                        position: annot.passage_offset + annot.passage_length,
                    });
                }

                var p1 = annot.passage_offset + annot.concept_offset;
                var p2 = p1 + annot.concept_length;
                var cpt = annot.concept_source + ":" + annot.concept_id;
                changes.push({
                    tag: "concept",
                    id: annot.id,
                    cpt: cpt,
                    action: "open",
                    position: p1,
                });
                changes.push({
                    tag: "concept",
                    id: annot.id,
                    cpt: cpt,
                    action: "close",
                    position: p2,
                });
                actual_idx++;
            }
        }

        changes.sort(function (a, b) {
            return a.position - b.position;
        }); //console.log('changes sorted', changes);
        // now we have a position sorted array
        // at each change the previous span is closed and a new one is opened

        var spans = [];
        var currSpan = {
            position: 0,
            ids: [],
            tags: [],
            content: "",
            cpts: [],
            concept_id: "",
            concept_type: "",
        };

        for (var idx = 0; idx < changes.length; idx++) {
            var change = changes[idx]; //console.log(currSpan.position, change.position);

            if (change.position != currSpan.position) {
                var subContent = tc.substring(
                    currSpan.position,
                    change.position
                );
                currSpan.content = subContent; //console.log('pushing', currSpan, 'subContent', subContent);

                spans.push(currSpan);
                currSpan = this._cloneNode(currSpan);
                currSpan.position = change.position;
            }

            if (change.action == "open") {
                currSpan.ids.push(change.id);
                currSpan.tags.push(change.tag);
                if (change.cpt) currSpan.cpts.push(change.cpt);
            } else {
                var idxId = currSpan.ids.indexOf(change.id);
                var idxTag = currSpan.tags.indexOf(change.tag);
                var idxCpt = currSpan.cpts.indexOf(change.cpt);
                if (idxId > -1) currSpan.ids.splice(idxId, 1);
                if (idxTag > -1) currSpan.tags.splice(idxTag, 1);
                if (idxCpt > -1) currSpan.cpts.splice(idxCpt, 1);
            }
        } //for (var i=0;i<spans.length;i++) { console.log('node ready', this._printableNode(spans[i]));}

        return spans;
    }

    _printableNode(node) {
        node.ids.sort();
        node.tags.sort();
        var str = "pos:" + node.position + " ";
        str += "tags:";

        for (var i = 0; i < node.tags.length; i++) str += node.tags[i] + " ";

        str += "ids:";

        for (var i = 0; i < node.ids.length; i++) str += node.ids[i] + " ";

        str += "cpts:";

        for (var i = 0; i < node.cpts.length; i++) str += node.cpts[i] + " ";

        str += "content:" + node.content;
        return str;
    }

    _cloneNode(node) {
        var newNode = {
            position: node.position,
            ids: [],
            tags: [],
            cpts: [],
            content: "",
        };

        for (var i = 0; i < node.ids.length; i++) newNode.ids.push(node.ids[i]);

        for (var i = 0; i < node.tags.length; i++)
            newNode.tags.push(node.tags[i]);

        for (var i = 0; i < node.cpts.length; i++)
            newNode.cpts.push(node.cpts[i]);

        return newNode;
    }

    selectPsg(id, withScroll) {
        var someId = "" + id;
        var spanList = this.root.querySelectorAll("span[selected]");

        for (var i = 0; i < spanList.length; i++) {
            spanList[i].removeAttribute("selected");
        }

        var spanList = this.root.querySelectorAll("span");

        for (var i = 0; i < spanList.length; i++) {
            var span = spanList[i];
            var ids = span.title.split(" ");

            for (var j = 0; j < ids.length; j++) {
                if (someId == ids[j]) {
                    span.setAttribute("selected", true);

                    if (withScroll) {
                        // span.scrollIntoView(true); //span.scrollIntoView({block:"center", behavior: "smooth", inline:"nearest"});
                        span.scrollIntoView({
                            block: "center",
                            behavior: "smooth",
                            inline: "nearest",
                        });
                    }

                    break;
                }
            }
        }
    }
}

window.customElements.define("pubmed-section-v2", PubmedSectionV2);
