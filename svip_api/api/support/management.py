from django.db import models


def boolean_input(question, default=None):
    """
    Prompts the user running a management command for confirmation, returning whether True if they pressed 'Y' or 'y',
    or 'default' if nothing was pressed.
    :param question: the prompt
    :param default: the default return value if nothing is entered
    :return: True if 'Y' or 'y' was pressed, false otherwise
    """
    result = input("%s " % question)
    if not result and default is not None:
        return default
    while len(result) < 1 or result[0].lower() not in "yn":
        result = input("Please answer yes or no: ")
    return result[0].lower() == "y"


def set_natural_key(fields):
    """
    Allows a django Model class to be naturally serialized/deserialized by 'fields'.

    When decorating a model.Model, it either updates its existing manager to include
    a 'get_by_natural_key' method, or creates a new manager if one doesn't already exist.

    Also adds 'natural_key' on the model, which

    :param fields: fields from the model to use during (de)serialization, should uniquely identify the instance
    :return: the decorated class
    """
    def __naturalize(cls):
        class _InternalManager(type(cls.objects)):
            # create 'natural key' methods using the specified fields on this object
            def get_by_natural_key(self, *args):
                return self.get(**dict(zip(fields, args)))

        _InternalManager.__name__ = '%sManager' % cls.__name__
        cur_mgr = _InternalManager

        def natural_key(self):
            return tuple(getattr(self, k) for k in fields)

        # annotate the manager, then annotate the class with its new manager + natural_key method
        setattr(cls, 'objects', cur_mgr)
        setattr(cls, 'natural_key', natural_key)

        return cls

    return __naturalize


