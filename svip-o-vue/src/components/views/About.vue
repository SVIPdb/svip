<template>
    <div class="container">
        <div class="position-fixed fixed-bottom about-nav" v-b-scrollspy.offset="140">
            <b-nav pills fill justified>
                <b-nav-item @click="scrollIntoView" href="#home">Home</b-nav-item>
                <b-nav-item @click="scrollIntoView" href="#project">Project</b-nav-item>
                <b-nav-item @click="scrollIntoView" href="#partners">Partners</b-nav-item>
                <b-nav-item @click="scrollIntoView" href="#team">Team</b-nav-item>
                <b-nav-item @click="scrollIntoView" href="#contact">Contact</b-nav-item>
                <b-nav-item @click="scrollIntoView" href="#events">Events</b-nav-item>
                <b-nav-item @click="scrollIntoView" href="#references">References</b-nav-item>
            </b-nav>
        </div>

        <div class="highlight-clean row">
            <div class="col-md-12 mt-3">
                <section id="home" class="content-section-light">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <div style="text-align: center;">
                                    <img class="img-fluid" src=/project-info/media/Logo_SVIP.png alt="SVIP logo" width=550>
                                </div>
                                <br>
                                <br>
                                <h1>Swiss Variant Interpretation Platform</h1>
                                <p class="lead">A one-stop shop for clinical interpretation of variants in oncology</p>
                                <p>The Swiss Variant Interpretation Platform for Oncology (SVIP-O) aims at providing a centralized,
                                    joint, and curated database for clinical somatic variants coming from Swiss hospitals and
                                    related institutions (e.g. pathology institutes).</p>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="project" class="content-section-gray">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <h1>The Project</h1>
                                <p class="lead">An infrastructure development project of SPHN and BioMedIT</p>

                                <h3>Why SVIP?</h3>
                                <div class="text-justify">
                                    <p>Clinicians in oncology and hemato-oncology are daily confronted with the challenge of
                                        interpreting genetic variants using an increasing number of public knowledge sources, which
                                        provide information of heterogeneous quality.<br>
                                        Swiss hospitals and SIB have decided to join forces to develop a common infrastructure
                                        allowing hospitals to share and unify the clinical interpretation of the genetic variants
                                        identified in their patients all over Switzerland.<br>
                                        This consensus annotation of variants will also be accessible to researchers, as having
                                        access to variants detected in patients with well-characterized and clinically-validated
                                        phenotypic information is critical to better understand disease aetiology and reliably
                                        identify new drug targets.<br>
                                        The SVIP project was launched in 2017, with the support of the Swiss Personalized Health
                                        Network (SPHN, <a href="http://www.sphn.ch">www.sphn.ch</a>) and BioMedIT initiatives.
                                    </p>
                                </div>

                                <h3>SVIP workflow</h3>
                                <div class="text-justify">
                                    <p>The principle of the project is that hospitals feed the system with all variants they
                                        identify in their patients when using NGS for diagnosis. For variants already annotated in
                                        the database, annotations will be merged, and discrepancies will be solved by a clinical
                                        panel composed of experts from the partnering hospitals. For variants without previous
                                        annotation, manual curation supported by bioinformatics tools will provide a draft
                                        annotation and likely clinical interpretation, which will also be validated by the clinical
                                        expert panel.
                                    </p>
                                </div>
                                <div class="container-fluid-compact">
                                    <div class="row">
                                        <!-- /.col-md-2 -->
                                        <div class="col-lg-2 mb-2">
                                            <div class="card h-100 small">
                                                <div class="card-title-gradient gradient-1">Joint repository</div>
                                                <div class="card-body">
                                                    <p>Shared between all partner hospitals with single point of entry</p>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- /.col-md-2 -->
                                        <div class="col-lg-2 mb-2">
                                            <div class="card h-100  small">
                                                <div class="card-title-gradient gradient-2">Posting of variants</div>
                                                <div class="card-body">
                                                    <p>To avoid unnecessary manual labor and increase efficiency</p>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- /.col-md-2 -->
                                        <div class="col-lg-2 mb-2">
                                            <div class="card h-100 small">
                                                <div class="card-title-gradient gradient-3">Validation of clinical variants</div>
                                                <div class="card-body">
                                                    <p>By manual curation (SIB) and clinical experts consensus (hospitals)</p>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- /.col-md-2 -->
                                        <div class="col-lg-2 mb-2">
                                            <div class="card h-100 small">
                                                <div class="card-title-gradient gradient-4">Common annotation</div>
                                                <div class="card-body">
                                                    <p>Approved by all partners, ensuring consistent assessment of pathogenicity</p>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- /.col-md-2 -->
                                        <div class="col-lg-2 mb-2">
                                            <div class="card h-100 small">
                                                <div class="card-title-gradient gradient-5">Discrepancy management</div>
                                                <div class="card-body">
                                                    <p>To solve conflicting annotations between labs when new variants are
                                                        identified</p>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- /.col-md-2 -->
                                        <div class="col-lg-2 mb-2">
                                            <div class="card h-100 small">
                                                <div class="card-title-gradient gradient-6">Feedback mechanism</div>
                                                <div class="card-body">
                                                    <p>In case pathogenicity changes over time</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <h3>SVIP to support also translational research</h3>
                                <div class="text-justify">
                                    <p>SVIP will incorporate variant information from other similar projects such as ClinVar,
                                        ClinGen, CIViC, OncoKB, and PMKB, to facilitate the prioritization of variants by molecular
                                        pathologists, to become the Swiss one-stop shop for the interpretation of somatic variants,
                                        enabling faster and more robust prioritisation.<br>
                                        The consensus annotation of variants will also be accessible to researchers, as having
                                        access to variants detected in patients with well-characterized and clinically-validated
                                        phenotypic information is critical to better understand disease aetiology and reliably
                                        identify new drug targets.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="partners" class="content-section-light">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <h1>Our Partners</h1>
                                <p class="lead">A national network of medical institutions committed to a joint goal</p>
                                <p class="mb-5">This program has been made possible thanks to the commitment and strong support of
                                    Swiss hospitals, institutes and medical societies who have agreed to share their know-how and
                                    expertise for the benefit of the patients.</p>
                            </div>
                            <div class="col-md-3 mb-3">
                                <ul>
                                    <li><i><a href="http://www.sgmp.uzh.ch/home.html">Swiss Society of Molecular Pathology</a></i>
                                    </li>
                                </ul>
                                <ul>
                                    <li><i><a href="http://sgpath.ch">Swiss Society of Pathology</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="https://www.unibas.ch/en/Focal-areas/Personalized-Health-Basel.html">Personalized
                                        Health Basel</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="https://www.ksbl.ch/home">Kantonsspital Baselland</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="https://www.insel.ch">Bern University Hospital</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="http://www.dbmr.unibe.ch">Department for BioMedical Research</a> and <a
                                        href="http://www.pathology.unibe.ch/index_eng.html">Institute of Pathology</a>, Bern
                                        University</i></li>
                                </ul>
                                <ul>
                                    <li><i><a
                                        href="https://www.hug-ge.ch/pathologie-clinique/laboratoires-de-pathologie-moleculaire">Geneva
                                        University Hospital</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="https://www.chuv.ch/fr/pathologie/ipa-home/">Lausanne University
                                        Hospital</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="https://www4.ti.ch/dss/dsp/icp/istituto/">Locarno Institute of Pathology</a></i>
                                    </li>
                                </ul>
                                <ul>
                                    <li><i><a href="https://www.kssg.ch/pathologie">St Gallen Cantonal Hospital</a></i></li>
                                </ul>
                                <ul>
                                    <li><i><a href="http://www.en.pathology.usz.ch">Zürich University Hospital</a></i></li>
                                </ul>
                            </div>
                            <div class="col-md-9 mb-9">
                                <div><img class="img-fluid" alt="SVIP partner institutions"
                                    src="/project-info/media/svip_partner_institutions.png"><br>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="team" class="content-section-gray">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <h1>About the Team</h1>
                                <!--<p class="lead">Team introduction</p>-->
                            </div>
                            <!-- /.col-md-4 -->
                            <div class="col-md-4 mb-4">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <div class="card-title" style="text-align: center">
                                            <img class="card-img-top" style="height: 200px; width: auto;" src=/project-info/media/barbie.jpg
                                                alt="Valérie Barbié">
                                        </div>
                                        <p class="card-text">Val&eacute;rie Barbi&eacute; is head of Clinical Bioinformatics at SIB,
                                            which objectives are to harmonize bioinformatics diagnosis practices for omics data
                                            across Swiss hospitals. The group also collaborates with Swiss hospitals or institutions
                                            to jointly develop tailored diagnosis pipelines in NGS. She is co-leading the SIB
                                            Somatic Mutation Calling WG.</p>
                                    </div>
                                    <div class="card-footer">
                                        <a href="https://www.sib.swiss/" class="btn btn-primary">Website</a>

                                        <b-btn to="mailto:Valerie.Barbie@sib.swiss" variant="secondary" class="ml-2">
                                        Email
                                        </b-btn>
                                    </div>
                                </div>
                            </div>
                            <!-- /.col-md-4 -->
                            <div class="col-md-4 mb-4">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <div class="card-title" style="text-align: center">
                                            <img class="card-img-top" style="height: 200px; width: auto;" src=/project-info/media/stekhoven.jpg
                                                alt="Daniel Stekhoven">
                                        </div>
                                        <p class="card-text mt-3">Daniel Stekhoven is head of the Clinical Bioinformatics Unit at
                                            NEXUS – a biomedical core facility of ETH Zurich aiming at translating computational
                                            methods and tools to clinical application. CBU is among the first to use comprehensive
                                            NGS in cancer diagnostics. He is group leader of SIB and co-leader of the Somatic
                                            Mutation Calling WG.</p>
                                    </div>
                                    <div class="card-footer">
                                        <a href="http://www.nexus.ethz.ch/" class="btn btn-primary">Website</a>

                                        <b-btn to="mailto:stekhoven@nexus.ethz.ch" variant="secondary" class="ml-2">
                                        Email
                                        </b-btn>
                                    </div>
                                </div>
                            </div>
                            <!-- /.col-md-4 -->
                            <div class="col-md-4 mb-4">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <div class="card-title" style="text-align: center">
                                            <img class="card-img-top" style="height: 200px; width: auto;" src=/project-info/media/ruch.png
                                                alt="Patrick Ruch">
                                        </div>
                                        <p class="card-text">Patrick Ruch is professor and chairman of the Information Sciences
                                            department of the University of Applied Sciences Western Switzerland (HES-SO) in Geneva.
                                            He is also leader of the SIB Text Mining group, which maintains text analytics services
                                            to support the curation of SIB databases such as Swiss-Prot and neXtprot.</p>
                                    </div>
                                    <div class="card-footer">
                                        <a href="https://www.hes-so.ch/" class="btn btn-primary">Website</a>
                                        <!--<a href="#" class="btn btn-secondary float-right">Email</a> -->
                                        <b-btn to="mailto:patrick.ruch@hesge.ch" variant="secondary" class="ml-2">
                                        Email
                                        </b-btn>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="contact" class="content-section-light">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <h1>
                                    Stay tuned
                                </h1>
                                <p class="lead">Sign up to our newsletter or become an institutional member
                                </p>
                                <b-btn to="mailto:Valerie.Barbie@sib.swiss" variant="secondary">
                                Sign up
                                </b-btn>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="events" class="content-section-gray">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <h1>Events</h1>
                                <!-- Event card -->
                                <div class="container-fluid-compact">
                                    <div class="card-group">
                                        <div class="card col-lg-3 my-1 bg-light">
                                            <div class="card-body text-center">
                                                <p class="text-center"><img src="/project-info/media/calendar.png" alt="When?"> 25 February
                                                    2019</p>
                                            </div>
                                        </div>
                                        <div class="card col-lg-9 my-1">
                                            <div class="card-body">
                                                <p><a href="https://www.youtube.com/watch?v=6KatLlUW-uo" target="_blank">DCC Seminar
                                                    and Training Series</a>
                                                    <br><img src="/project-info/media/location.png" alt="Where?"> Online presentation</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Event card -->
                                <div class="container-fluid-compact">
                                    <div class="card-group">
                                        <div class="card col-lg-3 my-1 bg-light">
                                            <div class="card-body text-center">
                                                <p class="text-center"><img src="/project-info/media/calendar.png" alt="When?"> 11-12 September
                                                    2018</p>
                                            </div>
                                        </div>
                                        <div class="card col-lg-9 my-1">
                                            <div class="card-body">
                                                <p><a href="http://www.ehealthsummit.ch/ehome/304633/ehealth-summit-2018" target="_blank">Swiss
                                                    eHealth Summit 2018</a><br><img src="/project-info/media/location.png" alt="Where?"> Bern,
                                                    Switzerland</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Event card -->
                                <div class="container-fluid-compact">
                                    <div class="card-group">
                                        <div class="card col-lg-3 my-1 bg-light">
                                            <div class="card-body text-center">
                                                <p class="text-center"><img src="/project-info/media/calendar.png" alt="When?"> 18-21 June 2018
                                                </p>
                                            </div>
                                        </div>
                                        <div class="card col-lg-9 my-1">
                                            <div class="card-body">
                                                <p><a href="http://www.personalizedhealth.nexus.ethz.ch/" target="_blank">Personalized Health
                                                    Technologies and Translational Research Conference</a><br><img
                                                    src="/project-info/media/location.png" alt="Where?"> ETH Zürich, Switzerland</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Event card -->
                                <div class="container-fluid-compact">
                                    <div class="card-group">
                                        <div class="card col-lg-3 my-1 bg-light">
                                            <div class="card-body text-center">
                                                <p class="text-center"><img src="/project-info/media/calendar.png" alt="When?"> 23-25 May 2018</p>
                                            </div>
                                        </div>
                                        <div class="card col-lg-9 my-1">
                                            <div class="card-body">
                                                <p><a
                                                    href="https://coursesandconferences.wellcomegenomecampus.org/events/item.aspx?e=712" target="_blank">Curating
                                                    the Clinical Genome</a><br><img src="/project-info/media/location.png" alt="Where?">
                                                    Wellcome Genome Campus, Hinxton, Cambridge, UK</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Event card -->
                                <div class="container-fluid-compact">

                                    <div class="card-group">
                                        <div class="card col-lg-3 my-1 bg-light">
                                            <div class="card-body text-center">
                                                <p class="text-center"><img src="/project-info/media/calendar.png" alt="When?"> 17 May 2018</p>
                                            </div>
                                        </div>
                                        <div class="card col-lg-9 my-1">
                                            <div class="card-body">
                                                <p><a href="http://lausanne.inno-forum.org/personalized-healthcare-conference/" target="_blank">Innovation
                                                    Forum Personalised Healthcare Conference</a><br><img
                                                    src="/project-info/media/location.png" alt="Where?"> Lausanne, Switzerland</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Section publication newly added -->
                <section id="references" class="content-section-light">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-12">
                                <h1>References</h1>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item">
                                        Déborah Caucheteur, Julien Gobeill, Anaïs Mottaz, Emilie Pasche , Pierre-André Michel, Luc Mottin,
                                        Daniel J. Stekhoven, Valérie Barbié and Patrick Ruch.
                                        <em><a href="/project-info/media/MIE2020_SVIP_TM.pdf" target="_blank">Text-mining Services of the Swiss Variant
                                            Interpretation Platform for Oncology</a></em>. <a href="https://mie2020.org/" target="_blank">
                                        MIE 2020</a>.
                                    </li>
                                    <li class="list-group-item">
                                        Déborah Caucheteur, Emilie Pasche, Julien Gobeill, Anaïs Mottaz, Luc Mottin and Patrick Ruch.
                                        <em><a href="https://trec.nist.gov/pubs/trec28/papers/BITEM_PM.PM.pdf" target="_blank">Designing retrieval models
                                            to contrast precision-driven ad hoc search vs. recall-driven treatment extraction in
                                            Precision Medicine</a></em>. <a href="https://trec.nist.gov/pubs/trec28/trec2019.html" target="_blank">
                                        TREC 2019</a>.
                                    </li>
                                    <li class="list-group-item">
                                        Stekhoven Daniel J., Ruch Patrick, Barbié Valérie. <em><a href="https://doi.org/10.4414/smi.34.00411" target="_blank">
                                        Swiss Variant Interpretation Platform for Oncology (SVIP-O)</a></em>. <em><a href="https://medical-informatics.ch/"
                                        target="_blank">Swiss Med Informatics</a></em>. 2018;34:00411
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</template>

