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

# CURATION_ENTRIES_URL = reverse('curation_entries')
URL_CURATION_ENTRIES = reverse('curation_entries-list')
URL_SUBMISSION_ENTRIES = reverse('submission_entry-list')
URL_CURATION_REVIEWS = reverse('reviews-list')


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


class UnauthorizedRequest(TestCase):
    """
    Test authentication is required to get  data from API.
    """

    def test_auth_required_to_get_curation_entries(self):
        res = self.client.get(URL_CURATION_ENTRIES)
        print(res.status_code)
        self.assertEqual(res.data['results'], [])

    def test_auth_required_to_get_submission_entries(self):
        res = self.client.get(URL_SUBMISSION_ENTRIES)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_auth_required_to_get_curation_reviews(self):
        res = self.client.get(URL_CURATION_REVIEWS)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


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
        for i in range(3):
            create_curation_entry()
        res = self.client.get(URL_CURATION_ENTRIES)
        curation_entries = CurationEntry.objects.all().order_by('-id')
        serializer = CurationEntrySerializer(curation_entries, many=True, context={'request': res.wsgi_request})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(serializer.data, res.data['results'], )
