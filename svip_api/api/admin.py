from django.contrib import admin
from simple_history.admin import SimpleHistoryAdmin

from api.models import (VariantInSVIP, DiseaseInSVIP, Variant, CurationEntry, SubmittedVariant, 
                        SubmittedVariantBatch)

from api.models.genomic import VariantStatus

from api.models.svip import (SummaryComment, CurationAssociation, CurationEvidence, CurationReview,
                             SIBAnnotation1, SIBAnnotation2, SummaryDraft, CurationRequest, 
                            )

admin.site.register(SummaryComment)
admin.site.register(SummaryDraft)
admin.site.register(CurationReview)
admin.site.register(SIBAnnotation1)
admin.site.register(SIBAnnotation2)
admin.site.register(CurationRequest)

admin.site.register(VariantStatus)


@admin.register(CurationAssociation)
class CurationAssociationAdmin(admin.ModelAdmin):
    list_display = ('variant', 'variant_id', 'disease')

    def variant_id(self, obj):
        return obj.variant.id


class CurationsInlineAdmin(admin.TabularInline):
    model = CurationEntry
    # no extra empty rows for in curation entry field of CurationEvidence
    extra = 0


@admin.register(CurationEvidence)
class CurationEvidenceAdmin(admin.ModelAdmin):
    fields = ['association', 'type_of_evidence', 'drug']
    #inlines = [CurationsInlineAdmin]


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
class CurationEntryAdmin(SimpleHistoryAdmin):
    search_fields = (
        'disease__icd_o_morpho__term',
        'variant__description',
        'type_of_evidence',
        'drugs',
        'interactions',
        'effect',
        'tier_level_criteria',
        'tier_level',
        'mutation_origin',
        'associated_mendelian_diseases',
        'summary',
        'support',
        'comment',
        'references',
        'annotations',
        'owner__username'
    )
    list_display = (
        'id',
        'status',
        'variant',
        'type_of_evidence',
        'tier_level',
        'tier_level_criteria',
        'mutation_origin',
        'owner'
    )
    list_select_related = ('variant', 'owner',)
    list_filter = ('status', 'owner', 'type_of_evidence')
    autocomplete_fields = ['variant']


admin.site.register(SubmittedVariant)
admin.site.register(SubmittedVariantBatch)
