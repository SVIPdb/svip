from django.core.management.base import BaseCommand
from api.models.genomic import Variant
import re


amino_acids = {
    "Ala": "A",
    "Arg": "R",
    "Asn": "N",
    "Asp": "D",
    "Cys": "C",
    "Gln": "Q",
    "Glu": "E",
    "Gly": "G",
    "His": "H",
    "Ile": "I",
    "Leu": "L",
    "Lys": "K",
    "Met": "M",
    "Phe": "F",
    "Pro": "P",
    "Ser": "S",
    "Thr": "T",
    "Trp": "W",
    "Tyr": "Y",
    "Val": "V",
    "Sec": "U",
    "Pyl": "O",
    "Ter": "X",
    "*": "X"
}


def end_section(variant_name):
    search_digit = True
    counter = 0
    for char in variant_name:
        if search_digit:
            if char.isdigit():
                search_digit = False
        else:
            if not char.isdigit():
                return variant_name[counter:]
        counter += 1


def get_AA_2(string):
    # initializing a new string to apppend only alphabets
    only_alpha = ""
    # looping through the string to find out alphabets
    for char in string:
        # ord(chr) returns the ascii value
        is_uppercase = ord(char) >= 65 and ord(char) <= 90
        is_lowercase = ord(char) >= 97 and ord(char) <= 122
        is_stop = char == '*'
        if is_uppercase or is_lowercase or is_stop:
            only_alpha += char
    # return the string which contains only alphabets
    return only_alpha


def change_variant_names():

    for variant in Variant.objects.filter(id__lte=2000).all():
        if variant.hgvs_p != None:
            variant_name = re.split('[.]', variant.hgvs_p)[2]
            AA_1 = re.findall('([a-zA-Z ]*)\d*.*', variant_name)[0]
            if variant_name != '?':
                variant_name = variant_name.replace(AA_1, amino_acids[AA_1])
            AA_2 = get_AA_2(end_section(variant_name))[0:3]
            if AA_2 in amino_acids:
                variant_name = variant_name.replace(AA_2, amino_acids[AA_2])

        else:
            AA_1 = re.findall('([a-zA-Z ]*)\d*.*', variant.name)[0]
            if AA_1 in amino_acids:
                variant_name = variant_name.replace(AA_1, amino_acids[AA_1])
            AA_2 = get_AA_2(end_section(variant_name))[0:3]
            if AA_2 in amino_acids:
                variant_name = variant_name.replace(AA_2, amino_acids[AA_2])

        # variant.save()
        print(variant.name)


class Command(BaseCommand):
    help = 'Harmonize all the names of the variant using their HGVSp expression'

    def handle(self, *args, **options):
        change_variant_names()
