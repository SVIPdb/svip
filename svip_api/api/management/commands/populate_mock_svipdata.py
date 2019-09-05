import csv
import datetime
import random
import sys
import os
import json
from django.core.management.base import BaseCommand, CommandError
from django.db.models import Q, F

from api.models import Variant, VariantInSVIP, Sample, CurationEntry, VariantInSource, Disease

import api


APP_DIR = os.path.dirname(api.__file__)
SVIP_VARS_JSON = os.path.join(APP_DIR, "fixtures", "svip_variants.json")

# consult COSMIC for disease/tissue types relevant to this variant; otherwise, use the SVIP mock data
USE_COSMIC_DISEASES = False

CALLERS = [
    'Freebayes',
    'SOAPsnp',
    'realSFS',
    'SAMtools',
    'GATK',
    'Beagle',
    'IMPUTE2',
    'MaCH',
    'SNVmix',
    'VarScan',
    'DeepVariant',
    'Somaticsniper',
    'JointSNVMix',
    'NGSEP',
    'VarDict',
    'Reveel'
]
ALIGNERS = [
    'Arioc',
    'BarraCUDA',
    'BBMap',
    'BFAST',
    'BigBWA',
    'BLASTN',
    'BLAT',
    'Bowtie',
    'BWA',
    'BWA-PSSM',
    'CASHX',
    'Cloudburst',
    'CUDA-EC',
    'CUSHAW',
    'CUSHAW2',
    'CUSHAW2-GPU',
    'CUSHAW3',
    'drFAST',
    'ELAND',
    'ERNE',
    'GASSST',
    'GEM',
    'Genalice MAP',
    'Geneious Assembler',
    'GensearchNGS',
    'GMAP and GSNAP',
    'GNUMAP',
    'HIVE-hexagon',
    'IMOS',
    'Isaac',
    'LAST',
    'MAQ',
    'MOM',
    'MOSAIK',
    'MPscan',
    'Novoalign & NovoalignCS',
    'NextGENe',
    'NextGenMap',
    'Omixon Variant Toolkit',
    'PALMapper',
    'Partek Flow',
    'PASS',
    'PerM',
    'PRIMEX',
    'QPalma',
    'RazerS',
    'REAL, cREAL',
    'RMAP',
    'rNA',
    'RTG Investigator',
    'Segemehl',
    'SeqMap',
    'Shrec',
    'SHRiMP',
    'SLIDER',
    'SOCS',
    'SparkBWA',
    'Stampy',
    'SToRM',
    'Taipan',
    'UGENE',
    'VelociMapper',
    'XpressAlign',
    'ZOOM'
]


def create_svipvariants(model_variant, model_svip_variant):
    """
    Loads variant info from SVIP mock data file (api/fixtures/svip_variants.json) into the db
    :param model_variant: the variant model
    :param model_svip_variant: the variantinsvip model
    :return: a tuple (succeeded, total) with the number of variants added vs. the total number tried, respectively
    """
    with open(SVIP_VARS_JSON, "r") as fp:
        svip_variants = json.load(fp)

        model_svip_variant.objects.all().delete()
        Disease.objects.all().delete()

        succeeded, total = (0, len(svip_variants))

        for s in svip_variants:
            try:
                target_variant = model_variant.objects.get(
                    gene__symbol=s['gene_name'],
                    name=s['variant_name'],
                    hgvs_c__endswith=s['HGVScoding'][s['HGVScoding'].index(':')+1:]
                )
                candidate = model_svip_variant(
                    variant=target_variant,
                    data=s
                )
                candidate.save()

                # create disease entries keyed to this candidate, too
                for disease in s['diseases']:
                    candidate_disease = Disease(
                        svip_variant=candidate,
                        name=disease['name'],
                        status=disease['SVIP_status'],
                        score=int(disease['score'])
                    )
                    candidate_disease.save()

                succeeded += 1
            except model_variant.DoesNotExist:
                print(
                    "Couldn't find corresponding variant w/gene and name '%s %s', skipping..." %
                    (s['gene_name'], s['variant_name'])
                )

        return succeeded, total


def create_svip_related(source, target_model):
    """
    Load samples from api/fixtures/<source> and insert them into target_model. Deletes the contents of
    target_model before insertion. The target_model should have a field 'disease', and source should
    contain a header with entries that have the same names as target_models' fields. source must also
    contain the fields 'gene', 'variant', and 'cds', which are used to link the new entry to an existing
    Disease entry (indirectly using VariantInSVIP to match up to the correct variant).

    :return: a tuple (succeeded, total) with the number of samples added vs. the total number tried, respectively
    """
    with open(os.path.join(APP_DIR, "fixtures", source), "r") as samples_fp:
        reader = csv.DictReader(samples_fp, dialect=csv.excel_tab)
        succeeded, total = (0, 0)

        target_model.objects.all().delete()

        for sample in reader:
            total += 1

            try:
                candidate = target_model(
                    disease=Disease.objects.get(
                        name__iexact=sample['disease'],
                        svip_variant__variant__gene__symbol=sample['gene'],
                        svip_variant__variant__name=sample['variant'],
                        svip_variant__variant__hgvs_c__endswith=sample['cds']
                    ),
                    **dict(
                        (k, v.strip()) for k, v in sample.items() if k not in ('gene', 'variant', 'cds', 'disease')
                    )
                )
                candidate.save()
                succeeded += 1
            except Disease.DoesNotExist:
                print(
                    "Couldn't find corresponding disease \"%s\" w/gene, name, cds '%s %s %s', skipping..." %
                    (sample['disease'], sample['gene'], sample['variant'], sample['cds'])
                )

        return succeeded, total


