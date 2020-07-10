from django.contrib import admin

# Register your models here.
from api.models import VariantInSVIP, DiseaseInSVIP, Variant, CurationEntry


@admin.register(Variant)
class VariantAdmin(admin.ModelAdmin):
    list_filter = ('gene__symbol',)
    ordering = ('gene__symbol', 'name')
    search_fields = ('gene__symbol', 'name', 'hgvs_c')

@admin.register(VariantInSVIP)
class VariantInSVIPAdmin(admin.ModelAdmin):
    autocomplete_fields = ['variant']

admin.site.register(DiseaseInSVIP)

@admin.register(CurationEntry)
class CurationEntryAdmin(admin.ModelAdmin):
    autocomplete_fields = ['variant']
