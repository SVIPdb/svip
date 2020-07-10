from django.http import Http404
from rest_framework import permissions, status
from rest_framework.permissions import BasePermission, SAFE_METHODS


# gives view/edit permissions to anyone who's a curator, not just the owner
from rest_framework.request import clone_request
from rest_framework.response import Response

ALLOW_ANY_CURATOR = True

# curation with these statuses are visible by the public
PUBLIC_VISIBLE_STATUSES = ('reviewed', 'unreviewed')

class IsCurationPermitted(BasePermission):
    """
    Curation entries are visible by everyone *if* they're reviewed. They're editable by nobody except the curator
    who created them, but only if they're drafts or saved.

    If they're not reviewed, then an entry is visible to a curator if they own it. Reviewers can see submitted
    """

    @staticmethod
    def is_user_allowed(user, obj, is_reading):
        """
        Returns True if the user is permitted to access this curation entry (either for viewing if is_reading or writing if not).
        :param user: the user for whom to compute permissions
        :param obj: the curation entry to check
        :param is_reading: is the requested operation read-only?
        :return: True if they can access it, false otherwise
        """

        # superusers are almighty
        if user.is_superuser:
            return True

        if user.groups.filter(name='curators'):
            if not is_reading:
                # curators can only edit their own drafts or saved entries
                # submitted and reviwed entries are always static to curators
                return (obj.owner == user or ALLOW_ANY_CURATOR) and obj.status in ('draft', 'saved')
            else:
                # curators can see their own entries and only others' reviewed entries
                return (obj.owner == user or ALLOW_ANY_CURATOR) or obj.status == 'reviewed'
        elif user.groups.filter(name='reviewers'):
            # FIXME: create a group called 'reviewers'
            if not is_reading:
                # reviewers can't change anything
                # (side note, reviewers provide their approval on a cross table that relates reviewers and curation entries)
                return False
            else:
                # reviewers can see anything that's submitted or reviewed
                # FIXME: eventually they should only see things they've been assigned, which we'll check in the cross-table
                return obj.status in ('submitted', 'reviewed', 'unreviewed')
        else:
            # ok, they're authenticated but not in any known group, so we must give them the default permissions
            return obj.status in PUBLIC_VISIBLE_STATUSES

    def has_permission(self, request, view):
        # superusers have all permissions
        if request.user.is_superuser:
            return True

        # only curators can write to curation entries
        if not request.user.groups.filter(name='curators') and request.method not in SAFE_METHODS:
            return False

        return super().has_permission(request, view)

    def has_object_permission(self, request, view, obj):
        if not request.user or not request.user.is_authenticated:
            # for unauthenticated users, we can only return entries that are in the list of public-visible statuses
            return obj.status in IsCurationPermitted.PUBLIC_VISIBLE_STATUSES

        return IsCurationPermitted.is_user_allowed(
            user=request.user,
            obj=obj,
            is_reading=request.method in SAFE_METHODS
        )


def authed_curation_set(user):
    """
    Returns a QuerySet of CurationEntry instances that this user should be able to view
    :param user: the user against which to evaluate CurationEntry permissions
    :return: a QuerySet of CurationEntries visible to the given user
    """
    from api.models import CurationEntry
    result = None

    if user.is_authenticated:
        groups = [x.name for x in user.groups.all()]
        if user.is_superuser:
            # superusers can see everything
            result = CurationEntry.objects.all()
        if 'curators' in groups:
            # curators see only their own entries if ALLOW_ANY_CURATOR is false
            # if it's true, they can see any curation entry
            result = CurationEntry.objects.filter(owner=user) if not ALLOW_ANY_CURATOR else CurationEntry.objects.all()
        elif 'reviewers' in groups:
            # FIXME: should reviewers see all entries, or just the ones they've been assigned?
            result = CurationEntry.objects.filter(status__in=('reviewed', 'submitted', 'unreviewed'))

    if not result:
        # unauthenticated users and other users who don't have specific roles just see the default set
        result = CurationEntry.objects.filter(status__in=PUBLIC_VISIBLE_STATUSES)

    return result


class IsSampleViewer(permissions.BasePermission):
    """
    Allows only individuals with the view_sample permission to view samples.
    """

    def has_object_permission(self, request, view, obj):
        return request.user.has_perm('api.view_sample')


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    Assumes the model instance has an `owner` attribute.
    """

    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Instance must have an attribute named `owner`.
        return obj.owner == request.user


# noinspection PyUnresolvedReferences
class AllowUpdateAsCreateMixin(object):
    """
    The following mixin class may be used in order to support PUT-as-create
    behavior for incoming requests.
    """

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object_or_none()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)

        if instance is None:
            lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
            lookup_value = self.kwargs[lookup_url_kwarg]
            extra_kwargs = {
                self.lookup_field: lookup_value
            }
            serializer.save(**extra_kwargs)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        serializer.save()
        return Response(serializer.data)

    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)

    def get_object_or_none(self):
        try:
            return self.get_object()
        except Http404:
            if self.request.method in ('PUT', 'PATCH'):
                # For PUT-as-create operation, we need to ensure that we have
                # relevant permissions, as if this was a POST request.  This
                # will either raise a PermissionDenied exception, or simply
                # return None.
                self.check_permissions(clone_request(self.request, 'POST'))
            else:
                # PATCH requests where the object does not exist should still
                # return a 404 response.
                # FA: this has been revised to allow us to
                raise
