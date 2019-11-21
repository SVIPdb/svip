from rest_framework.permissions import BasePermission, SAFE_METHODS


# gives view/edit permissions to anyone who's a curator, not just the owner
ALLOW_ANY_CURATOR = True


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
                return obj.status in ('submitted', 'reviewed')
        else:
            # ok, they're authenticated but not in any known group, so we must give them the default permissions
            return obj.status == 'reviewed'

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
            # for unauthenticated users, we can only return entries that are reviewed
            return obj.status == 'reviewed'

        return IsCurationPermitted.is_user_allowed(
            user=request.user,
            obj=obj,
            is_reading=request.method in SAFE_METHODS
        )
