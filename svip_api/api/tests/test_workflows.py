from django.contrib.auth.models import Group
from django.test import TestCase
from django.urls import reverse, resolve
from rest_framework import status
from rest_framework.test import APIClient
import copy

from api.models.svip import SubmissionEntry, CurationReview, CurationEntry
from api.tests.data import create_user, create_variant, create_disease, create_submission_entry, create_review, \
    create_curation_request, create_curation_entry
from api.serializers.svip import CurationReviewSerializer
from api.views.svip import SubmissionEntryViewSet

# https://www.django-rest-framework.org/api-guide/testing/


URL_SUBMISSION_ENTRY = reverse('submission_entry-list')
URL_CURATION_REVIEWS = reverse('reviews-list')

URL_BULK_SUBMISSION_ENTRIES = reverse('submission_entry-bulk-submit')
URL_SUBMIT_CURATION_REVIEW = reverse('reviews-submit-review')
URL_BULK_CURATION_REVIEWS = reverse('reviews-bulk-submit')


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
             },
            {"owner_id": self.user.id,
             "variant_id": variant.id,
             "disease_id": disease.id,
             "effect": "Not associated with diagnosis",
             "drug": "Fuflomicin",
             "curation_entries": [1214],
             "type_of_evidence": "Predictive / Therapeutic - Fuflomicin",
             "tier": "Reported evidence supportive of benign/likely benign effect"
             }
        ]

        res = self.client.post(URL_BULK_SUBMISSION_ENTRIES, payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        submission_entries_count = SubmissionEntry.objects.count()
        self.assertEqual(submission_entries_count, 2)

        submission_entry_1, submission_entry_2 = SubmissionEntry.objects.all()[0], SubmissionEntry.objects.all()[1]
        self.assertEqual(submission_entry_1.variant.id, variant.id)
        self.assertEqual(submission_entry_1.owner.id, self.user.id)
        self.assertEqual(submission_entry_2.effect, payload[1]['effect'])

    def test_retrieving_submission_entries(self):
        for i in range(2):
            create_submission_entry()
        res = self.client.get(URL_SUBMISSION_ENTRY)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEquals(len(res.data['results']), 2)

    def test_retrieving_submission_entries_for_specific_variant(self):
        variant = create_variant()
        create_submission_entry(variant=variant)
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
                   'effect': 'Poor outcome',
                   'tier': 'IID Tier',
                   'comment': 'Some comment',
                   'draft': True,
                   'reviewer': self.user.id,
                   'acceptance': True}
        res = self.client.post(URL_SUBMIT_CURATION_REVIEW, payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        curation_reviews_count = CurationReview.objects.count()
        self.assertEqual(curation_reviews_count, 1)

    def test_bulk_submit_curation_reviews(self):
        submission_entry = create_submission_entry()
        review1 = {'submission_entry': submission_entry.id,
                   'effect': 'Poor outcome',
                   'tier': 'IID Tier',
                   'comment': 'Some comment',
                   'draft': True,
                   'reviewer': self.user.id,
                   'acceptance': True}

        review2 = copy.deepcopy(review1)
        review3 = copy.deepcopy(review1)
        review2['effect'] = 'Some other effect'
        review2['tier'] = 'Some other tier'

        payload = {"data": [
            ['Some diseases, NOS', [review1]],
            ['Other diseases, NOS', [review2, review3]]
        ]}

        res = self.client.post(URL_BULK_CURATION_REVIEWS, payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        curation_reviews_count = CurationReview.objects.count()
        self.assertEqual(curation_reviews_count, 3)

    def test_retrieve_reviews(self):
        review_1 = create_review()
        review_2 = create_review(annotated_effect='Some other effect')
        review_3 = create_review(annotated_tier='Some other tier')

        reviews = CurationReview.objects.all().order_by('id')
        reviews_count = CurationReview.objects.count()

        res = self.client.get(URL_CURATION_REVIEWS)
        serializer = CurationReviewSerializer(reviews, many=True, context={'request': res.wsgi_request})

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(reviews_count, 3)
        self.assertEqual(serializer.data, res.data['results'])
        self.assertEqual(res.data['results'][1]['comment'], review_1.comment)
        self.assertEqual(res.data['results'][1]['annotated_effect'], review_2.annotated_effect)
        self.assertEqual(res.data['results'][2]['annotated_tier'], review_3.annotated_tier)


class VariantStatusChanging(TestCase):
    """
    Tests changing variant status during the workflow.
    """

    def setUp(self):
        self.client = APIClient()
        self.user = create_user({
            "username": "test_user_workflow",
            "password": "testpass123"
        })
        # put this user in the 'clinicians' and 'curators' group
        curators_group = Group.objects.get(name='curators')
        clinicians_group = Group.objects.get(name='clinicians')
        curators_group.user_set.add(self.user)
        clinicians_group.user_set.add(self.user)
        self.variant = create_variant()

    def test_stage_is_none(self):
        """
        Tests status is 'none' if there are no curation requests.
        """
        self.assertEqual(self.variant.stage, 'none')

    def test_stage_is_loaded(self):
        """
        Tests status is 'loaded' if there is a curation request.
        """
        create_curation_request(variant=self.variant)
        self.assertEqual(self.variant.stage, 'loaded')

    def test_stage_is_changing_in_workflow(self):
        """
        Tests stage is changing correctly during the workflow.
        """

        create_curation_entry(variant=self.variant)
        self.assertEqual(self.variant.stage, 'ongoing_curation')

        CurationEntry.objects.all().update(status='submitted')
        submission_entry = create_submission_entry(variant=self.variant, owner=self.user)
        CurationEntry.objects.all().update(submission_entry=submission_entry)

        self.assertEqual(self.variant.stage, 'annotated')

        review_1 = create_review(submission_entry=submission_entry)
        self.assertEqual(self.variant.stage, 'ongoing_review')

        review_2 = create_review(submission_entry=submission_entry, annotated_tier='Some other tier', acceptance=False)
        review_3 = create_review(submission_entry=submission_entry, annotated_effect='Some other effect',
                                 acceptance=False)
        self.assertEqual(self.variant.stage, 'unapproved')

        CurationReview.objects.filter(id=review_3.id).update(acceptance=True)
        self.assertEqual(self.variant.stage, 'unapproved')

        CurationReview.objects.filter(id=review_2.id).update(acceptance=True)
        self.assertEqual(self.variant.stage, 'approved')

        CurationEntry.objects.all().update(status='resubmitted')
        CurationReview.objects.all().delete()
        self.assertEqual(self.variant.stage, 'reannotated')
