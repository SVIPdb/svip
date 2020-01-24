from django.contrib.postgres.fields import JSONField
from django.db import models
from django.utils.timezone import now
from django_db_cascade.deletions import DB_CASCADE


RUN_STATUSES = (
    'running',
    'success',
    'failure'
)


class HarvestRun(models.Model):
    """
    Keeps track of runs of the public database harvester.

    Before a run, an entry should be created, with the harvester holding a reference to the new entry. After a run,
    the success or failure state, any additional output, and statistics should be updated.
    """

    started_on = models.DateTimeField(default=now)
    ended_on = models.DateTimeField(null=True)
    status = models.TextField(choices=zip(RUN_STATUSES, RUN_STATUSES), default='running')
    output = models.TextField(null=True)
    stats = JSONField(null=True)
