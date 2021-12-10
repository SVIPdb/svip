# SVIP: Overview

## Disease

Disease name according to the ICD-O ontology

Disease name according to the International Classification of Disease for Oncology (ICD-O3)

### Example Disease

`?`

### Disease reference

## # of samples

Number of samples in SVIP for the given disease.

Number of samples in SVIP for the given disease, expressed as (number of samples with this variant in this disease / total number of samples with this variant). This proportion describes the frequency of a variant within a specific disease on the basis of the SVIP data.

### Example # of samples

`11/30`

## Age distribution

Age distribution of carriers of the variant in a given disease in SVIP (absolute number and percentage)

Age distribution (absolute number and percentage) of carriers of the variant in SVIP, by category of age (under 40, 40 to 60,  60 to 80,  and above 80 years old) for a given disease.

### Example Age distribution

`{'img': 'age_dist.png'}`

## Gender balance

Male and female carriers of the variant in a given disease in SVIP (absolute number and percentage)

Gender balance of the carriers of the variant in a given disease in the SVIP samples data.

### Example Gender balance

`{'img': 'gender_dist.png'}`

## Pathogenicity

Potential ability of the variant to cause or to worsen a certain disease.

Potential ability of the variant to cause or to worsen a certain disease. Five levels are available:

- Pathogenic,
- Likely pathogenic,
- Variant of Unknown Significance (VUS),
- Likely benign,
- Benign.

### Example Pathogenicity

`Pathogenic`

## Clinical significance

Potential clinical actionability of the variant in a given disease.

Potential clinical actionability of the variant in given disease. Three types of clinical significance evidences are available according to guidelines.

- Predictive (therapeutic): variant that indicates sensitivity or resistance to a specific therapy.
- Prognostic: variant that predicts the course of a disease.
- Diagnostic: variant that supports the diagnosis of a disease.

### Example Clinical significance

`Predictive`

### Clinical significance reference

## Status

Status of the variant in the SVIP database.

Status of the variant in the SVIP database. Five statuses are available.

- Loaded: variant present in SVIP but not annotated.
- Under Curation: variant currently under manual curation.
- Curated: variant with manually curated evidences of pathogenicity and/or clinical significance.
- Under Review: curated variant submitted to the expert panel for review.
- Reviewed: curated variant that went through an expert panel decision.

### Example Status

`Curated`

## SVIP confidence

Not definitive: Level of confidence of the variant interpretation after curation and review process.

Level of confidence of the variant interpretation after curation and review process.

### Example SVIP confidence

``
