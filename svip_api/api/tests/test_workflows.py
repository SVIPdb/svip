from django.contrib.auth.models import Group
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from api.models.svip import SubmissionEntry
from api.tests.data import create_user, create_variant, create_disease

URL_BULK_SUBMISSION_ENTRIES = 'http://localhost:8085/api/v1/submission_entries/bulk_submit'


class SubmissionEntryApi(TestCase):
    """
    Tests creating a submission entries from bulk submit
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

    def test_bulk_submit_submission_entry(self):
        variant = create_variant()
        disease = create_disease()
        payload = [
            {"owner_id": self.user.id,
             "variant_id": variant.id,
             "disease_id": disease.id,
             "effect": "Associated with diagnosis",
             "drug": "Fuflomicin",
             "curation_entries": [1214],
             "type_of_evidence": "Predictive / Therapeutic - Fuflomicin",
             "tier": "Reported evidence supportive of benign/likely benign effect"
             }]

        res = self.client.post(URL_BULK_SUBMISSION_ENTRIES, payload, format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK)

        submission_entries_count = SubmissionEntry.objects.count()
        self.assertEqual(submission_entries_count, 1)

        submission_entry = SubmissionEntry.objects.all()[0]
        self.assertEqual(submission_entry.variant.id, variant.id)
        self.assertEqual(submission_entry.owner.id, self.user.id)
