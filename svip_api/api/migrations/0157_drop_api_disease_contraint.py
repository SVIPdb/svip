# Generated by Django 2.2.4 on 2021-02-24 01:17

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0156_auto_20211103_1642'),
    ]

    operations = [
        migrations.RunSQL(
            """
            -- Remove contraint of api_disease 
            ALTER TABLE public.icd_o_topo_api_disease DROP CONSTRAINT icd_o_topo_api_disease_api_disease_fk;
            """,
            reverse_sql="""
            -- Add constraint to api_disease
            ALTER TABLE public.icd_o_topo_api_disease ADD CONSTRAINT icd_o_topo_api_disease_api_disease_fk FOREIGN KEY (api_disease_id) REFERENCES api_disease(id);
            """)
    ]
