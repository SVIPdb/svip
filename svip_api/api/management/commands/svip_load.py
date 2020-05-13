import csv
import datetime
import random
import sys
import os
import json

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand, CommandError
from django.db.models import Q, F

from api.models import Variant, VariantInSVIP, Sample, CurationEntry, VariantInSource, DiseaseInSVIP, Disease, Gene

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


def create_svipvariants(source=SVIP_VARS_JSON, create_variant=False, delete_existing=True):
    """
    Loads variant info from SVIP mock data file into the db
    :param source source JSON file (defualt SVIP_VARS_JSON)
    :param create_variant create variants that don't exist instead of ignoring them
    :return: a tuple (succeeded, total) with the number of variants added vs. the total number tried, respectively
    """
    with open(source, "r") as fp:
        svip_variants = json.load(fp)

        if delete_existing:
            VariantInSVIP.objects.all().delete()
            DiseaseInSVIP.objects.all().delete()

        succeeded, total = (0, len(svip_variants))

        for s in svip_variants:
            try:
                if create_variant:
                    assembly, chromosome, position = s['position'].split(":")

                    # should we also create the gene if it doesn't exist?

                    target_variant, was_created = Variant.objects.get_or_create(
                        gene__symbol=s['gene_name'],
                        name=s['variant_name'],
                        hgvs_c__endswith=s['HGVScoding'][s['HGVScoding'].index(':')+1:],
                        defaults={
                            'gene': Gene.objects.get(symbol=s['gene_name']),
                            'name': s['variant_name'],
                            'description': "%s %s" % (s['gene_name'], s['variant_name']),
                            'refseq': s["HGVScoding"].split(":")[0],
                            'hgvs_c': s['HGVScoding'],
                            'reference_name': assembly,
                            'chromosome': chromosome,
                            'start_pos': int(position)
                        }
                    )
                else:
                    target_variant = Variant.objects.get(
                        gene__symbol=s['gene_name'],
                        name=s['variant_name'],
                        hgvs_c__endswith=s['HGVScoding'][s['HGVScoding'].index(':') + 1:]
                    )

                # check if it exists and bail if so
                if not delete_existing and VariantInSVIP.objects.filter(variant=target_variant).exists():
                    print("Variant %s already exists in SVIP, skipping..." % str(target_variant))
                    continue

                candidate = VariantInSVIP(
                    variant=target_variant,
                    data=s
                )
                candidate.save()

                # create disease entries keyed to this candidate, too
                for disease in s['diseases']:
                    candidate_disease = DiseaseInSVIP(
                        svip_variant=candidate,
                        disease=Disease.objects.filter(name__iexact=disease['name']).first(),
                        status=disease['SVIP_status'],
                        score=int(disease['score'])
                    )
                    candidate_disease.save()

                succeeded += 1
            except Gene.DoesNotExist:
                print(
                    "Couldn't find gene %s for variant w/name '%s', skipping..." %
                    (s['gene_name'], s['variant_name'])
                )
            except Variant.DoesNotExist:
                print(
                    "Couldn't find corresponding variant w/gene and name '%s %s', skipping..." %
                    (s['gene_name'], s['variant_name'])
                )

        return succeeded, total