def synthesize_samples(num_samples_per_variant=10):
    """
    Creates "realistic" patient samples for each variant in SVIP. Uses COSMIC for (disease, tissue) assocations
    with variants.
    :param num_samples_per_variant: the number of samples to synthesize for each variant
    :return: the total number of created samples
    """

    sample_id = random.randint(5000, 9000)
    created_samples = 0
    svip_variants = VariantInSVIP.objects.all()

    # delete all the samples before we begin
    Sample.objects.all().delete()

    # for each SVIP variant, produce a random amount of randomly-generated sample data
    for svip_var in svip_variants:
        # get (disease, tissue) pairs from COSMIC for the current variant
        if USE_COSMIC_DISEASES:
            disease_tissues = (
                VariantInSource.objects
                    .filter(
                        # ~Q(association__phenotype__term__in=('other', 'NS')),
                        # variant=svip_var.variant,
                        source__name='cosmic'
                    )
                    .values(
                        disease=F('association__phenotype__term'),
                        tissue=F('association__environmentalcontext__description')
                    ).distinct()
            )
        else:
            tissues = {
                'Lung Adenocarcinoma': 'Lung',
                'Non-Small Cell Lung Cancer': 'Lung',
                'Non-Small Cell Lung Carcinoma': 'Lung',
                'Papillary Thyroid Carcinoma': 'Thyroid',
                'Breast Cancer': 'Breast',
                'Colorectal Cancer': 'Colorectal',
                'Skin Melanoma': 'Skin',
                'Prostate Cancer': 'Prostate',
            }
            disease_tissues = [{'disease': x['name'], 'tissue': tissues[x['name']]} for x in svip_var.disease_set.values('name')]

        # for sex-specific diseases, we should only use one sex
        sex_specific = {
            'Prostate Cancer': 'Male'
        }


        # TODO: decide if the sample data and hospital should be the same for all samples for this variant or not

        # generate a random sampling date for all samples in the same set
        sample_date = datetime.date(random.randint(2016, 2018), random.randint(1, 12), 1) + \
                      datetime.timedelta(days=random.randint(0, 30))

        sample_parts = {
            'year': sample_date.year,
            'month': sample_date.month,
            'day': sample_date.day
        }

        # presumably the samples for the same variant will come from the sample hospital, too?
        hospital = random.choice(('USZ', 'USB'))
        caller = '-'  # random.choice(CALLERS)
        aligner = '-'  # random.choice(ALIGNERS)

        for _ in range(num_samples_per_variant):
            disease, tissue = [x.replace('_', ' ').title() for x in random.choice(disease_tissues).values()]

            candidate = Sample(**{
                'disease': Disease.objects.get(svip_variant=svip_var, name=disease),
                'sample_id': str(sample_id),
                'year_of_birth': str(random.randint(1935, 1988)),
                'gender': random.choice(('Male', 'Female')) if disease not in sex_specific else sex_specific[disease],
                'hospital': hospital,
                'medical_service': 'Pathology',
                'provider_annotation': random.choice(('Pathogenic', '-')),
                'sample_tissue': tissue,
                'tumor_purity': '%d%%' % random.randint(80, 92),
                'tnm_stage': 'T0N2M1',
                'sample_type': 'Primary',
                'sample_site': 'Biopsy',
                'specimen_type': 'FFPE',
                'sequencing_date': '%(day)02d.%(month)02d.%(year)d' % sample_parts,
                'panel': 'Hotspot v2',
                'coverage': random.randint(1500, 1600),
                'calling_strategy': random.choice(('Matched', 'Tumor only')),
                'caller': caller,
                'aligner': aligner,
                'software': 'Torrent Suite',
                'software_version': '5.10',
                'platform': 'Ion Torrent Proton',
                'contact': 'mailto:Dr_Onco@hospital.ch'
            })
            candidate.save()

            sample_id += random.randint(300, 2000)
            created_samples += 1

    return created_samples, len(svip_variants) * num_samples_per_variant


class Command(BaseCommand):
    help = 'Populates database with SVIP mock variants'

    def add_arguments(self, parser):
        parser.add_argument(
            '--no-sample-synth',
            action='store_true',
            help='Use samples.tsv instead of creating samples dynamically',
        )

    def handle(self, *args, **options):
        created_count, total = create_svipvariants(Variant, VariantInSVIP)
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock variant entries' % (created_count, total)))

        if not options['no_sample_synth']:
            created_count, total = synthesize_samples(num_samples_per_variant=30)
            self.stdout.write(self.style.SUCCESS('Generated %d out of %d SVIP mock samples' % (created_count, total)))
        else:
            created_count, total = create_svip_related("samples.tsv", Sample)
            self.stdout.write(self.style.SUCCESS('Loaded %d out of %d SVIP mock samples from \'samples.tsv\'' % (created_count, total)))

        created_count, total = create_svip_related("curation.tsv", CurationEntry)
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock curation entries' % (created_count, total)))
