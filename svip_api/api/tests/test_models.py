from django.test import TestCase

class ModelTests(TestCase):
    def test_model_choice_class(self):
      """ Testing the Model Choice Class """
      from api.utils import ModelChoice
      class MyModelChoice(ModelChoice):
        prop1='Prop1'
        prop2='Prop2'

      choices = MyModelChoice.get_choices()
      self.assertEqual(choices, [
        ('prop1', 'Prop1'),
        ('prop2', 'Prop2')
      ])