<script>
import {slugifySans} from "@/utils";
import "@/css/infocards.scss";

export default {
    name: "About",
    data() {
        return {

        };
    },
    methods: {
        slugifySans,
        // Convenience method to scroll a heading into view.
        // Not required for scrollspy to work
        scrollIntoView(evt) {
            evt.preventDefault();
            const href = evt.target.getAttribute('href');
            const el = href ? document.querySelector(href) : null;

            if (el) {
                // document.querySelector("body").scrollTop = el.offsetTop
                el.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        }
    }
}
</script>

<style scoped>
/*.videoWrapper {*/
/*    position: relative;*/
/*    padding-bottom: 56.25%; !* 16:9 *!*/
/*    padding-top: 25px;*/
/*    height: 0;*/
/*}*/
/*.videoWrapper iframe {*/
/*    position: absolute;*/
/*    top: 0;*/
/*    left: 0;*/
/*    width: 100%;*/
/*    height: 100%;*/
/*}*/
/*iframe {*/
/*    frameborder: 0;*/
/*}*/

.about-nav {
    padding: 10px; border-top: solid 1px #ccc; background-color: white; z-index: 9999;
}

section { border-bottom: solid 1px #eee; margin-top: -90px; padding-top: 90px; margin-bottom: 2em; padding-bottom: 1em; }
section:last-child { border-bottom: none; }
</style>
