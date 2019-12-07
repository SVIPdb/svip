from django.conf import settings
from django.db import models
from django.utils.timezone import now
from django_db_cascade.deletions import DB_CASCADE


# =====================================================================================================================
# === abstract comment/tag type/tag definitions
# =====================================================================================================================

class Comment(models.Model):
    """
    An abstract comment, which has text, datetime info, and an owner.

    You can inherit from this class to associate comments with specific database entities, e.g., the VariantComment
    class below.
    """
    text = models.TextField()
    created_on = models.DateTimeField(default=now, db_index=True)
    last_modified = models.DateTimeField(auto_now=True, db_index=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=DB_CASCADE)

    def owner_name(self):
        fullname = ("%s %s" % (self.owner.first_name, self.owner.last_name)).strip()
        return fullname if fullname else self.owner.username

    class Meta:
        abstract = True


class TagType(models.Model):
    """
    Types of tags, which can be referenced by a Tag instance.
    """
    text = models.TextField(db_index=True)
    created_on = models.DateTimeField(default=now, db_index=True)


class Tag(models.Model):
    """
    A tag associated with a specific comment, of type TagType.
    """
    type = models.ForeignKey(TagType, on_delete=DB_CASCADE)
    created_on = models.DateTimeField(default=now, db_index=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=DB_CASCADE)

    class Meta:
        abstract = True


# =====================================================================================================================
# === concrete comment, tag classes
# =====================================================================================================================

class VariantComment(Comment):
    """
    A comment on a specific variant.
    """
    variant = models.ForeignKey('Variant', on_delete=DB_CASCADE)


class VariantTag(Tag):
    """
    A tag associated with a comment on a variant.
    """
    comment = models.ForeignKey(VariantComment, on_delete=DB_CASCADE)
