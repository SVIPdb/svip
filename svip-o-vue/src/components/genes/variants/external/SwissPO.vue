<template>
    <div class="col-sm-auto">
        <div class="card mt-3 top-level">
            <div class="card-header">
                <div class="card-title">
                    Swiss Personalized Oncology
                    <div class="float-right align-middle">
                        <a :href="`http://swiss-po.ch/?protein='${ protein }'&variant='p.${change}'`" target="_blank">
                            <icon name="external-link-alt"/>
                        </a>
                    </div>
                </div>
            </div>

            <div class="card-body top-level" style="padding: 0;">
                <div class="not-found" v-if="found_in_swisspo === false">
                    <icon name="exclamation-triangle"/>
                    residue not found in molecule
                </div>
                <!-- tbc: ngl visualizer -->
                <div style="background-color: white; width: 300px;">
                    <div id="viewport" style="width: 100%; height: 250px;"></div>
                </div>

                <div style="border-top: solid 1px #ccc; padding: 10px; padding-bottom: 3px;">
                    <label for="pdb_select">Selected PDB/Chain:</label>&nbsp;
                    <select id="pdb_select" v-if="pdbs" v-model="selected_pdb">
                        <option disabled value="">Choose a PDB</option>
                        <option v-for="(x, idx) in pdbs" :key="idx" :value="x">{{ x.pdb }} {{ x.chain }}</option>
                    </select>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import {HTTP} from "@/router/http";
import {serverURL} from "@/app_config";
import * as NGL from "ngl";

const one_to_three = {
    "A": "ALA",
    "R": "ARG",
    "N": "ASN",
    "D": "ASP",
    "B": "ASX",
    "C": "CYS",
    "E": "GLU",
    "Q": "GLN",
    "Z": "GLX",
    "G": "GLY",
    "H": "HIS",
    "I": "ILE",
    "L": "LEU",
    "K": "LYS",
    "M": "MET",
    "F": "PHE",
    "P": "PRO",
    "S": "SER",
    "T": "THR",
    "W": "TRP",
    "Y": "TYR",
    "V": "VAL"
};