def create_svip_samples(source):
    """
    Load samples from api/fixtures/<source> and insert them into Sample. Deletes the contents of Sample before insertion.

    :return: a tuple (succeeded, total) with the number of samples added vs. the total number tried, respectively
    """

    with open(os.path.join(APP_DIR, "fixtures", source), "r") as samples_fp:
        reader = csv.DictReader(samples_fp, dialect=csv.excel_tab)
        succeeded, total = (0, 0)

        Sample.objects.all().delete()

        for sample in reader:
            total += 1

            try:
                candidate = Sample(
                    disease_in_svip=DiseaseInSVIP.objects.get(
                        disease__name__iexact=sample['disease'],
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


def create_svip_curationentries(source):
    """
    Load curation entries from api/fixtures/<source> and insert them into CurationEntry. Deletes the contents of
    CurationEntry before insertion.

    :return: a tuple (succeeded, total) with the number of curation entries added vs. the total number tried, respectively
    """

    with open(os.path.join(APP_DIR, "fixtures", source), "r") as samples_fp:
        reader = csv.DictReader(samples_fp, dialect=csv.excel_tab)
        succeeded, total = (0, 0)

        CurationEntry.objects.all().delete()

        for curation_entry in reader:
            total += 1

            try:
                candidate = CurationEntry(
                    variant=Variant.objects.get(
                        gene__symbol=curation_entry['gene'],
                        name=curation_entry['variant'],
                        hgvs_c__endswith=curation_entry['cds']
                    ),
                    disease=Disease.objects.filter(
                        name__iexact=curation_entry['disease'],
                    ).first(),
                    owner=User.objects.get(username=curation_entry['owner_name']),
                    drugs=[x.strip() for x in curation_entry['drug'].split(", ")],
                    **dict(
                        (k, v.strip()) for k, v in curation_entry.items() if k not in ('gene', 'variant', 'cds', 'disease', 'drug', 'owner_name')
                    )
                )
                candidate.save()
                succeeded += 1
            except Disease.DoesNotExist:
                print(
                    "Couldn't find corresponding disease \"%s\" w/gene, name, cds '%s %s %s', skipping..." %
                    (curation_entry['disease'], curation_entry['gene'], curation_entry['variant'], curation_entry['cds'])
                )
            except Variant.DoesNotExist:
                print(
                    "Couldn't find corresponding variant \"%s\" w/gene, disease, cds '%s %s %s', skipping..." %
                    (curation_entry['variant'], curation_entry['gene'], curation_entry['disease'], curation_entry['cds'])
                )

        return succeeded, total


def synthesize_samples(num_samples_per_variant=10):
    """
    Creates "realistic" patient samples for each variant in SVIP. If USE_COSMIC_DISEASES is enabled, uses COSMIC for
    (disease, tissue) assocations with variants. If not, uses a hardcoded list drawn from the SVIP mock variants.

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
        if svip_var.diseaseinsvip_set.count() == 0:
            print("SVIP variant %s has no associated diseases, skipping sample synthesis..." % str(svip_var.description))
            continue

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
                'Adenocarcinoma of lung': 'Lung',
                'Non-small cell lung cancer': 'Lung',
                'Neoplasm of thyroid gland': 'Thyroid',
                'Adenocarcinoma of colorectum': 'Colorectal',
                'Malignant melanoma of skin': 'Skin',
                'Adenocarcinoma of prostate': 'Prostate',
            }
            disease_tissues = [
                {'disease': x['name'], 'tissue': tissues[x['name']]}
                for x in svip_var.diseaseinsvip_set.values(name=F('disease__name'))
            ]

        # for sex-specific diseases, we should only use one sex
        sex_specific = {
            'Adenocarcinoma of prostate': 'Male'
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
                'disease_in_svip': DiseaseInSVIP.objects.get(svip_variant=svip_var, disease__name__iexact=disease),
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
            '--svip-infile',
            help='SVIP variants JSON description file (default: %s)' % SVIP_VARS_JSON,
            default=SVIP_VARS_JSON
        )
        parser.add_argument(
            '--create-variants',
            action='store_true',
            help="Creates variant entries referenced in SVIP vars JSON if they don't already exist",
        )
        parser.add_argument(
            '--delete-existing',
            action='store_true',
            help="Drop existing SVIP variants before creation",
        )
        parser.add_argument(
            '--only-vars',
            action='store_true',
            help="Don't create samples or curation entries, just SVIP variants",
        )
        parser.add_argument(
            '--no-sample-synth',
            action='store_true',
            help='Use samples.tsv instead of creating samples dynamically',
        )

    def handle(self, *args, **options):
        created_count, total = create_svipvariants(
            source=options['svip_infile'],
            create_variant=options['create_variants'],
            delete_existing=options['delete_existing']
        )
        self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock variant entries' % (created_count, total)))

        if not options['only_vars']:
            if not options['no_sample_synth']:
                created_count, total = synthesize_samples(num_samples_per_variant=30)
                self.stdout.write(self.style.SUCCESS('Generated %d out of %d SVIP mock samples' % (created_count, total)))
            else:
                created_count, total = create_svip_samples("samples.tsv")
                self.stdout.write(self.style.SUCCESS('Loaded %d out of %d SVIP mock samples from \'samples.tsv\'' % (created_count, total)))

            created_count, total = create_svip_curationentries("curation.tsv")
            self.stdout.write(self.style.SUCCESS('Created %d out of %d SVIP mock curation entries' % (created_count, total)))
        else:
            self.stdout.write(self.style.NOTICE('only-vars is specified; skipping creating samples, curation entries'))
