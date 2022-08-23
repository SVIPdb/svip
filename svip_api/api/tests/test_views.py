from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from api.models.genomic import Variant, Gene
from django.contrib.auth.models import Group
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from api.models import CurationEntry
from api.serializers import CurationEntrySerializer
from api.tests.data import create_curation_entry, create_user


class ViewTests(APITestCase):
    def setUp(self):
        gene = Gene.objects.create(
            entrez_id=673,
            ensembl_gene_id='ENSG00000157764',
            symbol='BRAF'
        )
        variant = Variant.objects.create(
            gene=gene,
            name='V600E',
            description='BRAF V600E'
        )

    def test_variant_list(self):
        """ Test the variant list """
        url = reverse('variant-list')
        response = self.client.get(url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        data = response.json()
        self.assertEqual(data['count'], 1, "We expect 1 result")
        self.assertEqual(data['results'][0]['name'], 'V600E', "We expenct the variant name to be 'V600E")


# CURATION_ENTRIES_URL = reverse('curation_entries')
URL = 'http://localhost:8085/api/v1/curation_entries'


class UnauthorizedRequest(TestCase):
    """
    Test authentication and being is required to get the curation entries data from API.
    """

    def test_auth_required(self):
        res = self.client.get(URL)
        self.assertEqual(res.data['results'], [])


class CurationEntryApiForCurators(TestCase):
    """
    Tests authenticated API requests for users in the curation group
    """

    def setUp(self):
        self.client = APIClient()
        self.user = create_user({
            "username": "test_user2",
            "password": "testpass123"
        })
        # put this user in the 'curators' group
        curators_group = Group.objects.get(name='curators')
        curators_group.user_set.add(self.user)

        self.client.force_authenticate(self.user)

    def test_retrieve_curation_entries(self):
        # create several curation entries in the db
        create_curation_entry()
        create_curation_entry()
        create_curation_entry()

        res = self.client.get(URL)
        curation_entries = CurationEntry.objects.all().order_by('-id')
        serializer = CurationEntrySerializer(curation_entries, many=True, context={'request': res.wsgi_request})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(serializer.data, res.data['results'], )


