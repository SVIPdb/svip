import DataParser from "@/support/pmca/proxy-data-parser";

const CandyProxy = {
  //baseUrl : 'http://localhost:8088',
  getPromisedAnnotatedPublication: function (pmid, service, with_covoc) {
    var me = this;
    return new Promise(function (resolve, reject) {
      Promise.all([me.getPromisedPublication(pmid, service, with_covoc)]).then(function (values) {
        var publi = values[0]; //var annotations = values[1];
        //me._attachAnnotationsToPubliSections(publi, annotations);

        resolve(publi);
      }).catch(function (reason) {
        reject(reason);
      });
    });
  },
  getPromisedPublication: function (pmcid, service, with_covoc) {
    var me = this;
    var mypath = "http://undefined.service.sorry"; // direct calls to candy service

    if (service == "httpcandy") mypath = "http://candy.hesge.ch/SIBiLS/PMC/fetch_PAM.jsp?ids=";
    if (service == "httpscandy") mypath = "https://candy.hesge.ch/SIBiLS/PMC/fetch_PAM.jsp?ids=";
    if (service == "candy") mypath = "/SIBiLS/PMC/fetch_PAM.jsp?ids="; // proxied call to candy service (not used any more since tomcat on candy sends header Access-Control-Allow-Origin="*")

    if (service == "proxy") mypath = "http://localhost:8088/sibils/pmc/"; // proxied call to ncbi, xml file cache, xml parsing

    if (service == "ncbi") mypath = "http://localhost:8088/parse/pmc/";
    var id = pmcid;
    if (service.indexOf("candy") >= 0 && !id.startsWith("PMC")) id = "PMC" + id;
    var url = mypath + id;

    if (with_covoc) {
      var sep = '?';
      if (url.indexOf('?') >= 0) sep = '&';
      url += sep + 'covoc';
    }

    console.log("id", id);
    console.log("service", service);
    console.log("covoc", with_covoc);
    console.log("url", url);
    return this._getPromisedJson(url).then(function (json) {
      return me._getPromisedParsedData(json.data, DataParser.parsePublicationData);
    });
  },

  /*
    getPromisedMedlineAnnotations: function(pmid) {
      var me = this;
      var url = this.baseUrl + '/medline/annot?publicationId=' + pmid;
      console.log(url);
      return this._getPromisedJson(url).then(function(json) {
        return me._getPromisedParsedData(json, DataParser.parseMedlineAnnotationData);
      });
    },
  */

  /* * * * * * * * * * * * * * * * * * * * * * * * * * * *
   *  low level helper functions
   * * * * * * * * * * * * * * * * * * * * * * * * * * * */

  /*
   _attachAnnotationsToPubliSections: function (publi, annotations) {
     for (var psgTxt in annotations) {
         var pos = -1;
         for (var s=0; s<publi.sections.length;s++ ) {
           var section = publi.sections[s];
           var sctText = publi.sections[s].text;
           var sctName = publi.sections[s].name;
           pos = sctText.indexOf(psgTxt);
           if (pos>-1) {
             var annot = annotations[psgTxt];
             annot.sectionPos=pos;
             annot.sectionName=sctName;
             annot.text=psgTxt;
             if (section.annotations == undefined) section.annotations = [];
             section.annotations.push(annot);
             //console.log("INFO, annotation psg found in section: ", sctName, annotations[psgTxt]);
             break;
           }
         }
         if (pos==-1) console.log("WARNING, annotation psg NOT found: ", psgTxt);
     }
     for (var s=0; s<publi.sections.length;s++ ) {
       var section = publi.sections[s];
       section.annotations.sort(function(a,b) {return a.sectionPos - b.sectionPos;});
     }
     //for (var s=0; s<publi.sections.length;s++ ) console.log("sorted section annotations",publi.sections[s].name, publi.sections[s].annotations);
   },
  */
  _getPromisedParsedData: function (json, parseFunction) {
    var me = this;
    var promise = new Promise(function (resolve, reject) {
      try {
        resolve(parseFunction(json));
      } catch (err) {
        console.log(err.stack);
        reject(me._getRejectObject(json.query.uri, 200, "Data parsing error: " + err.message));
      }
    });
    return promise;
  },
  _getPromisedJson: function (url) {
    var me = this;
    var promise = new Promise(function (resolve, reject) {
      var xhttp = new XMLHttpRequest();
      xhttp.open("GET", url, true);

      xhttp.onreadystatechange = function () {
        if (this.readyState != 4) return; // if could get a valid response from server

        if (this.status == 200) {
          var json = JSON.parse(this.responseText); // perform some special formatting in this case

          if (json.success == undefined) json = me._getSuccessObjectForCandy(url, json);

          if (json.success) {
            resolve(json);
          } else {
            var msg = json.error && json.error.message ? ": " + json.error.message : "";
            reject(me._getRejectObject(url, this.status, "Server error" + msg));
          }
        } else {
          reject(me._getRejectObject(url, this.status, "HTTP error"));
        }
      };

      xhttp.send();
    });
    return promise;
  },
  // This method creates the object expected by the parser.
  // We do some fomratting of the incoming object which is normally
  // performed by the proxy server.
  // If we get here, it means that the proxy is bypassed and with_annotations
  // we call candy services directly
  _getSuccessObjectForCandy: function (uri, obj) {
    // get the single expected publication
    var publi = obj[0]; // do some fix if necessary

    if (publi.annotations == undefined && publi.annotation != undefined) {
      publi.annotations = publi.annotation;
      delete publi.annotation;
    } // build and return expected data structure


    return {
      "success": true,
      "query": {
        "method": "GET",
        "params": {},
        "uri": uri
      },
      "data": publi
    };
  },
  _getSuccessObject: function (uri, obj) {
    return {
      "success": true,
      "query": {
        "method": "GET",
        "params": {},
        "uri": uri
      },
      "data": obj
    };
  },
  _getRejectObject: function (uri, status, msg) {
    return {
      "success": false,
      "query": {
        "method": "GET",
        "params": {},
        "uri": uri
      },
      "error": {
        "message": msg,
        "httpStatus": status
      }
    };
  }
};

export default CandyProxy;
