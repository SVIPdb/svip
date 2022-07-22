#Variant page				

The Variant page provides information on the variant of interest, ranging from HGVS expressions to manual annotation. It reports an aggregation of the minimal clinical data submitted by SVIP partners, as well as software predictions of the effect of the variant on the gene function. If the variant has been manually curated, a summary describes the current knowledge on the variant and its clinical significance, based on scientific literature reviewed during the curation process.

_N.B:_ SVIP uses GRCh37 as genomic reference sequence.

##General variant information
Field |	Source |	Description
--- | --- | ---
Gene name|HGNC|Gene name according to the HUGO Gene Nomenclature Committee (https://www.genenames.org/)
Variant|Various|For many variants affecting the protein sequence, we choose the name that is the most frequently<br/> found in the literature or the second half of the HGVS expression using<br>• the amino acid one-letter code (e.g. V600E) or, if not present<br>• the coding change (e.g. c.1799T>A) or, if not present <br>• the genomic change (e.g. 140453136A>T)
HGVS.g|VEP|HGVS nomenclature with a linear genomic reference sequence. <br>SVIP first displays the RefSeq reference sequence. 
HGVS.p|VEP|HGVS nomenclature with a protein reference sequence, if applicable. <br>SVIP first displays the RefSeq reference sequence.
HGVS.c|VEP|HGVS nomenclature with a coding DNA reference sequence, if applicable.<br> SVIP first displays the RefSeq reference sequence. <br>By default, we display the Matched Annotation from NCBI and EMBL-EBI (MANE) Select transcript,<br> but all HGVS expressions are stored in the database,<br> allowing searches with any expression.  
dbSNP|VEP|Single Nucleotide Polymorphism Database identifier.
Position||Variant genomic position
Allele frequency|VEP|Frequency of the variant in gnomAD exomes combined population.
Status|SVIP|LOADED : present in SVIP but no annotation<br>IN PROGRESS : curation started  (this status in ternal only and not visible on the public interface)<br>PARTIAL : only partial curation is available (no summary, no clinical review)<br>ANNOTATED : annotation complete, but not yet approved by the review panel<br>APPROVED : annotation complete and approved by the expert panel
SVIP confidence|SVIP|Based on a three-star evaluation system:<br>• no star: the variant has been retrieved from various sources by SVIP harvester<br>• one star: at least one tumor sample has been submitted to SVIP <br>•	two stars: the variant has been manually annotated<br>• three stars: the manual annotation of the variant has been validated by the SVIP expert panel.

##Gene Summary
A summary is available for each gene entry for which variant(s) have been curated. This summary describes what the gene physiological function and its involvement in cancer are. It is displayed in all SVIP variant entries known for this gene, even in entries that have not yet been curated.	
				
##Variant Summary	
			
A summary is available for each variant that has been manually curated. This summary describes the current knowledge about the variant and its clinical significance, based on scientific literature reviewed during the curation process.  	
				
##SVIP Information	
			
This section shows clinical data provided by SVIP partners (see ‘About’ - [https://svip.ch/about]()), included the tumor types in which the variant has been identified, the number of samples, etc.
For each variant, the following information is available:

Field|Source|Description
--- | --- | ---
Disease | International<br> Classification of<br> Diseases for Oncology<br> (ICD-O)|ICD-O morphologic and topographic terms of the disease,<br> as provided by the SVIP partner
Nb of Samples | | Number of VCF files provided by the partners containing this variant in the disease of interest
Age Distribution ||Distribution of the age of the patients when their sample was analyzed
Gender Balance ||Gender distribution of the patients’ samples
Pathogenicity ||Pathogenicity optionally provided by the medical expert
Clinical Significance||Summary of the various evidences grouped by type:<br> predictive/therapeutic, diagnostic, prognostic

A click on the green arrow on the left of the disease name allows to see all manual annotations associated with the variant in this specific disease.

##Publicly available information

In this section, we provide data harvested from specialized databases, like  CIViC, COSMIC or ClinVar. This data includes the diseases in which the variant has been reported, the type of evidence (prognostic, predictive, functional, etc.) and the clinical significance and interpretation found in these databases.

##Additional data sources	
				
- **Algorithmic predictions**:  provides score and predicted impact from SIFT, Polyphen and FATHMM softwares.
- **Allele frequency**: provides the number of alleles and the frequency reported by gnomAD.
- **Swiss Personalized Oncology (Swiss-PO)**:  provides a link to Swiss-PO, a web tool developed help predict the potential impact of mutations on protein three-dimensional structure in oncology (see Krebs et al., 2021, PMID:33737716).	
- **SOCIBP samples**: 	when available, provides the information on samples carrying the same mutation in the SOCIPB SPHN project dataset.