const DataParser = {
  parsePublicationData: function (publi) {
    var xml_annots = DataParser.extractTableContentAnnotations(publi);
    var seeds_by_cnt = DataParser.buildTableContentAnnotationSeeds(xml_annots);
    DataParser.rebuiltContentAnnotationsForTableList(publi, seeds_by_cnt); //console.log("parse step 1", publi);

    DataParser.setupAnnotationIds(publi); //console.log("sorted annotations with id", publi.annotations);
    //console.log("parse step 2");

    DataParser.buildSectionIdTitleDictionary(publi); //console.log("step 3");

    DataParser.buildAnnotationTree(publi); //console.log("step 4");

    DataParser.attachAnnotationsToContents(publi); //console.log("step 5");

    delete publi.annotation_tree; // delete publi.annotations;      // to be confirmed

    return publi;
  },
  extractTableContentAnnotations: function (publi) {
    var txt_annotations = [];
    var xml_annotations = [];

    for (var i = 0; i < publi.annotations.length; i++) {
      var annot = publi.annotations[i];

      if (annot.field == 'Table' && annot.subfield == 'Content') {
        xml_annotations.push(annot);
      } else {
        txt_annotations.push(annot);
      }
    }

    publi.annotations = txt_annotations; // console.log("txt annotations", txt_annotations);
    // console.log("xml annotations", xml_annotations);

    return xml_annotations;
  },
  buildTableContentAnnotationSeeds: function (annots) {
    // build a list of annotation seeds based on a unique key
    var annot_map = new Map();

    for (var i = 0; i < annots.length; i++) {
      var annot = annots[i];
      var key = annot.content_id + "|" + annot.concept_id + "|" + annot.concept_form;
      if (!annot_map.has(key)) annot_map.set(key, annot);
    } // console.log("annot_map", annot_map);
    // build a map of seeds: a list of seeds for each content_id


    var cnt_seeds = new Map();
    var annot_values = Array.from(annot_map.values()); // console.log("annot_values", annot_values);

    for (var i = 0; i < annot_values.length; i++) {
      var seed = annot_values[i]; // console.log(seed);
      // remove useless properties of seeds, they are recomputed later

      delete seed.passage;
      delete seed.passage_offset;
      delete seed.passage_length;
      delete seed.concept_offset;
      delete seed.concept_offset_in_section; // add seed to content_id key

      var key = seed.content_id;
      if (!cnt_seeds.has(key)) cnt_seeds.set(key, []);
      cnt_seeds.get(key).push(seed);
    } //console.log("seeds by content id", cnt_seeds);


    return cnt_seeds;
  },
  rebuiltContentAnnotationsForTableList: function (publi, seeds_by_cnt) {
    var rebuilt_annotations = [];
    var section_lists = ['body_sections', 'float_sections'];

    for (var sl = 0; sl < section_lists.length; sl++) {
      var section_list = section_lists[sl];

      for (var i = 0; i < publi[section_list].length; i++) {
        var sec = publi[section_list][i]; //console.log(sec.tag);

        for (var j = 0; j < sec.contents.length; j++) {
          var cnt = sec.contents[j];

          if (seeds_by_cnt.has(cnt.id)) {
            var seeds = seeds_by_cnt.get(cnt.id);
            var cnt_annotations = DataParser.getRebuiltContentAnnotationsForTable(seeds, cnt.xml);
            rebuilt_annotations = rebuilt_annotations.concat(cnt_annotations);
          }
        }
      }
    } //console.log("rebuilt annotations", rebuilt_annotations);


    publi.annotations = publi.annotations.concat(rebuilt_annotations);
  },
  // rebuild annotations of a given table xml content based on a list of annotation seeds
  getRebuiltContentAnnotationsForTable: function (seeds, xmlstr) {
    var new_annotations = [];

    for (var k = 0; k < seeds.length; k++) {
      var seed = seeds[k];
      var idx = -1;

      while (true) {
        idx = xmlstr.indexOf(seed.concept_form, idx);
        if (idx == -1) break; //console.log(idx, seed);

        var instance = {
          passage: seed.concept_form,
          // we decide psg and cpt have same span
          passage_offset: idx,
          passage_length: seed.concept_length,
          concept_offset: 0,
          concept_offset_in_section: idx
        };
        var annot = Object.assign({}, seed, instance);
        new_annotations.push(annot);
        idx += seed.concept_length; //we could also choose idx++ but...
      }
    }

    return new_annotations;
  },
  getOrderForSubfield: function (sf) {
    if (typeof sf == "undefined") return 20; // usual case for paragraph text

    if (sf && sf == 'Caption') return 10; // for figures and tables

    if (sf && sf == 'Footer') return 50; // for figures and tables

    if (sf && sf == 'Content') return 30; // for tables (xml content)

    return 20;
  },
  setupAnnotationIds: function (publi) {
    publi.annotations.sort(function (a, b) {
      // 1st criterion: content id order
      if (a.content_id > b.content_id) return 1;
      if (a.content_id < b.content_id) return -1; // 2nd criterion: content subfield

      if (DataParser.getOrderForSubfield(a.subfield) > DataParser.getOrderForSubfield(b.subfield)) return 1;
      if (DataParser.getOrderForSubfield(a.subfield) < DataParser.getOrderForSubfield(b.subfield)) return -1; // 3rd criterion: position in textual content

      return a.passage_offset + a.concept_offset - b.passage_offset - b.concept_offset;
    });

    for (var i = 0; i < publi.annotations.length; i++) {
      var annot = publi.annotations[i];
      var annot_id = "ann:" + i;
      annot.id = annot_id;
      var psg_id = "psg:" + annot.content_id + ":" + String(annot.passage_offset) + ":" + String(annot.passage_length);
      annot.psg_id = psg_id;
    }
  },
  buildSectionIdTitleDictionary: function (publi) {
    var id_title = {};
    var section_lists = ['body_sections', 'float_sections'];

    for (var sl = 0; sl < section_lists.length; sl++) {
      var section_list = section_lists[sl];

      for (var i = 0; i < publi[section_list].length; i++) {
        var sec = publi[section_list][i];
        id_title[sec.id] = sec.title;
      }
    }

    publi.section_id_title = id_title;
  },
  buildAnnotationTree: function (publi) {
    var cnt2psg = {};

    for (var i = 0; i < publi.annotations.length; i++) {
      var annot = publi.annotations[i];
      if (!cnt2psg[annot.content_id]) cnt2psg[annot.content_id] = {};
      var psg2annot = cnt2psg[annot.content_id];
      if (!psg2annot[annot.psg_id]) psg2annot[annot.psg_id] = [];
      var annot_list = psg2annot[annot.psg_id];
      annot_list.push(annot);
    }

    publi.annotation_tree = cnt2psg;
  },
  attachAnnotationsToContents: function (publi) {
    var section_lists = ['body_sections', 'float_sections'];

    for (var sl = 0; sl < section_lists.length; sl++) {
      var section_list = section_lists[sl];

      for (var i = 0; i < publi[section_list].length; i++) {
        var section = publi[section_list][i];

        for (var j = 0; j < section.contents.length; j++) {
          var content = section.contents[j];
          content.annotations = publi.annotation_tree[content.id];
        }
      }
    }
  },
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  getParentId: function (id) {
    if (id == null) return null;
    var elems = id.split('.');
    if (elems.length < 2) return null;
    elems.pop();
    return elems.join('.');
  },
  getParentTitle: function (content_id, publi) {
    var sec_id = this.getParentId(content_id);

    while (true) {
      if (sec_id == null) return null;
      var section_title = publi.section_id_title[sec_id];
      if (section_title && section_title.length > 0) return section_title;
      sec_id = this.getParentId(sec_id);
    }
  },
  // Temporary
  getIdLabelListFromAnnotations: function (publi) {
    var result = [];

    for (var i = 0; i < publi.annotations.length; i++) {
      var annot = publi.annotations[i];
      var psg = annot.passage;
      var psg_max = 100;
      if (psg.length > psg_max) psg = psg.substr(0, psg_max / 2 - 2) + " ... " + psg.substr(-psg_max / 2 + 3); //var ann = annot.id + " " + annot.type;

      var cpt = annot.concept_form + " " + annot.concept_source + ":" + annot.concept_id;
      var parent_title = this.getParentTitle(annot.content_id, publi); //var label = ann + " - " + cpt + " - " + psg;
      //if (parent_title && parent_title.length>0) label = parent_title + ' - ' + label;

      result.push({
        "id": annot.id,
        "label": annot.type + " - " + cpt,
        "concept_source": annot.concept_source
      });
    }

    return result;
  },
  getPropertyValuesFromAnnotations: function (annotations, property_name) {
    var dico = {};

    for (var i = 0; i < annotations.length; i++) {
      var annot = annotations[i];
      var value = annot[property_name];
      if (dico[value] == undefined) dico[value] = 0;
      dico[value] = dico[value] + 1;
    }

    var result = [];

    for (var k in dico) result.push({
      name: k,
      count: dico[k],
      checked: true
    });

    result.sort((a, b) => a.name.toLowerCase() > b.name.toLowerCase() ? 1 : -1);
    return result;
  }
};

export default DataParser;
