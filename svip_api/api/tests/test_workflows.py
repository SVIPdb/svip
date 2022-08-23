from django.contrib.auth.models import Group
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from api.models.svip import SubmissionEntry, CurationReview
from api.tests.data import create_user, create_variant, create_disease, create_submission_entry

URL_BULK_SUBMISSION_ENTRIES = 'http://localhost:8085/api/v1/submission_entries/bulk_submit'
URL_SUBMISSION_ENTRY = reverse('submission_entry-list')
URL_SUBMIT_CURATION_REVIEW = 'http://localhost:8085/api/v1/reviews/submit_review'


class SubmissionEntryApi(TestCase):
    """
    Tests creating a submission entries from bulk submit and retrieving submission entries as a list or by a variant.
    """

    def setUp(self):
        self.client = APIClient()
        self.user = create_user({
            "username": "test_user2",
            "password": "testpass123"
        })
        # put this user in the 'curators' group
        curators_group = Group.objects.get(name='curators')
        clinicians_group = Group.objects.get(name='clinicians')
        curators_group.user_set.add(self.user)
        clinicians_group.user_set.add(self.user)

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

    def test_retrieving_submission_entries(self):
        create_submission_entry()
        create_submission_entry()
        res = self.client.get(URL_SUBMISSION_ENTRY)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEquals(len(res.data['results']), 2)

    def test_retrieving_submission_entries_for_specific_variant(self):
        variant = create_variant()
        create_submission_entry(variant_id=variant.id)
        create_submission_entry()
        res = self.client.get(URL_SUBMISSION_ENTRY, {'variant_id': variant.id})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEquals(len(res.data['results']), 1)
        self.assertEquals(res.data['results'][0]['variant']['id'], variant.id)


class CurationReviewApi(TestCase):
    """
    Tests creating and submitting curation reviews.
    """

    def setUp(self):
        self.client = APIClient()
        self.user = create_user({
            "username": "test_user3",
            "password": "testpass123"
        })
        # put this user in the 'clinicians' group
        clinicians_group = Group.objects.get(name='clinicians')
        clinicians_group.user_set.add(self.user)

        self.client.force_authenticate(self.user)

    def test_submit_curation_review(self):
        submission_entry = create_submission_entry()
        payload = {'submission_entry': submission_entry.id,
                   'annotated_effect': 'Poor outcome',
                   'annotated_tier': 'IID Tier',
                   'comment': 'Some comment',
                   'draft': True,
                   'reviewer': self.user.id}
        res = self.client.post(URL_SUBMIT_CURATION_REVIEW, payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        curation_reviews_count = CurationReview.objects.count()
        self.assertEqual(curation_reviews_count, 1)


