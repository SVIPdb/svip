SELECT transcript.stable_id, transcript.version, xref.display_label
FROM transcript, object_xref, xref, external_db
WHERE transcript.transcript_id = object_xref.ensembl_id
 AND object_xref.ensembl_object_type = 'Transcript'
 AND object_xref.xref_id = xref.xref_id
 AND xref.external_db_id = external_db.external_db_id
 AND external_db.db_name = 'RefSeq_mRNA'
AND transcript.stable_id in ();