export default {
    name: "SwissPO",
    props: {
        protein: {type: String, required: true},
        change: {type: String, required: false}
    },
    data() {
        return {
            stage: null,
            structure: null,
            pdbs: [],
            selected_pdb: null,
            found_in_swisspo: null
        }
    },
    mounted() {
        if (this.stage) {
            delete this.stage;
        }
        this.stage = new NGL.Stage("viewport", {
            //fogNear: 10,
            // "percentages, "dist" is distance too camera in Angstrom
            clipNear: 0,
            clipFar: 100,
            clipDist: 3,
            // percentages, start of fog and where on full effect
            fogNear: 0,
            fogFar: 100,
            // background color
            backgroundColor: "white",
            sampleLevel: 2
        });

        window.addEventListener('resize', this.handleNGLResize);

        // and do an initial load
        this.loadStructure(this.protein, this.change);
    },
    computed: {
        change_parts() {
            const result = this.change.match(/^([A-Z])([0-9]+)([A-Z])$/);
            return (result) && {ref: result[1], alt: result[3], pos: result[2]};
        }
    },
    watch: {
        uniprotId: function (val) {
            this.loadStructure(val, this.change);
        },
        change: function (val) {
            this.zoomResidue(val);
        },
        selected_pdb: function (val) {
            console.log("Selected: ", val);
            HTTP.get(`swiss_po/get_residues/${val.pdb}:${val.chain}`)
                .then(response => response.data)
                .then(data => {
                    console.log("Got PDB info: ", data);
                    this.loadPDB(data.pdb_filename, val.chain, data.residue_range)
                });
        }
    },
    methods: {
        handleNGLResize() {
            if (this.stage) {
                this.stage.handleResize();
            }
        },
        async loadStructure(protein, change) {
            this.pdbs = await HTTP.get(`swiss_po/get_pdbs/${protein}`).then(response => response.data);
            // get the first PDB by default
            this.selected_pdb = this.pdbs[0];
        },
        loadPDB(pdb_path, chain, residue_range) {
            this.stage.removeAllComponents();

            // noinspection JSCheckFunctionSignatures
            this.stage.loadFile(`${serverURL}swiss_po/get_pdb_data/${pdb_path}`, {ext: 'pdb'}).then((o) => {
                // to have the representation we want, we choose to use the "cartoon" one
                o.addRepresentation("cartoon", {sele: "*", color: "residueindex"});
                // Show the ligand in hyperball representation, surrounded by a transparent surface
                o.addRepresentation('hyperball', {sele: "[LIG]"});
                o.addRepresentation('surface', {
                    sele: "[LIG]",
                    smooth: 2,
                    opacity: 0.2,
                    lowResolution: false,
                    useWorker: false,
                    color: "white"
                });

                // produce a nice generic view of the entire molecule
                this.stage.autoView(0);

                // show only the selected chain
                o.setSelection(`:${chain}`);

                this.structure = o;

                // --------
                // let's also try zooming in on a position and labeling it
                // --------
                if (this.change_parts.pos >= residue_range.min && this.change_parts.pos <= residue_range.max) {
                    this.found_in_swisspo = true;
                    this.zoomResidue(this.change);
                } else {
                    this.found_in_swisspo = false;
                    console.warn("Residue not located in molecule, showing anyway");
                }
            });
        },
        zoomResidue() {
            const o = this.structure;
            let myZoom;

            // see if we can extract a position from the change, otherwise bail
            if (this.change && this.change_parts) {
                myZoom = this.change_parts.pos;
                console.log("Zooming in on ", myZoom);
            } else {
                console.log("Unable to find simple position in ", this.change, ", aborting zoom");
                return;
            }

            // Define ball and stick and licorice representations.
            const bnsRepr = o.addRepresentation('ball+stick', {sele: 'NONE'});
            const licRepr = o.addRepresentation('licorice', {sele: 'NONE'});
            const conRepr = o.addRepresentation("contact", {
                sele: 'NONE',
                hydrogenBond: true,
                hydrophobic: false,
                halogenBond: false,
                ionicInteraction: true,
                metalCoordination: false,
                cationPi: false,
                piStacking: false,
                weakHydrogenBond: false,
                waterHydrogenBond: true,
                backboneHydrogenBond: true,
                maxPiStackingDist: 5.5,
                maxPiStackingOffset: 2.0,
                maxPiStackingAngle: 45,
            });

            // zooming on the selected  amino acid;
            const center = o.getCenter(myZoom);
            const zoom = o.getZoom(myZoom);
            this.stage.animationControls.zoomMove(center, zoom, 2000);
            // label selected amino acid
            const l = o.addRepresentation("label", {
                sele: `( ${myZoom} ) and .CA`,
                color: "orange",
                borderColor: 'black',
                scale: 2.0
            });

            // show the selected residue in ball and stick
            const bns = bnsRepr.setSelection(myZoom);

            // show residues around the selected one in licorice
            const selection = new NGL.Selection(myZoom);
            const radius = 5;
            const atomSet = o.structure.getAtomSetWithinSelection(selection, radius);
            const atomSet2 = o.structure.getAtomSetWithinGroup(atomSet).toSeleString();
            let lic = licRepr.setSelection(atomSet2);

            // show contacts made by residues around the selected one
            const contacts = conRepr.setSelection(atomSet2);

            // show various types of hydrogen bonds, too
            contacts.setParameters({hydrogenBond: true});
            contacts.setParameters({waterHydrogenBond: true});
            contacts.setParameters({backboneHydrogenBond: true});
        }
    }
};
</script>

<style scoped>
.not-found {
    color: #350710;
    display: flex;
    justify-content: center;
    align-items: center;
    flex: 1 1 auto;
    background-color: #faf9cf;
    border-bottom: solid 1px #eed6b5;
    padding: 5px;
}

.not-found .fa-icon { margin-right: 5px; }

/* show indication that we can manipulate by dragging */
#viewport { cursor: grab; }

#viewport:active { cursor: grabbing; }
</style>
