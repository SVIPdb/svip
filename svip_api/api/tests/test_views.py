from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from api.models.genomic import Variant, Gene

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

    