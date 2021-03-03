-- public.icd_o_morpho_behavior definition

-- Drop table

-- DROP TABLE public.icd_o_morpho_behavior;

CREATE TABLE public.icd_o_morpho_behavior (
	id serial NOT NULL,
	behavior_code int4 NOT NULL,
	behavior_description text NOT NULL,
	CONSTRAINT icd_o_morpho_behavior_pk PRIMARY KEY (id)
);


-- public.icd_o_morpho_level definition

-- Drop table

-- DROP TABLE public.icd_o_morpho_level;

CREATE TABLE public.icd_o_morpho_level (
	id serial NOT NULL,
	"level" text NOT NULL,
	icd_o_level bool NOT NULL,
	CONSTRAINT icd_o_morpho_level_pk PRIMARY KEY (id)
);


-- public.icd_o_morpho_version definition

-- Drop table

-- DROP TABLE public.icd_o_morpho_version;

CREATE TABLE public.icd_o_morpho_version (
	id serial NOT NULL,
	"version" text NOT NULL,
	CONSTRAINT icd_o_morpho_version_pk PRIMARY KEY (id)
);


-- public.icd_o_topo_level definition

-- Drop table

-- DROP TABLE public.icd_o_topo_level;

CREATE TABLE public.icd_o_topo_level (
	id serial NOT NULL,
	"level" text NOT NULL, -- Topography level as provided in ICD-O
	CONSTRAINT icd_o_topo_level_pk PRIMARY KEY (id)
);


-- public.icd_o_topo_version definition

-- Drop table

-- DROP TABLE public.icd_o_topo_version;

CREATE TABLE public.icd_o_topo_version (
	id serial NOT NULL,
	"version" text NOT NULL,
	CONSTRAINT icd_o_topo_version_pk PRIMARY KEY (id)
);


-- public.icd_o_morpho definition

-- Drop table

-- DROP TABLE public.icd_o_morpho;

CREATE TABLE public.icd_o_morpho (
	id serial NOT NULL,
	cell_type_code text NOT NULL,
	icd_o_morpho_behavior_id int4 NOT NULL,
	icd_o_morpho_level_id int4 NOT NULL,
	term text NOT NULL,
	code_reference text NULL,
	obs bool NOT NULL,
	additional_information text NULL,
	created_on timestamptz NULL,
	user_created bool NOT NULL,
	morpho_version int4 NULL,
	CONSTRAINT icd_o_morpho_pkey PRIMARY KEY (id),
	CONSTRAINT icd_o_morpho_behavior_fk FOREIGN KEY (icd_o_morpho_behavior_id) REFERENCES icd_o_morpho_behavior(id),
	CONSTRAINT icd_o_morpho_level_fk FOREIGN KEY (icd_o_morpho_level_id) REFERENCES icd_o_morpho_level(id),
	CONSTRAINT icd_o_morpho_version_fk FOREIGN KEY (morpho_version) REFERENCES icd_o_morpho_version(id)
);


-- public.icd_o_topo definition

-- Drop table

-- DROP TABLE public.icd_o_topo;

CREATE TABLE public.icd_o_topo (
	id serial NOT NULL,
	topo_code text NULL,
	topo_level_id int4 NULL,
	topo_term text NULL,
	topo_version int4 NULL,
	CONSTRAINT idc_o_topo_pk PRIMARY KEY (id),
	CONSTRAINT idc_o_topo_level_fk FOREIGN KEY (topo_level_id) REFERENCES icd_o_topo_level(id),
	CONSTRAINT idc_o_topo_version_fk FOREIGN KEY (topo_version) REFERENCES icd_o_topo_version(id)
);


-- public.icd_o_topo_api_disease definition

-- Drop table

-- DROP TABLE public.icd_o_topo_api_disease;

CREATE TABLE public.icd_o_topo_api_disease (
	api_disease_id int4 NOT NULL,
	icd_o_topo_id int4 NOT NULL,
	CONSTRAINT icd_o_topo_api_disease_pk PRIMARY KEY (api_disease_id, icd_o_topo_id)
);


-- public.icd_o_topo_api_disease foreign keys

ALTER TABLE public.icd_o_topo_api_disease ADD CONSTRAINT icd_o_topo_api_disease_api_disease_fk FOREIGN KEY (api_disease_id) REFERENCES api_disease(id);
ALTER TABLE public.icd_o_topo_api_disease ADD CONSTRAINT icd_o_topo_api_disease_icd_o_topo_fk FOREIGN KEY (icd_o_topo_id) REFERENCES icd_o_topo(id);


/* Data insertion */

INSERT INTO public.icd_o_morpho_version ("version") VALUES
	 ('ICD-O-3.2 update 09102020');


INSERT INTO public.icd_o_morpho_behavior (behavior_code,behavior_description) VALUES
	 (0,'Benign'),
	 (1,'Uncertain whether benign or malignant / Borderline malignancy / Low malignant potential / Uncertain malignant potential'),
	 (2,'Carcinoma in situ / Intraepithelial / Noninfiltrating / Noninvasive'),
	 (3,'Malignant, primary site'),
	 (6,'Malignant, metastatic site / Malignant, secondary site'),
	 (9,'Malignant, uncertain whether primary or metastatic site'),
	 (99,'Not applicable');


INSERT INTO public.icd_o_morpho_level ("level",icd_o_level) VALUES
	 ('1',true),
	 ('2',true),
	 ('3',true),
	 ('Preferred',true),
	 ('Synonym',true),
	 ('Related',true),
	 ('Synonym',false),
	 ('Abbreviation',false);


INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8050',1,4,'Papilloma, NOS',NULL,false,'(except of bladder M-8120/0)','2020-12-18 00:00:00+01',false,1),
	 ('8050',4,4,'Papillary carcinoma, NOS',NULL,false,'(except of thyroid M-8260/3)','2020-12-18 00:00:00+01',false,1),
	 ('8052',1,6,'Benign keratosis, NOS',NULL,false,'(see also M-8070/0)','2020-12-18 00:00:00+01',false,1),
	 ('8000',1,5,'Unclassified tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',2,4,'Neoplasm, uncertain whether benign or malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',2,5,'Tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',2,5,'Unclassified tumor, borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',2,5,'Unclassified tumor, uncertain whether benign or malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',4,4,'Neoplasm, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',4,5,'Blastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8000',4,5,'Tumor, malignant, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',4,5,'Cancer',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',4,5,'Malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',4,5,'Unclassified tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',5,4,'Neoplasm, metastatic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',5,5,'Neoplasm, secondary',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',5,5,'Tumor embolus',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',5,5,'Tumor, metastatic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',5,5,'Tumor, secondary',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',6,4,'Neoplasm, malignant, uncertain whether primary or metastatic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8000',6,5,'Unclassified tumor, malignant, uncertain whether primary or metastatic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8001',1,4,'Tumor cells, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8001',2,4,'Tumor cells, uncertain whether benign or malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8001',2,5,'Tumor cells, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8001',4,4,'Tumor cells, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8002',4,4,'Malignant tumor, small cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8003',4,4,'Malignant tumor, giant cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8004',4,4,'Malignant tumor, spindle cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8004',4,5,'Malignant tumor, fusiform cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8005',1,4,'Clear cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8005',4,4,'Malignant tumor, clear cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('801-804',7,2,'Epithelial neoplasms, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',1,4,'Epithelial tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',3,4,'Carcinoma in situ, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',3,5,'Intraepithelial carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',4,4,'Carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',4,5,'Epithelial tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',4,6,'Heterotopia-associated carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',5,4,'Carcinoma, metastatic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8010',5,5,'Secondary carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8010',6,4,'Carcinomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8011',1,4,'Epithelioma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8011',4,4,'Epithelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8011',4,5,'Epithelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8012',4,4,'Large cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8013',4,4,'Large cell neuroendocrine carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8013',4,6,'Combined large cell neuroendocrine carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8014',4,4,'Large cell carcinoma with rhabdoid phenotype',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8015',4,4,'Glassy cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8020',4,4,'Carcinoma, undifferentiated, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8020',4,6,'Carcinoma, poorly differentiated, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8020',4,6,'Anaplastic undifferentiated carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8020',4,6,'Dedifferentiated carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8021',4,4,'Carcinoma, anaplastic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8022',4,4,'Pleomorphic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8023',4,4,'Nuclear protein in testis (NUT)-associated carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8023',4,5,'NUT carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8023',4,5,'NUT midline carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8030',4,4,'Giant cell and spindle cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8031',4,4,'Giant cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8032',4,4,'Spindle cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8033',4,4,'Pseudosarcomatous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8033',4,5,'Sarcomatoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8034',4,4,'Polygonal cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8035',4,4,'Carcinoma with osteoclast-like giant cells',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8035',4,6,'Squamous carcinoma with osteoclast-like giant cells',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8035',4,6,'Undifferentiated carcinoma with osteoclast-like giant cells',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8040',1,4,'Tumorlet, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8040',1,6,'Diffuse idiopathic neuroendocrine cell hyperplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8040',2,4,'Tumorlet, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8041',4,4,'Small cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8041',4,5,'Reserve cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8041',4,5,'Round cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8041',4,6,'Small cell neuroendocrine carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8041',4,5,'Small cell carcinoma, pulmonary type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8043',4,4,'Small cell carcinoma, fusiform cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8044',4,4,'Small cell carcinoma, intermediate cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8045',4,4,'Combined small cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8045',4,5,'Mixed small cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8045',4,6,'Combined small cell-adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8045',4,6,'Combined small cell-large cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8045',4,6,'Combined small cell-squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('805-808',7,2,'Squamous cell neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8050',3,4,'Papillary carcinoma in situ, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8051',1,4,'Verrucous papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8090',4,4,'Basal cell carcinoma, NOS','(C44._)',false,'(except of prostate M-8147/3)','2020-12-18 00:00:00+01',false,1),
	 ('8051',4,4,'Verrucous carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8051',4,5,'Verrucous epidermoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8051',4,5,'Verrucous squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',1,4,'Squamous cell papilloma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8052',1,5,'Keratotic papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',1,5,'Squamous papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',1,6,'Seborrhoeic keratosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',1,6,'Solar lentigo',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',1,6,'Lichen planus-like keratosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',3,4,'Papillary squamous cell carcinoma, non-invasive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',3,5,'Papillary squamous cell carcinoma in situ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',4,4,'Papillary squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8052',4,5,'Papillary epidermoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8053',1,4,'Squamous cell papilloma, inverted',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8054',1,4,'Warty dyskeratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8054',4,4,'Warty carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8054',4,5,'Condylomatous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8054',4,6,'Warty-basaloid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8060',1,4,'Squamous papillomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8060',1,5,'Papillomatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',1,4,'Actinic keratosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',1,6,'Arsenical keratosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',1,6,'PUVA keratosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',3,4,'Squamous cell carcinoma in situ, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8070',3,5,'Epidermoid carcinoma in situ, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',3,5,'Intraepidermal carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',3,5,'Intraepithelial squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',4,4,'Squamous cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',4,5,'Squamous cell carcinoma, usual type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',4,5,'Epidermoid carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',4,5,'Squamous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',4,5,'Squamous cell epithelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8070',5,4,'Squamous cell carcinoma, metastatic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8071',3,4,'Differentiated intraepithelial neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8071',4,4,'Squamous cell carcinoma, keratinizing, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8071',4,5,'Epidermoid carcinoma, keratinizing',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8071',4,5,'Squamous cell carcinoma, large cell, keratinizing',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8071',4,6,'Keratoacanthoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8072',1,4,'Large cell acanthoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8072',4,4,'Squamous cell carcinoma, large cell, nonkeratinizing, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8072',4,5,'Epidermoid carcinoma, large cell, nonkeratinizing',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8072',4,5,'Squamous cell carcinoma, nonkeratinizing, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',1,4,'Adenoma, NOS',NULL,false,'(except of pituitary M-8272/0 or nipple M-8506/0 or rete ovarii M-9110/0)','2020-12-18 00:00:00+01',false,1),
	 ('8140',4,4,'Adenocarcinoma, NOS',NULL,false,'(except of anal glands/ducts M-8215/3 or rete ovarii M-9110/3)','2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8073',4,4,'Squamous cell carcinoma, small cell, nonkeratinizing',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8073',4,5,'Epidermoid carcinoma, small cell, nonkeratinizing',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8074',4,4,'Squamous cell carcinoma, spindle cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8074',4,5,'Epidermoid carcinoma, spindle cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8074',4,5,'Squamous cell carcinoma, sarcomatoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8074',4,6,'Pseudovascular squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8075',4,4,'Squamous cell carcinoma, adenoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8075',4,5,'Squamous cell carcinoma, acantholytic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8075',4,5,'Squamous cell carcinoma, pseudoglandular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8076',3,4,'Squamous cell carcinoma in situ with questionable stromal invasion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8076',3,5,'Epidermoid carcinoma in situ with questionable stromal invasion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8076',4,4,'Squamous cell carcinoma, microinvasive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',1,4,'Squamous intraepithelial neoplasia, low grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',1,5,'Squamous intraepithelial neoplasia, grade I',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',1,5,'Low grade squamous intraepithelial lesion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,4,'Squamous intraepithelial neoplasia, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'Squamous intraepithelial neoplasia, grade II',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'Squamous intraepithelial neoplasia, grade III',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'Squamous dysplasia, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'High grade squamous intraepithelial lesion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8078',4,4,'Squamous cell carcinoma with horn formation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8082',4,4,'Lymphoepithelial carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8082',4,5,'Lymphoepithelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8082',4,5,'Lymphoepithelioma-like carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8083',4,4,'Basaloid squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8083',4,6,'Papillary-basaloid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8084',1,4,'Clear cell acanthoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8084',4,4,'Squamous cell carcinoma, clear cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8085',4,4,'Squamous cell carcinoma, HPV positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8086',4,4,'Squamous cell carcinoma, HPV negative',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('809-811',7,2,'Basal cell neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8093',4,5,'Fibroepithelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8093',4,5,'Fibroepithelioma of Pinkus type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8093',4,5,'Fibroepithelial basal cell carcinoma, Pinkus type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8093',4,5,'Pinkus tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('812-813',7,2,'Transitional cell papillomas and carcinomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',1,4,'Urothelial papilloma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',1,5,'Transitional cell papilloma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',1,5,'Transitional papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',1,5,'Transitional cell papilloma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8120',3,4,'Urothelial carcinoma in situ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',3,5,'Transitional cell carcinoma in situ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',4,4,'Transitional cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',4,5,'Urothelial carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',4,6,'Transitional carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',4,6,'Squamotransitional carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',1,6,'Urothelial papilloma, inverted',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',1,6,'Transitional papilloma, inverted, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',1,5,'Transitional cell papilloma, inverted, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',2,6,'Columnar cell papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8122',4,4,'Urothelial carcinoma, sarcomatoid ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8122',4,5,'Urothelial carcinoma, spindle cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8122',4,5,'Transitional cell carcinoma, spindle cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8122',4,5,'Transitional cell carcinoma, sarcomatoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8123',4,4,'Basaloid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('814-838',7,2,'Adenomas and adenocarcinomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',2,4,'Atypical adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',3,4,'Adenocarcinoma in situ, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',4,5,'Adenocarcinoma, usual type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',4,6,'Carcinoma of Skene, Cowper and Littre glands',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8140',4,6,'Endolymphatic sac tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',5,4,'Adenocarcinoma, metastatic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8141',4,4,'Scirrhous adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8141',4,5,'Carcinoma with productive fibrosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8141',4,5,'Scirrhous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8143',4,4,'Superficial spreading adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8144',1,4,'Adenoma, intestinal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8144',4,5,'Adenocarcinoma, enteric',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8144',4,5,'Mucinous carcinoma, intestinal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8146',1,4,'Monomorphic adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8147',1,4,'Basal cell adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8147',4,4,'Basal cell adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',1,4,'Glandular intraepithelial neoplasia, low grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',1,5,'Glandular intraepithelial neoplasia, grade I',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',1,5,'Glandular intraepithelial neoplasia, grade II',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',1,6,'Biliary intraepithelial neoplasia, low grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,4,'Glandular intraepithelial neoplasia, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,5,'Glandular intraepithelial neoplasia, grade III',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,5,'Flat intraepithelial neoplasia, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,6,'Biliary intraepithelial neoplasia, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8148',3,5,'Biliary intraepithelial neoplasia, grade 3 (BilIN-3)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8149',1,4,'Canalicular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,4,'Glucagonoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,5,'Alpha cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,6,'Enteroglucagonoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,6,'Glucagon-like peptide-producing tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,6,'L-cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,5,'PP/PYY producing tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8153',4,4,'Gastrinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8153',4,5,'G cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8153',4,5,'Gastrin cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,4,'Mixed neuroendocrine non-neuroendocrine neoplasm (MiNEN)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8155',4,4,'Vipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8156',4,4,'Somatostatinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8156',4,5,'Somatostatin cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8158',4,4,'ACTH-producing tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8158',4,6,'Endocrine tumor, functioning, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',1,4,'Pancreatobiliary neoplasm, non-invasive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',1,5,'Non-invasive pancreatobiliary papillary neoplasm with low grade dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',1,5,'Non-invasive pancreatobiliary papillary neoplasm with low grade intraepithelial neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8190',1,4,'Trabecular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8190',4,4,'Trabecular adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8190',4,5,'Trabecular carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8191',1,4,'Embryonal adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',4,4,'Adenoid cystic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',4,5,'Adenocarcinoma, cylindroid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',4,5,'Adenocystic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8201',4,4,'Cribriform carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8202',1,4,'Microcystic adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',1,4,'Adenomatous polyp, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8210',1,5,'Polypoid adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',3,4,'Adenocarcinoma in situ in adenomatous polyp',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',3,5,'Adenocarcinoma in situ in polyp, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',3,5,'Carcinoma in situ in polyp, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',3,5,'Adenocarcinoma in situ in polypoid adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',3,5,'Adenocarcinoma in situ in tubular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',3,5,'Carcinoma in situ in adenomatous polyp',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',4,4,'Adenocarcinoma in adenomatous polyp',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',4,5,'Adenocarcinoma in polyp, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',4,5,'Carcinoma in polyp, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8210',4,5,'Adenocarcinoma in polypoid adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',4,5,'Adenocarcinoma in tubular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8210',4,5,'Carcinoma in adenomatous polyp',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8211',1,4,'Tubular adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8211',4,4,'Tubular adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8211',4,5,'Tubular carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8212',1,4,'Flat adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8213',1,5,'Traditional serrated adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8213',1,6,'Sessile serrated adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8213',1,6,'Sessile serrated polyp',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8213',1,6,'Traditional sessile serrated adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8213',4,4,'Serrated adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8220',1,5,'Adenomatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8260',1,4,'Papillary adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8221',1,4,'Multiple adenomatous polyps',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8221',4,4,'Adenocarcinoma in multiple adenomatous polyps',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8230',3,5,'Intraductal carcinoma, solid type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8230',4,4,'Solid carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8230',4,5,'Solid adenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8230',4,6,'Solid carcinoma with mucin formation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8230',4,5,'Solid adenocarcinoma with mucin formation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8231',4,4,'Carcinoma simplex',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,4,'Neuroendocrine tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',4,5,'Cylindroma, NOS',NULL,false,'(except of skin or breast M-8200/0)','2020-12-18 00:00:00+01',false,1),
	 ('8240',4,5,'Carcinoid tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,5,'Neuroendocrine carcinoma, low grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,5,'Neuroendocrine carcinoma, well differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,6,'Neuroendocrine tumor, grade 1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,5,'Typical carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8241',4,4,'Enterochromaffin cell carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8241',4,5,'Argentaffinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8241',4,5,'Carcinoid tumor, argentaffin',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8241',4,5,'EC cell carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8241',4,5,'Serotonin producing carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8241',4,5,'Serotonin producing tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8242',4,4,'Enterochromaffin-like cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8242',4,5,'ECL cell carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8243',4,4,'Goblet cell carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8243',4,5,'Mucinous carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8243',4,5,'Mucocarcinoid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8244',4,4,'Mixed adenoneuroendocrine carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8244',4,5,'Combined carcinoid and adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8244',4,5,'Mixed carcinoid and adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8244',4,5,'Composite carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8244',4,5,'MANEC',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8244',4,5,'Mixed carcinoid-adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8245',2,4,'Tubular carcinoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8245',4,4,'Adenocarcinoid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8246',4,4,'Neuroendocrine carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8246',4,5,'Poorly differentiated neuroendocrine neoplasm',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8248',2,4,'Apudoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8249',4,4,'Neuroendocrine tumor, grade 2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8249',4,5,'Atypical carcinoid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8249',4,6,'Neuroendocrine carcinoma, moderately differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8249',4,6,'Neuroendocrine tumor, grade 3',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',1,4,'Atypical adenomatous hyperplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8251',4,5,'Alveolar carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8255',4,4,'Adenocarcinoma with mixed subtypes',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8255',4,5,'Adenocarcinoma combined with other types of carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8260',1,6,'Glandular papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8260',2,4,'Aggressive papillary tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8260',4,4,'Papillary adenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8261',1,4,'Villous adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8261',1,6,'Villous papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8261',3,4,'Adenocarcinoma in situ in villous adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8261',4,4,'Adenocarcinoma in villous adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8262',4,4,'Villous adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',1,4,'Tubulovillous adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',1,5,'Villoglandular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',1,6,'Papillotubular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8263',1,5,'Tubulo-papillary adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',3,4,'Adenocarcinoma in situ in tubulovillous adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',4,4,'Adenocarcinoma in tubulovillous adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',4,6,'Villoglandular carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',4,6,'Villoglandular variant of endometrioid adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',4,6,'Papillotubular adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8263',4,5,'Tubulopapillary adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8264',1,4,'Papillomatosis, glandular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Pituitary adenoma, ectopic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',1,4,'Oxyphilic adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8290',1,5,'Oncocytic adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',1,5,'Oncocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',1,6,'Oncocytic papillary cystadenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',4,4,'Oxyphilic adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',4,5,'Oncocytic adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',4,5,'Oncocytic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,5,'Duct cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8310',1,4,'Clear cell adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8310',4,4,'Clear cell adenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8310',4,5,'Clear cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8310',4,6,'Clear cell adenocarcinoma, mesonephroid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8310',4,6,'Clear cell renal cell carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8311',2,4,'Hypernephroid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8315',4,4,'Glycogen-rich carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8316',2,4,'Multilocular cystic renal neoplasm of low malignant potential ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8317',4,6,'Hybrid oncocytic chromophobe tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8320',4,4,'Granular cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8320',4,5,'Granular cell adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8323',1,4,'Mixed cell adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,5,'Carcinoid, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8323',4,4,'Mixed cell adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8324',1,4,'Lipoadenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8324',1,5,'Adenolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8333',4,4,'Fetal adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8813',1,6,'Fascial fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8360',2,4,'Multiple endocrine adenomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8360',2,5,'Endocrine adenomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',1,4,'Endometrioid adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',1,5,'Endometrioid cystadenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',2,4,'Endometrioid adenoma, borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8380',2,5,'Endometrioid tumor, borderline',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',2,5,'Atypical proliferative endometrioid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',2,5,'Endometrioid cystadenoma, borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',2,5,'Endometrioid tumor of low malignant potential',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',4,4,'Endometrioid adenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',4,5,'Endometrioid carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',4,6,'Endometrioid cystadenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8381',1,4,'Endometrioid adenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8381',1,5,'Endometrioid cystadenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8381',2,4,'Endometrioid adenofibroma, borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8381',2,5,'Endometrioid cystadenofibroma, borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8381',4,4,'Endometrioid adenofibroma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8381',4,5,'Endometrioid cystadenofibroma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8382',4,4,'Endometrioid adenocarcinoma, secretory variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8383',4,4,'Endometrioid adenocarcinoma, ciliated cell variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8384',4,4,'Adenocarcinoma, endocervical type, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8894',1,5,'Vascular leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('839-842',7,2,'Adnexal and skin appendage neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8401',1,4,'Apocrine adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8401',1,5,'Apocrine cystadenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8401',4,4,'Apocrine adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8401',4,5,'Apocrine carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8405',1,4,'Papillary hidradenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8405',1,5,'Hidradenoma papilliferum',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8406',1,6,'Sialadenoma papilliferum',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8406',4,4,'Syringocystadenocarcinoma papilliferum',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8409',1,6,'Eccrine poroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8409',1,6,'Apocrine poroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8409',3,4,'Porocarcinoma in situ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('843',7,2,'Mucoepidermoid neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8430',2,4,'Mucoepidermoid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8430',4,4,'Mucoepidermoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('844-849',7,2,'Cystic, mucinous and serous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8440',1,4,'Cystadenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8440',1,5,'Cystoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8440',4,4,'Cystadenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',1,4,'Serous cystadenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',1,5,'Serous cystoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',1,6,'Serous microcystic adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',3,4,'Serous intraepithelial carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8441',4,4,'Serous carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',4,5,'Serous cystadenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8450',1,6,'Papillary cystadenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8450',4,5,'Papillocystic adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8452',4,6,'Solid pseudopapillary carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8474',1,4,'Seromucinous cystadenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8474',2,4,'Seromucinous borderline tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8474',2,5,'Seromucinous tumor, atypical proliferative',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',1,4,'Mucinous adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',1,6,'Mucous gland adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8480',4,5,'Acinar adenocarcinoma, mucinous variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Colloid adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Colloid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Gelatinous adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Gelatinous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Mucinous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Mucoid adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Mucoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Mucous adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,5,'Mucous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8480',5,4,'Pseudomyxoma peritonei',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8481',4,4,'Mucin-producing adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8481',4,5,'Mucin-producing carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8481',4,5,'Mucin-secreting adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8481',4,5,'Mucin-secreting carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',4,4,'Signet ring cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',4,5,'Signet ring cell adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',4,5,'Acinar adenocarcinoma, signet ring-like variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',4,5,'Mucinous carcinoma, signet ring cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',4,6,'Poorly cohesive carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8490',4,6,'Signet ring cell/histiocytoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',5,4,'Metastatic signet ring cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8490',5,6,'Krukenberg tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('850-854',7,2,'Ductal and lobular neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,4,'Intraductal carcinoma, noninfiltrating, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,5,'Intraductal adenocarcinoma, noninfiltrating, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,5,'Intraductal carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,5,'Duct adenocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,5,'Duct carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,5,'Ductal carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8500',4,6,'Adenocarcinoma of mammary gland type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,6,'Adenocarcinoma of anogenital mammary-like glands',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8501',4,4,'Comedocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8502',4,4,'Secretory carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,4,'Intraductal papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,5,'Ductal papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,6,'Intraductal papillary neoplasm, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,6,'Intraductal tubular-papillary neoplasm, low grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,6,'Intraductal papillary neoplasm with high grade intraepithelial neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Intraductal papillary neoplasm with high grade dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8503',3,5,'Intraductal papillary tumor with high grade dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Intraductal papillary tumor with high grade intraepithelial neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,6,'Intraductal tubular-papillary neoplasm, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,6,'Intraductal tubulopapillary neoplasm',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',4,5,'Infiltrating papillary adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',4,5,'Infiltrating and papillary adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',4,6,'Intraductal papillary neoplasm with associated invasive carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',1,4,'Intracystic papillary adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',1,5,'Intracystic papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',3,5,'Noninfiltrating intracystic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8504',3,5,'Encysted papillary carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',3,5,'Intracystic papillary carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',3,5,'Intracystic carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',3,5,'Intracystic papillary adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',4,5,'Encysted papillary carcinoma with invasion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',4,5,'Intracystic papillary carcinoma with invasion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8505',1,4,'Intraductal papillomatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8505',1,5,'Diffuse intraductal papillomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8510',4,4,'Medullary carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8510',4,6,'Medullary adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8510',4,6,'Medullary-like carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8512',4,4,'Medullary carcinoma with lymphoid stroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8514',4,4,'Duct carcinoma, desmoplastic type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',4,6,'Tubulolobular carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8521',4,4,'Infiltrating ductular carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8525',4,4,'Polymorphous adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8525',4,5,'Polymorphous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8525',4,5,'Terminal duct adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('855',7,2,'Acinar cell neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',1,4,'Acinar cell adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8550',1,5,'Acinar adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',1,5,'Acinic cell adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',2,4,'Acinar cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',2,5,'Acinic cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',4,4,'Acinar cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',4,5,'Acinar carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8550',4,5,'Acinic cell adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8551',4,4,'Acinar cell cystadenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8552',4,4,'Mixed acinar-ductal carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('856-857',7,2,'Complex epithelial neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8560',1,4,'Mixed squamous cell and glandular papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8560',1,5,'Tubulosquamous polyp',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8560',4,4,'Adenosquamous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8560',4,5,'Mixed adenocarcinoma and epidermoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8560',4,5,'Mixed adenocarcinoma and squamous cell carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8562',4,4,'Epithelial-myoepithelial carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8563',1,4,'Lymphadenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8570',4,4,'Adenocarcinoma with squamous metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8570',4,5,'Adenoacanthoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8570',4,6,'Endometrioid carcinoma with squamous differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8571',4,4,'Adenocarcinoma with cartilaginous and osseous metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8571',4,5,'Adenocarcinoma with cartilaginous metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8571',4,5,'Adenocarcinoma with chondroid differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8571',4,5,'Adenocarcinoma with osseous metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8572',4,4,'Adenocarcinoma with spindle cell metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8572',4,5,'Acinar adenocarcinoma, sarcomatoid variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8572',4,6,'Fibromatosis-like metaplastic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8573',4,4,'Adenocarcinoma with apocrine metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8573',4,5,'Carcinoma with apocrine metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8574',4,4,'Adenocarcinoma with neuroendocrine differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8574',4,5,'Carcinoma with neuroendocrine differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8574',4,5,'Adenocarcinoma admixed with neuroendocrine carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8575',4,4,'Metaplastic carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8576',4,4,'Hepatoid adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8576',4,5,'Hepatoid carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('858',7,2,'Thymic epithelial neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8587',1,4,'Ectopic hamartomatous thymoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8588',4,4,'Spindle epithelial tumor with thymus-like element',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8588',4,5,'Spindle epithelial tumor with thymus-like differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8589',4,5,'Carcinoma showing thymus-like element',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8589',4,5,'Carcinoma showing thymus-like differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8589',4,5,'CASTLE',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('859-867',7,2,'Specialized gonadal neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',1,4,'Sex cord-stromal tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',1,6,'Signet-ring stromal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',1,6,'Microcystic stromal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',2,4,'Sex cord-gonadal stromal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',2,5,'Gonadal stromal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',2,5,'Sex cord tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',2,5,'Sex cord-stromal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8590',2,6,'Uterine tumor resembling ovarian sex cord tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8591',2,4,'Sex cord-gonadal stromal tumor, incompletely differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8591',2,6,'Sex cord-stromal tumor, unclassified',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8592',2,4,'Sex cord-gonadal stromal tumor, mixed forms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8592',2,5,'Sex cord-gonadal stromal tumor, mixed',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8594',2,4,'Mixed germ cell-sex cord-stromal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8594',2,6,'Mixed germ cell-sex cord-stromal tumor, unclassified',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8630',1,4,'Androblastoma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8630',1,5,'Arrhenoblastoma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8630',2,4,'Androblastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8630',2,5,'Arrhenoblastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8630',4,4,'Androblastoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8630',4,5,'Arrhenoblastoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8631',1,4,'Sertoli-Leydig cell tumor, well differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8631',2,4,'Sertoli-Leydig cell tumor of intermediate differentiation, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8631',2,5,'Sertoli-Leydig cell tumor, moderately differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8631',2,6,'Sertoli-Leydig cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8631',4,4,'Sertoli-Leydig cell tumor, poorly differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8631',4,6,'Sertoli-Leydig cell tumor, sarcomatoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8633',2,4,'Sertoli-Leydig cell tumor, retiform',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8634',2,4,'Sertoli-Leydig cell tumor, intermediate differentiation, with heterologous elements',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8634',2,5,'Sertoli-Leydig cell tumor, moderately differentiated, with heterologous elements',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8634',2,6,'Sertoli-Leydig cell tumor, retiform, with heterologous elements',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8634',4,4,'Sertoli-Leydig cell tumor, poorly differentiated, with heterologous elements',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8640',2,4,'Sertoli cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8640',2,5,'Tubular androblastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8640',2,5,'Pick tubular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8640',2,5,'Sertoli cell adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8640',2,5,'Testicular adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8641',1,4,'Sertoli cell tumor with lipid storage',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8642',2,4,'Large cell calcifying Sertoli cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8643',2,4,'Intratubular large cell hyalinizing Sertoli cell neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8650',2,5,'Interstitial cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8650',4,5,'Interstitial cell tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8670',1,5,'Steroid cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8670',4,4,'Steroid cell tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8671',1,4,'Adrenal rest tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('868-871',7,2,'Paragangliomas and glomus tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8681',4,4,'Sympathetic paraganglioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8682',4,4,'Parasympathetic paraganglioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8693',4,4,'Extra-adrenal paraganglioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8693',4,6,'Nonchromaffin paraganglioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8693',4,6,'Laryngeal paraganglioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8693',4,6,'Vagal paraganglioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8693',4,6,'Composite paraganglioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8700',4,5,'Chromaffin paraganglioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8700',4,5,'Chromaffin tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8700',4,5,'Chromaffinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8710',4,4,'Glomangiosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8710',4,5,'Glomoid sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8711',1,4,'Glomus tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8711',2,4,'Glomangiomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8711',2,6,'Glomus tumor of uncertain malignant potential',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8711',4,4,'Glomus tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8712',1,4,'Glomangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8713',1,4,'Glomangiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8714',1,4,'Perivascular epithelioid tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8714',1,5,'PEComa, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8714',4,4,'Perivascular epithelioid tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8714',4,5,'PEComa, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('872-879',7,2,'Nevi and melanomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,6,'Genital nevus',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',3,4,'Melanoma in situ',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',4,5,'Melanoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8746',4,4,'Mucosal lentiginous melanoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8750',1,5,'Stromal nevus',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',4,6,'Mixed epithelioid and spindle cell melanoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8771',4,4,'Epithelioid cell melanoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8772',4,4,'Spindle cell melanoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('880',7,2,'Soft tissue tumors and sarcomas, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8800',1,4,'Soft tissue tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8800',4,4,'Sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8800',4,5,'Mesenchymal tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8800',4,5,'Soft tissue sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8800',4,5,'Soft tissue tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8800',6,4,'Sarcomatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8801',4,4,'Spindle cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8801',4,5,'Spindle cell sarcoma, undifferentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8802',2,4,'Pleomorphic hyalinizing angiectatic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8802',4,5,'Pleomorphic cell sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8802',4,5,'Pleomorphic cell sarcoma, undifferentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8802',4,5,'Pleomorphic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8803',4,4,'Small cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8803',4,5,'Round cell sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8803',4,5,'Round cell sarcoma, undifferentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8804',4,4,'Epithelioid sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8804',4,5,'Epithelioid cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8804',4,6,'Epithelioid sarcoma, undifferentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8805',4,4,'Undifferentiated sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8806',4,4,'Desmoplastic small round cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('881-883',7,2,'Fibromatous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',1,6,'Desmoplastic fibroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',1,6,'Gardner fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',1,6,'Nuchal fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',1,6,'Collagenous fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',4,4,'Fibrosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',1,4,'Fibromyxoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',1,5,'Myxofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',1,5,'Myxoid fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',1,6,'Plexiform fibromyxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8811',1,6,'Acral fibromyxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',2,4,'Myxoinflammatory fibroblastic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',2,6,'Atypical myxoinflammatory fibroblastic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',2,6,'Hemosiderotic fibrolipomatous tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',4,4,'Myxofibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8811',4,6,'Fibromyxosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8813',1,4,'Fibroma of tendon sheath',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8813',2,4,'Palmar/plantar type fibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8813',2,5,'Superficial fibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8813',4,4,'Fascial fibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8814',4,4,'Infantile fibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8814',4,5,'Congenital fibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',1,4,'Solitary fibrous tumor/Hemangiopericytoma, grade 1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',1,5,'Hemangiopericytoma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',2,4,'Solitary fibrous tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',2,5,'Hemangiopericytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',2,5,'Localized fibrous tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',2,6,'Solitary fibrous tumor/Hemangiopericytoma, grade 2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',4,4,'Solitary fibrous tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',4,6,'Solitary fibrous tumor/Hemangiopericytoma, grade 3',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8815',4,5,'Hemangiopericytoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8816',1,4,'Calcifying aponeurotic fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8817',1,4,'Calcifying fibrous tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8818',1,4,'Fibrous dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8820',1,4,'Elastofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8821',2,4,'Aggressive fibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8821',2,5,'Desmoid type fibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8821',2,5,'Desmoid, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8821',2,5,'Desmoid tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8821',2,5,'Extra-abdominal desmoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8821',2,5,'Invasive fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8822',2,4,'Abdominal fibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8822',2,5,'Abdominal desmoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8823',1,4,'Sclerotic fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8823',2,4,'Desmoplastic fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8824',1,4,'Myofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8824',1,6,'Dermatomyofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8824',1,6,'Myopericytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8824',2,4,'Myofibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8824',2,6,'Congenital generalized fibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8824',2,5,'Infantile myofibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8825',1,4,'Myofibroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8825',2,4,'Myofibroblastic tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8825',2,5,'Inflammatory myofibroblastic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8825',4,4,'Myofibroblastic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8826',1,4,'Angiomyofibroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8828',1,4,'Nodular fasciitis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8828',1,6,'Proliferative fasciitis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8828',1,6,'Proliferative myositis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',1,4,'Benign fibrous histiocytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8830',1,5,'Fibroxanthoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',1,5,'Xanthofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',1,6,'Epithelioid fibrous histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',2,4,'Atypical fibrous histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',2,5,'Atypical fibroxanthoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',4,4,'Malignant fibrous histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',4,5,'Fibroxanthoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8831',1,4,'Histiocytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8831',1,6,'Deep histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8831',1,5,'Deep benign fibrous histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8831',1,6,'Juvenile histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8831',1,6,'Reticulohistiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8831',1,5,'Reticulohistocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8834',2,4,'Giant cell fibroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8835',2,4,'Plexiform fibrohistiocytic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8836',2,4,'Angiomatoid fibrous histiocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('884',7,2,'Myxomatous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8840',1,4,'Myxoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8840',4,4,'Myxosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8840',4,6,'Low grade fibromyxoid sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8840',4,6,'Sclerosing epithelioid fibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8841',1,4,'Angiomyxoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8841',1,6,'Aggressive angiomyxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8841',1,6,'Superficial angiomyxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8842',1,4,'Ossifying fibromyxoid tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8842',4,4,'Ossifying fibromyxoid tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('885-888',7,2,'Lipomatous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8850',1,4,'Lipoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8850',2,4,'Atypical lipomatous tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8850',2,5,'Atypical lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8850',2,5,'Liposarcoma, well differentiated, superficial',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8850',4,4,'Liposarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8850',4,5,'Fibroliposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',1,4,'Fibrolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',2,4,'Lipofibromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',4,4,'Liposarcoma, well differentiated, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',4,5,'Lipoma-like liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',4,5,'Liposarcoma, differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',4,6,'Inflammatory liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8851',4,6,'Sclerosing liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8852',1,4,'Fibromyxolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8852',1,5,'Myxolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8852',4,4,'Myxoid liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8852',4,5,'Myxoliposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8854',1,4,'Pleomorphic lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8854',4,4,'Pleomorphic liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8855',4,4,'Mixed liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8856',1,4,'Intramuscular lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8856',1,6,'Infiltrating angiolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8856',1,6,'Infiltrating lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8857',1,4,'Spindle cell lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8857',4,4,'Fibroblastic liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8858',4,4,'Dedifferentiated liposarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8860',1,4,'Angiomyolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8860',2,4,'Angiomyolipoma, epithelioid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8861',1,4,'Angiolipoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8862',1,4,'Chondroid lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8870',1,4,'Myelolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8880',1,4,'Hibernoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8880',1,5,'Brown fat tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8880',1,5,'Fetal fat cell lipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8881',1,4,'Lipoblastomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8881',1,5,'Fetal lipoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8881',1,5,'Fetal lipomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8881',1,5,'Lipoblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('889-892',7,2,'Myomatous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,4,'Leiomyoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,5,'Fibromyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,5,'Leiomyofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,6,'Lipoleiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8890',1,5,'Lipomatous leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,6,'Plexiform leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,6,'Leiomyoma, apoplectic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,6,'Leiomyoma, hydropic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,6,'Myolipoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,6,'Cotyledonoid leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,5,'Dissecting leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',2,4,'Leiomyomatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',2,6,'Leiomyomatosis, peritonealis disseminata',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',2,6,'Intravascular leiomyomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8890',2,5,'Intravenous leiomyomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',4,4,'Leiomyosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8891',1,4,'Epithelioid leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8891',1,5,'Leiomyoblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8891',4,4,'Epithelioid leiomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8892',1,4,'Cellular leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8893',1,4,'Bizarre leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8893',1,5,'Atypical leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8893',1,5,'Pleomorphic leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8893',1,5,'Symplastic leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8894',1,4,'Angioleiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8894',1,5,'Angiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8894',4,4,'Angiomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8895',1,4,'Myoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8895',4,4,'Myosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8896',1,4,'Myxoid leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8896',4,4,'Myxoid leiomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8897',2,4,'Smooth muscle tumor of uncertain malignant potential',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8897',2,5,'Smooth muscle tumor, atypical',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8897',2,6,'Smooth muscle tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8898',2,4,'Metastasizing leiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8900',1,4,'Rhabdomyoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8900',4,4,'Rhabdomyosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8900',4,5,'Rhabdosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8901',4,4,'Pleomorphic rhabdomyosarcoma, adult type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8901',4,6,'Pleomorphic rhabdomyosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8901',4,5,'Rhabdomyosarcoma, pleomorphic type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8902',4,4,'Mixed type rhabdomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8902',4,6,'Mixed embryonal rhabdomyosarcoma and alveolar rhabdomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8903',1,4,'Fetal rhabdomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8904',1,4,'Adult cellular rhabdomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8904',1,5,'Adult rhabdomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8904',1,6,'Glycogenic rhabdomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8910',4,4,'Embryonal rhabdomyosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8910',4,5,'Rhabdomyosarcoma, embryonal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8910',4,6,'Embryonal rhabdomyosarcoma, pleomorphic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8910',4,6,'Sarcoma botryoides',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8910',4,5,'Botryoid sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8912',4,4,'Spindle cell rhabdomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8912',4,5,'Sclerosing rhabdomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8912',4,5,'Rhabdomyosarcoma, spindle cell/sclerosing type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8920',4,4,'Alveolar rhabdomyosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8921',4,4,'Ectomesenchymoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8921',4,5,'Rhabdomyosarcoma with ganglionic differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('893-899',7,2,'Complex mixed and stromal neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8930',4,5,'Endometrioid stromal sarcoma, high grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8931',4,5,'Endometrioid stromal sarcoma, low grade',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8932',1,4,'Adenomyoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8932',1,6,'Atypical polypoid adenomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8933',4,4,'Adenosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8934',4,4,'Carcinofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8935',1,4,'Stromal tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8935',2,4,'Stromal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8935',2,6,'Stromal tumor of uncertain malignant potential',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,4,'Mucinous adenocarcinoma',NULL,false,'(except of lung M-8253/3)','2020-12-18 00:00:00+01',false,1),
	 ('8935',4,4,'Stromal sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8936',4,4,'Gastrointestinal stromal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8936',4,5,'GIST',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8936',4,5,'Gastrointestinal stromal sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8936',4,6,'Gastrointestinal autonomic nerve tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8936',4,5,'GANT',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8936',4,6,'Gastrointestinal pacemaker cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',1,4,'Pleomorphic adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',1,5,'Mixed tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',4,4,'Mixed tumor, malignant, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8951',4,4,'Mesodermal mixed tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9073',2,4,'Gonadoblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8960',2,4,'Mesoblastic nephroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8963',4,4,'Rhabdoid tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8963',4,5,'Malignant rhabdoid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8963',4,5,'Rhabdoid sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8973',4,4,'Pleuropulmonary blastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8974',2,4,'Sialoblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8980',4,4,'Carcinosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8981',4,4,'Carcinosarcoma, embryonal',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8982',1,4,'Myoepithelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8982',1,5,'Myoepithelial adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8982',1,5,'Myoepithelial tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8982',1,5,'Ectomesenchymal chondromyxoid tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8982',4,4,'Myoepithelial carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8982',4,5,'Malignant myoepithelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8982',4,5,'Myoepithelioma, infiltrating',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',1,4,'Mesenchymoma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',1,6,'Phosphaturic mesenchymal tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',1,5,'Phosphaturic mesenchymal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',2,4,'Mesenchymoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',2,5,'Mixed mesenchymal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',2,6,'Primitive non-neural granular cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',4,4,'Mesenchymoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8990',4,5,'Mixed mesenchymal sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8990',4,6,'Phosphaturic mesenchymal tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8991',4,4,'Embryonal sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('900-903',7,2,'Fibroepithelial neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9013',1,4,'Adenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9013',1,6,'Cystadenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9013',1,6,'Papillary adenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',1,4,'Serous adenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',1,6,'Serous cystadenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',1,6,'Seromucinous adenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',2,4,'Serous adenofibroma of borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9014',2,6,'Serous cystadenofibroma of borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',4,4,'Serous adenocarcinofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',4,5,'Malignant serous adenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',4,6,'Serous cystadenocarcinofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9014',4,5,'Malignant serous cystadenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',1,4,'Mucinous adenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',1,6,'Mucinous cystadenofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',2,4,'Mucinous adenofibroma of borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',2,6,'Mucinous cystadenofibroma of borderline malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',4,4,'Mucinous adenocarcinofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9015',4,5,'Malignant mucinous adenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',4,6,'Mucinous cystadenocarcinofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9015',4,5,'Malignant mucinous cystadenofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('904',7,2,'Synovial-like neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9040',1,4,'Synovioma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9040',4,4,'Synovial sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9040',4,5,'Synovioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9040',4,5,'Synovioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9041',4,4,'Synovial sarcoma, spindle cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9041',4,5,'Synovial sarcoma, monophasic fibrous',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9042',4,4,'Synovial sarcoma, epithelioid cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9043',4,4,'Synovial sarcoma, biphasic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('905',7,2,'Mesothelial neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9050',1,4,'Mesothelioma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9050',4,4,'Mesothelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9050',4,5,'Mesothelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9051',1,4,'Fibrous mesothelioma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9051',4,4,'Fibrous mesothelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9051',4,5,'Fibrous mesothelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9051',4,5,'Desmoplastic mesothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9051',4,5,'Sarcomatoid mesothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8504',3,4,'Encapsulated papillary carcinoma',NULL,false,'(except of thyroid M-8343/3)','2020-12-18 00:00:00+01',false,1),
	 ('8504',4,4,'Encapsulated papillary carcinoma with invasion',NULL,false,'(except of thyroid M-8343/3)','2020-12-18 00:00:00+01',false,1),
	 ('9051',4,5,'Spindled mesothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9052',1,4,'Epithelioid mesothelioma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9052',1,5,'Mesothelial papilloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9052',4,4,'Epithelioid mesothelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9052',4,5,'Epithelioid mesothelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9053',4,4,'Mesothelioma, biphasic, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9053',4,5,'Mesothelioma, biphasic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9054',1,4,'Adenomatoid tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('906-909',7,2,'Germ cell neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9060',4,4,'Dysgerminoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9064',4,4,'Germinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9064',4,5,'Germ cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9070',4,4,'Embryonal carcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9070',4,5,'Embryonal adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,4,'Yolk sac tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,5,'Embryonal carcinoma, infantile',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,5,'Yolk sac tumor, pre-pubertal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9071',4,5,'Endodermal sinus tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,5,'Polyvesicular vitelline tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,6,'Hepatoid yolk sac tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,6,'Yolk sac tumor, post-pubertal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9072',4,4,'Polyembryoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9072',4,5,'Embryonal carcinoma, polyembryonal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9073',2,5,'Gonocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',1,4,'Teratoma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',1,5,'Adult teratoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',1,5,'Cystic teratoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9080',1,5,'Adult cystic teratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',1,5,'Mature teratoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',1,5,'Teratoma, differentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',2,4,'Teratoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',2,5,'Solid teratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',2,6,'Germ cell tumor, regressed',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',4,4,'Teratoma, malignant, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',4,5,'Embryonal teratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',4,5,'Teratoblastoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',4,6,'Immature teratoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9081',4,4,'Teratocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9081',4,5,'Mixed embryonal carcinoma and teratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9081',4,6,'Teratocarcinosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9082',4,4,'Malignant teratoma, undifferentiated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9082',4,5,'Malignant teratoma, anaplastic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9083',4,4,'Malignant teratoma, intermediate',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',1,4,'Dermoid cyst, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',1,5,'Dermoid, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',4,4,'Teratoma with malignant transformation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',4,5,'Teratoma with somatic type malignancies',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9084',4,5,'Dermoid cyst with secondary tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9085',4,4,'Mixed germ cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9085',4,6,'Mixed teratoma and seminoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9086',4,4,'Germ cell tumor with associated hematological malignancy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('910',7,2,'Trophoblastic neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',4,4,'Choriocarcinoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',4,5,'Chorioepithelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',4,5,'Chorionepithelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9101',4,4,'Choriocarcinoma combined with other germ cell elements',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9101',4,5,'Choriocarcinoma combined with embryonal carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9101',4,5,'Choriocarcinoma combined with teratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9102',4,4,'Malignant teratoma, trophoblastic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9105',4,4,'Trophoblastic tumor, epithelioid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('911',7,2,'Mesonephromas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',1,6,'Mesonephroma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',1,5,'Mesonephric adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',1,5,'Wolffian duct adenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',2,4,'Wolffian tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',3,5,'LCIS, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',2,5,'Wolffian duct tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9110',2,5,'Mesonephric tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',4,4,'Mesonephroma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',4,5,'Mesonephroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',4,5,'Mesonephric adenocarcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',4,5,'Wolffian duct carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('912-916',7,2,'Blood vessel tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,4,'Hemangioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8542',4,4,'Paget disease, extramammary',NULL,false,'(except of bone: not neoplastic)','2020-12-18 00:00:00+01',false,1),
	 ('8550',4,5,'Acinar adenocarcinoma, NOS',NULL,false,'(except of lung M-8551/3 or prostate M-8140/3)','2020-12-18 00:00:00+01',false,1),
	 ('9120',1,5,'Angioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9120',1,6,'Cherry hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,6,'Sinusoidal hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,6,'Microvenular hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,6,'Glomeruloid hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,6,'Spindle cell hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,6,'Hobnail hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',4,4,'Hemangiosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',4,5,'Angiosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9121',1,4,'Cavernous hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9122',1,4,'Venous hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9123',1,4,'Racemose hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9123',1,5,'Arteriovenous hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9125',1,4,'Epithelioid hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9125',1,5,'Histiocytoid hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9126',1,4,'Atypical vascular lesion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9130',1,4,'Hemangioendothelioma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9130',2,4,'Hemangioendothelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9130',2,5,'Angioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9130',2,6,'Kaposiform hemangioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9130',4,4,'Hemangioendothelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9130',4,5,'Hemangioendothelial sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,4,'Capillary hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,5,'Hemangioma simplex',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,5,'Infantile hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,5,'Juvenile hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,5,'Plexiform hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,6,'Lobular capillary hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,6,'Congenital hemangioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,6,'Congenital hemangioma, rapidly involuting',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9131',1,6,'Congenital hemangioma, non-involuting',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9132',1,4,'Intramuscular hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9132',1,5,'Intramuscular angioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9133',4,4,'Epithelioid hemangioendothelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9133',4,5,'Epithelioid hemangioendothelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9135',2,4,'Papillary intralymphatic angioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9135',2,5,'Endovascular papillary angioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9135',2,5,'Dabska tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9136',2,4,'Spindle cell hemangioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9136',2,5,'Spindle cell angioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9136',2,6,'Retiform hemangioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9136',2,6,'Composite hemangioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9137',1,4,'Myointimoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9137',4,4,'Intimal sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9138',2,4,'Pseudomyogenic (epithelioid sarcoma-like) hemangioendothelioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9140',4,4,'Kaposi sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9140',4,5,'Multiple hemorrhagic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9141',1,4,'Angiokeratoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9142',1,4,'Verrucous keratotic hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9142',1,5,'Verrucous venous malformation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9160',1,4,'Angiofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9160',1,5,'Juvenile angiofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9160',1,6,'Cellular angiofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9160',1,6,'Giant cell angiofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9161',1,4,'Acquired tufted hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9161',1,5,'Tufted hemangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9161',2,4,'Hemangioblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9161',2,5,'Angioblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('917',7,2,'Lymphatic vessel tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9170',1,4,'Lymphangioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9170',1,5,'Lymphangioendothelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9170',4,4,'Lymphangiosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9170',4,5,'Lymphangioendothelial sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9170',4,5,'Lymphangioendothelioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9171',1,4,'Capillary lymphangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9172',1,4,'Cavernous lymphangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9173',1,4,'Cystic lymphangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9173',1,5,'Hygroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9173',1,5,'Cystic hygroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9174',1,4,'Lymphangiomyoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9174',2,4,'Lymphangioleiomyomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9174',2,5,'Lymphangiomyomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9175',1,4,'Hemolymphangioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('918-924',7,2,'Osseous and chondromatous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9180',4,6,'Osteosarcoma, extraskeletal',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9211',1,4,'Osteochondromyxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9212',1,4,'Bizarre parosteal osteochondromatous proliferation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9213',1,4,'Subungual exostosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',2,4,'Chondromatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9222',2,4,'Atypical cartilaginous tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9231',4,4,'Myxoid chondrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9240',4,4,'Mesenchymal chondrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9251',2,4,'Giant cell tumor of soft parts, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9251',4,4,'Malignant giant cell tumor of soft parts',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',2,5,'Pigmented villonodular synovitis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('926',7,2,'Miscellaneous bone tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9260',1,4,'Aneurysmal bone cyst',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9262',1,4,'Ossifying fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9262',1,5,'Fibro-osteoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9262',1,5,'Osteofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('927-934',7,2,'Odontogenic tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9270',1,4,'Odontogenic tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9270',2,4,'Odontogenic tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9270',4,4,'Odontogenic tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9270',4,5,'Ameloblastic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9270',4,5,'Odontogenic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9270',4,5,'Odontogenic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9270',4,5,'Primary intraosseous carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9271',1,4,'Ameloblastic fibrodentinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9271',1,5,'Dentinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9272',1,4,'Cementoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9272',1,5,'Periapical cemental dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9272',1,5,'Periapical cemento-osseous dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9273',1,4,'Cementoblastoma, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9274',1,4,'Cemento-ossifying fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9274',1,6,'Cementifying fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9275',1,4,'Gigantiform cementoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9275',1,5,'Florid osseous dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9280',1,4,'Odontoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9281',1,4,'Compound odontoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9282',1,4,'Complex odontoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9290',1,4,'Ameloblastic fibro-odontoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9290',1,5,'Fibroameloblastic odontoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9290',4,4,'Ameloblastic odontosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9290',4,5,'Ameloblastic fibro-odontosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9290',4,5,'Ameloblastic fibrodentinosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9300',1,4,'Adenomatoid odontogenic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9300',1,5,'Adenoameloblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9301',1,4,'Calcifying odontogenic cyst',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9302',1,4,'Dentinogenic ghost cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9302',1,5,'Odontogenic ghost cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9302',4,4,'Ghost cell odontogenic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9310',1,4,'Ameloblastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9310',4,4,'Ameloblastoma, metastasizing',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8622',2,4,'Granulosa cell tumor, juvenile','(C56.9)',false,'(except of testis M-8622/0)','2020-12-18 00:00:00+01',false,1),
	 ('9310',4,5,'Ameloblastoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9311',1,4,'Odontoameloblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9312',1,4,'Squamous odontogenic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9320',1,4,'Odontogenic myxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9320',1,5,'Odontogenic myxofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9321',1,4,'Odontogenic fibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9321',1,5,'Central odontogenic fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9322',1,4,'Peripheral odontogenic fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9330',1,4,'Ameloblastic fibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9330',4,4,'Ameloblastic fibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9330',4,5,'Ameloblastic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9330',4,5,'Odontogenic fibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9340',1,4,'Calcifying epithelial odontogenic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9340',1,5,'Pindborg tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9341',4,4,'Clear cell odontogenic carcinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9341',4,5,'Clear cell odontogenic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9342',4,4,'Odontogenic carcinosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('935-937',7,2,'Miscellaneous tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9363',1,4,'Melanotic neuroectodermal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9363',1,5,'Melanoameloblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9363',1,5,'Melanotic progonoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9363',1,5,'Retinal anlage tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9364',4,4,'Ewing sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9364',4,5,'Ewing tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9364',4,5,'Peripheral neuroectodermal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9364',4,6,'Neuroectodermal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9364',4,6,'Peripheral primitive neuroectodermal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9365',4,4,'Askin tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',4,4,'Malignant melanoma, NOS',NULL,false,'(except of soft parts M-9044/3)','2020-12-18 00:00:00+01',false,1),
	 ('8693',4,6,'Chemodectoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9370',1,4,'Benign notochordal cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9370',4,4,'Chordoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9371',4,4,'Chondroid chordoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9372',4,4,'Dedifferentiated chordoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9373',1,4,'Parachordoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('938-948',7,2,'Gliomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9395',4,4,'Papillary tumor of pineal region',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9413',1,4,'Dysembryoplastic neuroepithelial tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9431',2,4,'Angiocentric glioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9473',4,4,'CNS embryonal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9473',4,5,'Primitive neuroectodermal tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9473',4,5,'PNET, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('949-952',7,2,'Neuroepitheliomatous neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9490',1,4,'Ganglioneuroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9490',4,4,'Ganglioneuroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9490',4,6,'CNS ganglioneuroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9491',1,4,'Ganglioneuromatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9492',1,4,'Gangliocytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9500',4,4,'Neuroblastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9500',4,5,'CNS neuroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9500',4,5,'Sympathicoblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9501',4,4,'Medulloepithelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9502',4,4,'Teratoid medulloepithelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9503',4,4,'Neuroepithelioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9504',4,4,'Spongioneuroblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9505',2,4,'Ganglioglioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9505',2,5,'Glioneuroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9505',2,5,'Neuroastrocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9505',4,4,'Ganglioglioma, anaplastic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9506',2,4,'Central neurocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9506',2,5,'Neurocytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9506',2,6,'Extraventricular neurocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9507',1,4,'Pacinian tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9509',2,4,'Papillary glioneuronal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9509',2,6,'Rosette-forming glioneuronal tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9520',4,4,'Olfactory neurogenic tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('953',7,2,'Meningiomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',1,4,'Meningioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',1,6,'Lymphoplasmacyte-rich meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',1,6,'Metaplastic meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',1,6,'Microcystic meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',1,6,'Secretory meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',4,4,'Meningioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',4,5,'Leptomeningeal sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',4,5,'Meningeal sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9530',4,5,'Meningioma, anaplastic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9530',4,5,'Meningothelial sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9531',1,4,'Meningothelial meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9531',1,5,'Endotheliomatous meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9531',1,5,'Syncytial meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9532',1,4,'Fibrous meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9532',1,5,'Fibroblastic meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9533',1,4,'Psammomatous meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9534',1,4,'Angiomatous meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9535',1,4,'Hemangioblastic meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9535',1,5,'Angioblastic meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9537',1,4,'Transitional meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9537',1,5,'Mixed meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9538',2,4,'Clear cell meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9538',2,6,'Chordoid meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9538',4,4,'Papillary meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9538',4,6,'Rhabdoid meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9539',2,4,'Atypical meningioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9539',4,4,'Meningeal sarcomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('954-957',7,2,'Nerve sheath tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',1,4,'Neurofibroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9540',4,4,'Malignant peripheral nerve sheath tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,5,'MPNST, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,5,'Neurofibrosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,5,'Neurogenic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,5,'Neurosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,6,'Melanotic MPNST',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,6,'Melanotic psammomatous MPNST',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,6,'MPNST with glandular differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,6,'MPNST with mesenchymal differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9540',4,6,'MPNST with perineurial differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9541',1,4,'Melanotic neurofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8726',1,6,'Melanocytoma, NOS',NULL,false,'(see also M-8780/1)','2020-12-18 00:00:00+01',false,1),
	 ('9542',4,4,'Malignant peripheral nerve sheath tumor, epithelioid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9542',4,5,'Epithelioid MPNST',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9550',1,4,'Plexiform neurofibroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9550',1,5,'Plexiform neuroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,4,'Schwannoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,5,'Neurilemoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,5,'Neurinoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,6,'Ancient schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9560',1,6,'Cellular schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,6,'Degenerated schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,6,'Plexiform schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,6,'Psammomatous schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',2,4,'Melanotic schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',2,5,'Pigmented schwannoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',4,4,'Neurilemoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',4,5,'Malignant schwannoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',4,5,'Neurilemosarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9561',4,4,'Malignant peripheral nerve sheath tumor with rhabdomyoblastic differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9561',4,5,'Malignant schwannoma with rhabdomyoblastic differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9561',4,5,'MPNST with rhabdomyoblastic differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9561',4,5,'Triton tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9562',1,4,'Nerve sheath myxoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9562',1,5,'Neurothekeoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9562',1,6,'Cellular neurothekeoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9563',1,4,'Nerve sheath tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9563',1,6,'Hybrid nerve sheath tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9570',1,4,'Neuroma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9570',1,6,'Solitary circumscribed neuroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9571',1,4,'Perineurioma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9571',1,6,'Intraneural perineurioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9571',1,6,'Soft tissue perineurioma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9571',4,4,'Perineurioma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('958',7,2,'Granular cell tumors and alveolar soft part sarcomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9580',1,5,'Granular cell myoblastoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9580',4,4,'Granular cell tumor, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9580',4,5,'Granular cell myoblastoma, malignant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9581',4,4,'Alveolar soft part sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('959-972',7,2,'Hodgkin and non-Hodgkin lymphomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('959',7,3,'Malignant lymphomas, NOS or diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9590',4,4,'Malignant lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9590',4,5,'Lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',2,6,'Monoclonal B-cell lymphocytosis, non-CLL type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,4,'Malignant lymphoma, non-Hodgkin, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Non-Hodgkin lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'B-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Lymphosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Lymphosarcoma, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Malignant lymphoma, diffuse, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9591',4,6,'Malignant lymphoma, non-cleaved cell, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Reticulum cell sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Reticulosarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Reticulum cell sarcoma, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Reticulosarcoma, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Hairy cell leukemia variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Malignant lymphoma, lymphocytic, intermediate differentiation, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Malignant lymphoma, lymphocytic, poorly differentiated, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Malignant lymphoma, cleaved cell, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Malignant lymphoma, small cleaved cell, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9591',4,6,'Malignant lymphoma, small cell, noncleaved, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Malignant lymphoma, undifferentiated cell type, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,5,'Malignant lymphoma, undifferentiated cell, non-Burkitt',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Malignant lymphoma, small cleaved cell, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Splenic B-cell lymphoma/leukemia, unclassifiable',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,6,'Splenic diffuse red pulp small B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9596',4,4,'Composite Hodgkin and non-Hodgkin lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9596',4,6,'B-cell lymphoma, unclassifiable, with features intermediate between diffuse large B-cell lymphoma and classical Hodgkin lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('965-966',7,3,'Hodgkin lymphomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9650',4,4,'Hodgkin lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9650',4,5,'Hodgkin disease, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9650',4,5,'Malignant lymphoma, Hodgkin',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9650',4,6,'Classical Hodgkin lymphoma post-transplant lymphoproliferative disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9651',4,4,'Hodgkin lymphoma, lymphocyte-rich',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8802',4,4,'Giant cell sarcoma',NULL,false,'(except of bone M-9250/3)','2020-12-18 00:00:00+01',false,1),
	 ('8810',1,4,'Fibroma, NOS',NULL,false,'(except of tendon sheath M-8813/0)','2020-12-18 00:00:00+01',false,1),
	 ('9651',4,5,'Classical Hodgkin lymphoma, lymphocyte-rich',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9651',4,6,'Hodgkin disease, lymphocyte predominance, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9651',4,5,'Hodgkin disease, lymphocyte predominance, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9651',4,5,'Hodgkin disease, lymphocytic-histiocytic predominance',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9652',4,4,'Hodgkin lymphoma, mixed cellularity, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9652',4,5,'Classical Hodgkin lymphoma, mixed cellularity, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9653',4,4,'Hodgkin lymphoma, lymphocyte depletion, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9871',4,5,'FAB M4Eo',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9653',4,5,'Classical Hodgkin lymphoma, lymphocyte depletion, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9654',4,4,'Hodgkin lymphoma, lymphocyte depletion, diffuse fibrosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9654',4,5,'Classical Hodgkin lymphoma, lymphocyte depletion, diffuse fibrosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9655',4,4,'Hodgkin lymphoma, lymphocyte depletion, reticular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9655',4,5,'Classical Hodgkin lymphoma, lymphocyte depletion, reticular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9659',4,4,'Hodgkin lymphoma, nodular lymphocyte predominant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9659',4,5,'Hodgkin paragranuloma, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9661',4,4,'Hodgkin granuloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9662',4,4,'Hodgkin sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9663',4,4,'Hodgkin lymphoma, nodular sclerosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9663',4,5,'Classical Hodgkin lymphoma, nodular sclerosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9663',4,5,'Hodgkin disease, nodular sclerosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9664',4,4,'Hodgkin lymphoma, nodular sclerosis, cellular phase',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9664',4,5,'Classical Hodgkin lymphoma, nodular sclerosis, cellular phase',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9665',4,4,'Hodgkin lymphoma, nodular sclerosis, grade 1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9665',4,5,'Classical Hodgkin lymphoma, nodular sclerosis, grade 1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9665',4,5,'Hodgkin disease, nodular sclerosis, lymphocyte predominance',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9665',4,5,'Hodgkin disease, nodular sclerosis, mixed cellularity',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9667',4,4,'Hodgkin lymphoma, nodular sclerosis, grade 2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9667',4,5,'Classical Hodgkin lymphoma, nodular sclerosis, grade 2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9667',4,5,'Hodgkin disease, nodular sclerosis, lymphocyte depletion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9667',4,5,'Hodgkin disease, nodular sclerosis, syncytial variant',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('967-972',7,3,'Non-hodgkin lymphomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('967-969',7,3,'Mature B-cell lymphomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9671',4,5,'Malignant lymphoma, lymphoplasmacytoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9671',4,6,'Immunocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9671',4,6,'Malignant lymphoma, plasmacytoid',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9671',4,6,'Plasmacytic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9673',2,4,'In situ mantle cell neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9673',2,5,'In situ mantle cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9673',4,5,'Malignant lymphoma, centrocytic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9673',4,5,'Malignant lymphoma, lymphocytic, intermediate differentiation, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9673',4,5,'Malignant lymphomatous polyposis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9673',4,5,'Mantle zone lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9675',4,5,'Malignant lymphoma, centroblastic-centrocytic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9675',4,5,'Malignant lymphoma, centroblastic-centrocytic, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9675',4,5,'Malignant lymphoma, mixed cell type, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9675',4,5,'Malignant lymphoma, mixed lymphocytic-histiocytic, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9678',4,4,'Primary effusion lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',2,4,'EBV positive mucocutaneous ulcer',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,4,'Diffuse large B-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large B-cell, diffuse, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, histiocytic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large B-cell, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large B-cell, diffuse, centroblastic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large cell, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9680',4,5,'Malignant lymphoma, large cell, cleaved, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large cell, diffuse, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large cell, noncleaved, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, noncleaved, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, noncleaved, diffuse, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, histiocytic, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large cell, cleaved and noncleaved',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9867',4,5,'FAB M4',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large cell, cleaved, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',1,5,'Fibrous histiocytoma, NOS',NULL,false,'(except of tendon sheath M-9252/0)','2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8853',4,4,'Round cell liposarcoma',NULL,false,'(see also M-8852/3)','2020-12-18 00:00:00+01',false,1),
	 ('9680',4,5,'Malignant lymphoma, large cell, noncleaved, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Malignant lymphoma, centroblastic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Diffuse large B-cell lymphoma, germinal center B-cell subtype',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Diffuse large B-cell lymphoma, activated B-cell subtype',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Malignant lymphoma, centroblastic, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Anaplastic large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'B-cell lymphoma, unclassifiable, with features intermediate between diffuse large B-cell lymphoma and Burkitt lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Diffuse large B-cell lymphoma associated with chronic inflammation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'EBV positive diffuse large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9680',4,6,'High grade B-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'High grade B-cell lymphoma with MYC and BCL2 and/or BCL6 rearrangements',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9684',4,4,'Malignant lymphoma, large B-cell, diffuse, immunoblastic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9684',4,5,'Malignant lymphoma, immunoblastic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9684',4,5,'Malignant lymphoma, large cell, immunoblastic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'Burkitt tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'Malignant lymphoma, small noncleaved, Burkitt type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'Malignant lymphoma, undifferentiated, Burkitt type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,6,'Burkitt-like lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,6,'Burkitt-like lymphoma with 11q aberration',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9687',4,5,'Burkitt cell leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'Acute leukemia, Burkitt type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'Acute lymphoblastic leukemia, mature B-cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'B-ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9687',4,5,'FAB L3',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9688',4,4,'T-cell/histiocyte rich large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9688',4,5,'T-cell rich large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9688',4,5,'Histiocyte-rich large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9690',4,5,'Malignant lymphoma, follicle center, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9690',4,5,'Malignant lymphoma, follicular, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9690',4,5,'Malignant lymphoma, lymphocytic, nodular, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9690',4,5,'Malignant lymphoma, nodular, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9690',4,5,'Malignant lymphoma, centroblastic-centrocytic, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9690',4,5,'Malignant lymphoma, follicle center, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9690',4,6,'Follicular lymphoma, pediatric type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9691',4,4,'Follicular lymphoma, grade 2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9691',4,5,'Malignant lymphoma, mixed cell type, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9691',4,5,'Malignant lymphoma, mixed cell type, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9691',4,5,'Malignant lymphoma, mixed lymphocytic-histiocytic, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9691',4,5,'Malignant lymphoma, mixed small cleaved and large cell, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9695',2,4,'In situ follicular neoplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9695',2,5,'In situ follicular lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9695',4,4,'Follicular lymphoma, grade 1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9695',4,5,'Follicular lymphoma, small cleaved cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9695',4,5,'Malignant lymphoma, lymphocytic, poorly differentiated, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9695',4,5,'Malignant lymphoma, small cleaved cell, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,4,'Follicular lymphoma, grade 3',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, large cell, follicular, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, noncleaved cell, follicular, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Follicular lymphoma, grade 3A',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9698',4,5,'Follicular lymphoma, grade 3B',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, centroblastic, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, histiocytic, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, large cell, noncleaved, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, large cleaved cell, follicular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,5,'Malignant lymphoma, lymphocytic, well differentiated, nodular',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9698',4,6,'Large B-cell lymphoma with IRF4 rearrangement',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,4,'Marginal zone B-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'Marginal zone lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'BALT lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9699',4,5,'Bronchus-associated lymphoid tissue lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'MALT lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'Monocytoid B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'Mucosa-associated lymphoid tissue lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'Nodal marginal zone lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8046',4,7,'Non-small cell lung cancer',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,7,'Squamous cell carcinoma of lung',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9699',4,5,'SALT lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,5,'Skin-associated lymphoid tissue lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9699',4,6,'Extranodal marginal zone lymphoma of mucosa-associated lymphoid tissue',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9700',4,5,'Pagetoid reticulosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9701',4,4,'Sezary syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9701',4,5,'Sezary disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',2,4,'Indolent T-cell lymphoproliferative disorder of gastrointestinal tract',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,4,'Mature T-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,5,'Peripheral T-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,5,'T-cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,5,'Peripheral T-cell lymphoma, large cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,5,'Peripheral T-cell lymphoma, pleomorphic medium and large cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,5,'Peripheral T-cell lymphoma, pleomorphic small cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9702',4,5,'T-zone lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,6,'Lymphoepithelioid lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,5,'Lennert lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,6,'Follicular T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9702',4,6,'Nodal peripheral T-cell lymphoma with T follicular helper phenotype',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9705',4,4,'Angioimmunoblastic T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9705',4,5,'Angioimmunoblastic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9705',4,5,'Peripheral T-cell lymphoma, AILD (Angioimmunoblastic Lymphadenopathy with Dysproteinemia)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9708',4,4,'Subcutaneous panniculitis-like T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9712',4,5,'Intravascular B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9712',4,5,'Angioendotheliomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9712',4,5,'Angiotropic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9714',4,4,'Anaplastic large cell lymphoma, T-cell and Null-cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9714',4,5,'Large cell (Ki-1 positive) lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9714',4,6,'Anaplastic large cell lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9714',4,5,'Anaplastic large cell lymphoma, CD30 positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9714',4,6,'Anaplastic large cell lymphoma, ALK positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9715',4,4,'Anaplastic large cell lymphoma, ALK negative',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9716',4,4,'Hepatosplenic T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9716',4,5,'Hepatosplenic gamma-delta cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9717',4,4,'Intestinal T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9717',4,5,'Enteropathy-associated T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9717',4,5,'Enteropathy type intestinal T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9717',4,6,'Monomorphic epitheliotropic intestinal T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9719',4,4,'NK/T-cell lymphoma, nasal and nasal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9719',4,5,'Malignant reticulosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9719',4,5,'Angiocentric T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9719',4,5,'Extranodal NK/T-cell lymphoma, nasal type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9719',4,5,'Malignant midline reticulosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9719',4,5,'Polymorphic reticulosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9719',4,5,'T/NK-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('972',7,3,'Precursor cell lymphoblastic lymphomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9724',4,4,'Systemic EBV positive T-cell lymphoproliferative disease of childhood',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9725',2,4,'Hydroa vacciniforme-like lymphoproliferative disorder',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9725',2,5,'Hydroa vacciniforme-like lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9727',4,5,'Lymphoblastoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9727',4,5,'Malignant lymphoma, convoluted cell',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9727',4,6,'Blastic NK-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9727',4,6,'Blastic plasmacytoid dendritic cell neoplasm',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('973',7,2,'Plasma cell neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9731',4,4,'Plasmacytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9731',4,5,'Plasma cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9731',4,5,'Solitary myeloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9731',4,5,'Solitary plasmacytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9734',4,5,'Extraosseous plasmacytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9735',4,4,'Plasmablastic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9737',4,4,'ALK positive large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9738',4,4,'HHV8 positive diffuse large B-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9738',4,5,'Large B-cell lymphoma arising in HHV8-associated multicentric Castleman disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('974',7,2,'Mast cell neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9740',2,4,'Mastocytoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',2,5,'Mast cell tumor, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',2,6,'Extracutaneous mastocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',2,6,'Urticaria pigmentosa',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',4,4,'Mast cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',4,5,'Malignant mast cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',4,5,'Malignant mastocytoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9741',2,4,'Indolent systemic mastocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9741',4,4,'Malignant mastocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9741',4,5,'Systemic tissue mast cell disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9741',4,6,'Aggressive systemic mastocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9741',4,6,'Systemic mastocytosis with AHNMD',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9741',4,6,'Systemic mastocytosis with associated hematological clonal non-mast cell disorder',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9749',4,4,'Erdheim-Chester disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('975',7,2,'Neoplasms of histiocytes and accessory lymphoid cells',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9750',4,4,'Malignant histiocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9750',4,6,'Histiocytic medullary reticulosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',2,4,'Langerhans cell histiocytosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',2,6,'Langerhans cell histiocytosis, monostotic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',2,6,'Langerhans cell histiocytosis, polystotic',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9751',4,4,'Langerhans cell histiocytosis, disseminated',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,5,'Langerhans cell granulomatosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,6,'Eosinophilic granuloma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,6,'Acute progressive histiocytosis X',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,6,'Histiocytosis X, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,6,'Hand-Schuller-Christian disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,6,'Letterer-Siwe disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9751',4,6,'Nonlipid reticuloendotheliosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9755',4,4,'Histiocytic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9755',4,6,'True histiocytic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9756',4,4,'Langerhans cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9757',4,4,'Interdigitating dendritic cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9757',4,5,'Interdigitating cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9757',4,6,'Dendritic cell sarcoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9757',4,6,'Indeterminate dendritic cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9758',4,4,'Follicular dendritic cell sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9758',4,6,'Follicular dendritic cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9759',4,4,'Fibroblastic reticular cell tumor',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('976',7,2,'Immunoproliferative diseases',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9760',4,4,'Immunoproliferative disease, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9761',2,4,'IgM monoclonal gammopathy of undetermined significance',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9762',4,4,'Heavy chain disease, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9762',4,6,'Alpha heavy chain disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9762',4,6,'Gamma heavy chain disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9762',4,5,'Franklin disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9762',4,6,'Mu heavy chain disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9764',4,5,'Mediterranean lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9765',2,4,'Monoclonal gammopathy of undetermined significance, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9765',2,5,'MGUS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9765',2,5,'Monoclonal gammopathy, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9766',2,4,'Angiocentric immunoproliferative lesion',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9766',2,6,'Lymphomatoid granulomatosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9766',2,6,'Lymphomatoid granulomatosis, grade 1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9766',2,6,'Lymphomatoid granulomatosis, grade 2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9766',4,4,'Lymphomatoid granulomatosis, grade 3',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9767',2,4,'Angioimmunoblastic lymphadenopathy (AIL)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9767',2,5,'Immunoblastic lymphadenopathy (IBL)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9768',2,4,'T-gamma lymphoproliferative disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9769',2,4,'Immunoglobulin deposition disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9769',2,5,'Primary amyloidosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9769',2,5,'Systemic light chain disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('980',7,3,'Leukemias, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9800',4,4,'Leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9800',4,6,'Aleukemic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9800',4,6,'Chronic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9800',4,6,'Subacute leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9801',4,4,'Acute leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9801',4,5,'Blast cell leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9801',4,5,'Stem cell leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9801',4,5,'Undifferentiated leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9805',4,4,'Acute biphenotypic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9805',4,6,'Acute bilineal leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9805',4,6,'Acute mixed lineage leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9806',4,4,'Mixed phenotype acute leukemia with t(9;22)(q34;q11.2); BCR-ABL1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9807',4,4,'Mixed phenotype acute leukemia with t(v;11q23); MLL rearranged',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9808',4,4,'Mixed phenotype acute leukemia, B/myeloid, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9809',4,4,'Mixed phenotype acute leukemia, T/myeloid, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('981-983',7,3,'Lymphoid leukemias',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,4,'B lymphoblastic leukemia/lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'c-ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9811',4,5,'Common ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'Common precursor B ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'Pre-B ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'Pre-pre-B ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'Pro-B ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'Precursor B-cell lymphoblastic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9044',4,4,'Clear cell sarcoma, NOS',NULL,false,'(except of kidney M-8964/3)','2020-12-18 00:00:00+01',false,1),
	 ('9052',1,6,'Well differentiated papillary mesothelioma',NULL,false,'(except of pleura M-9052/1)','2020-12-18 00:00:00+01',false,1),
	 ('9010',1,6,'Lipofibroadenoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9811',4,5,'Precursor B-cell lymphoblastic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9811',4,6,'B lymphoblastic leukemia/lymphoma with iAMP21',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9812',4,4,'B lymphoblastic leukemia/lymphoma with t(9;22)(q34;q11.2); BCR-ABL1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9813',4,4,'B lymphoblastic leukemia/lymphoma with t(v;11q23); MLL rearranged',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9814',4,4,'B lymphoblastic leukemia/lymphoma with t(12;21)(p13;q22); TEL-AML1 (ETV6-RUNX1)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9815',4,4,'B lymphoblastic leukemia/lymphoma with hyperdiploidy',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9816',4,4,'B lymphoblastic leukemia/lymphoma with hypodiploidy (Hypodiploid ALL)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9817',4,4,'B lymphoblastic leukemia/lymphoma with t(5;14)(q31;q32); IL3-IGH',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9818',4,4,'B lymphoblastic leukemia/lymphoma with t(1;19)(q23;p13.3); E2A-PBX1 (TCF3-PBX1)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9819',4,4,'B lymphoblastic leukemia/lymphoma, BCR-ABL1-like',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,4,'Lymphoid leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9820',4,6,'Lymphatic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,6,'Lymphocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,6,'Aleukemic lymphoid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,5,'Aleukemic lymphatic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,5,'Aleukemic lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,6,'Lymphosarcoma cell leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,6,'Subacute lymphoid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,5,'Subacute lymphatic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9820',4,5,'Subacute lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',2,4,'Monoclonal B-cell lymphocytosis, CLL type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9823',4,4,'B-cell chronic lymphocytic leukemia/small lymphocytic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Chronic lymphatic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Chronic lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Chronic lymphoid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, small B lymphocytic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, lymphocytic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, lymphocytic, diffuse, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, small cell, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, small lymphocytic, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, lymphocytic, well differentiated, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9823',4,5,'Malignant lymphoma, small cell diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Malignant lymphoma, small lymphocytic, diffuse',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9827',4,5,'Adult T-cell leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9827',4,5,'Adult T-cell lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9827',4,5,'Adult T-cell lymphoma/leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9831',4,4,'T-cell large granular lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9831',4,5,'Large granular lymphocytosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9831',4,5,'NK-cell large granular lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9831',4,5,'T-cell large granular lymphocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9831',4,6,'Chronic lymphoproliferative disorder of NK cells',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9832',4,4,'Prolymphocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9833',4,4,'Prolymphocytic leukemia, B-cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9834',4,4,'Prolymphocytic leukemia, T-cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphoblastic leukemia, L2 type, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphoblastic leukemia-lymphoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Lymphoblastic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphatic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphoid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'FAB L1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9835',4,5,'FAB L2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Precursor cell lymphoblastic leukemia, not phenotyped',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphoblastic leukemia, precursor-cell type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,4,'Precursor T-cell lymphoblastic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,5,'Cortical T ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,5,'Mature T ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,5,'Pre-T ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,5,'Pro-T ALL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,5,'Precursor T-cell lymphoblastic lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9837',4,6,'T lymphoblastic leukemia/lymphoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9837',4,6,'Early T-cell precursor acute lymphoblastic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('984-993',7,3,'Myeloid leukemias',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,4,'Acute erythroid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'Acute myeloid leukemia, M6 type',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',4,7,'Adenocarcinoma of lung',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8012',4,7,'Large cell carcinoma of lung',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8041',4,7,'Small cell carcinoma of lung',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9080',4,5,'Immature teratoma, NOS',NULL,false,'(except of lung, thymus or thyroid M-9080/1)','2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'Acute erythremia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'Acute erythremic myelosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9840',4,5,'AML M6',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'Di Guglielmo disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'Erythremic myelosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'Erythroleukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'FAB M6',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'M6A',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9840',4,5,'M6B',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,4,'Myeloid leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Granulocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Myelocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9860',4,5,'Myelogenous leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Myelomonocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Non-lymphocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,6,'Aleukemic myeloid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Aleukemic granulocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Aleukemic myelogenous leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,6,'Aleukemic monocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,6,'Chronic monocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,6,'Eosinophilic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,6,'Monocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9860',4,6,'Subacute monocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,6,'Subacute myeloid leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Subacute granulocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9860',4,5,'Subacute myelogenous leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9861',4,5,'Acute granulocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9861',4,5,'Acute myelocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9861',4,5,'Acute myelogenous leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9861',4,5,'Acute non-lymphocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9863',4,4,'Chronic myeloid leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9863',4,5,'Chronic granulocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9863',4,5,'Chronic myelocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9863',4,5,'Chronic myelogenous leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9865',4,4,'Acute myeloid leukemia with t(6;9)(p23;q34); DEK-NUP214',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9866',4,4,'Acute promyelocytic leukemia, t(15;17)(q22;q11-12)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9866',4,5,'Acute promyelocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9866',4,5,'Acute myeloid leukemia, PML/RAR-alpha',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9866',4,5,'Acute myeloid leukemia, t(15;17)(q22;q11-12)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9866',4,5,'Acute promyelocytic leukemia, PML/RAR-alpha',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9867',4,4,'Acute myelomonocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9869',4,4,'Acute myeloid leukemia with inv(3)(q21;q26.2) or t(3;3)(q21;q26.2); RPN1-EVI1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9870',4,4,'Acute basophilic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9871',4,5,'Acute myeloid leukemia, CBF-beta/MYH11',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9871',4,5,'Acute myeloid leukemia, inv(16)(p13;q22)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9871',4,5,'Acute myeloid leukemia, t(16;16)(p13;q11)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9871',4,5,'Acute myelomonocytic leukemia with abnormal eosinophils',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9872',4,4,'Acute myeloid leukemia, minimal differentiation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9872',4,5,'Acute myeloblastic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9873',4,4,'Acute myeloid leukemia without maturation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9873',4,5,'FAB M1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9874',4,4,'Acute myeloid leukemia with maturation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9874',4,5,'FAB M2, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,4,'Chronic myeloid leukemia, BCR/ABL positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic myelogenous leukemia, BCR/ABL positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic granulocytic leukemia, BCR/ABL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic granulocytic leukemia, Philadelphia chromosome (Ph1) positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic granulocytic leukemia, t(9;22)(q34;q11)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic myeloid leukemia, Philadelphia chromosome (Ph1) positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic myelogenous leukemia, Philadelphia chromosome (Ph1) positive',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic myeloid leukemia, t(9;22)(q34;q11)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9875',4,5,'Chronic myelogenous leukemia, t(9;22)(q34;q11)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9876',4,4,'Atypical chronic myeloid leukemia, BCR/ABL negative',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9876',4,6,'Atypical chronic myeloid leukemia, Philadelphia chromosome (Ph1) negative',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9877',4,4,'Acute myeloid leukemia with mutated NPM1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9878',4,4,'Acute myeloid leukemia with biallelic mutation of CEBPA',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9879',4,4,'Acute myeloid leukemia with mutated RUNX1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9891',4,4,'Acute monocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9891',4,5,'Monoblastic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9891',4,5,'Acute monoblastic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',4,7,'Malignant melanoma of skin',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8743',4,7,'Superficial spreading malignant melanoma of skin',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9891',4,6,'Acute monoblastic and monocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9895',4,4,'Acute myeloid leukemia with myelodysplasia-related changes',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9895',4,5,'Acute myeloid leukemia with multilineage dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9895',4,5,'Acute myeloid leukemia with prior myelodysplastic syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9895',4,5,'Acute myeloid leukemia without prior myelodysplastic syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9896',4,4,'Acute myeloid leukemia, t(8;21)(q22;q22)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9896',4,5,'Acute myeloid leukemia, AML1(CBF-alpha)/ETO',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9896',4,5,'Acute myeloid leukemia with t(8;21)(q22;q22); RUNX1-RUNX1T1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9896',4,5,'FAB M2, AML1(CBF-alpha)/ETO',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9896',4,5,'FAB M2, t(8;21)(q22;q22)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9897',4,4,'Acute myeloid leukemia, 11q23 abnormalities',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9897',4,5,'Acute myeloid leukemia, MLL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9897',4,5,'Acute myeloid leukemia with t(9;11)(p22;q23); MLLT3-MLL',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9898',2,4,'Transient abnormal myelopoiesis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9898',4,4,'Myeloid leukemia associated with Down syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9910',4,4,'Acute megakaryoblastic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9910',4,5,'Megakaryocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9910',4,5,'FAB M7',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9911',4,4,'Acute myeloid leukemia (megakaryoblastic) with t(1;22)(p13;q13); RBM15-MKL1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9912',4,4,'Acute myeloid leukemia with BCR-ABL1',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9920',4,4,'Therapy-related myeloid neoplasm',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9920',4,5,'Therapy-related acute myeloid leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9920',4,6,'Therapy-related acute myeloid leukemia, alkylating agent related',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9920',4,6,'Therapy-related acute myeloid leukemia, epipodophyllotoxin-related',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9930',4,5,'Chloroma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9930',4,5,'Granulocytic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9931',4,5,'Acute myelosclerosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9931',4,5,'Acute panmyelosis, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9931',4,5,'Acute myelofibrosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9931',4,5,'Malignant myelosclerosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('994',7,3,'Other leukemias',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9940',4,5,'Leukemic reticuloendotheliosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9945',4,4,'Chronic myelomonocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9945',4,6,'Chronic myelomonocytic leukemia, type I',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9945',4,6,'Chronic myelomonocytic leukemia, type II',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9945',4,5,'Chronic myelomonocytic leukemia in transformation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9946',4,4,'Juvenile myelomonocytic leukemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9946',4,5,'Juvenile chronic myelomonocytic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9948',4,4,'Aggressive NK-cell leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('995-996',7,2,'Myeloproliferative neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9950',4,4,'Polycythemia vera',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9950',4,5,'Chronic erythremia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9950',4,5,'Polycythemia rubra vera',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9961',4,5,'Megakaryocytic myelosclerosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9961',4,5,'Myelofibrosis as a result of myeloproliferative disease',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9961',4,5,'Myelofibrosis with myeloid metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9961',4,5,'Myelosclerosis with myeloid metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9962',4,4,'Essential thrombocythemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9962',4,5,'Essential hemorrhagic thrombocythemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9962',4,5,'Idiopathic hemorrhagic thrombocythemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9962',4,5,'Idiopathic thrombocythemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9963',4,4,'Chronic neutrophilic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9964',4,4,'Chronic eosinophilic leukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9964',4,5,'Hypereosinophilic syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9965',4,4,'Myeloid or lymphoid neoplasm with PDGFRA rearrangement',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9966',4,4,'Myeloid neoplasm with PDGFRB rearrangement',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9967',4,4,'Myeloid or lymphoid neoplasm with FGFR1 abnormalities',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9968',4,4,'Myeloid or lymphoid neoplasm with PCM1-JAK2',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('997',7,2,'Other hematological neoplasms',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9970',2,4,'Lymphoproliferative disorder, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9970',2,5,'Lymphoproliferative disease, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9971',2,5,'PTLD, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9971',2,6,'Polymorphic post-transplant lymphoproliferative disorder',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9975',4,4,'Myeloproliferative neoplasm, unclassifiable',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9975',4,6,'Myelodysplastic/myeloproliferative neoplasm, unclassifiable',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('998-999',7,2,'Myelodysplastic syndromes',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9980',4,4,'Myelodysplastic syndrome with single lineage dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9980',4,5,'Refractory anemia, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9980',4,5,'Refractory anemia without sideroblasts',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9980',4,5,'Refractory neutropenia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9980',4,5,'Refractory thrombocytopenia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9982',4,4,'Myelodysplastic syndrome with ring sideroblasts and single lineage dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9982',4,5,'Refractory anemia with sideroblasts',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9982',4,5,'RARS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9982',4,5,'Refractory anemia with ring sideroblasts associated with marked thrombocytosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9982',4,5,'Refractory anemia with ring sideroblasts, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9982',4,5,'Myelodysplastic syndrome with ring sideroblasts, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9983',4,4,'Myelodysplastic syndrome with excess blasts',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9983',4,5,'Refractory anemia with excess blasts, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9983',4,5,'RAEB, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9983',4,5,'RAEB I',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9983',4,5,'RAEB II',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9984',4,4,'Refractory anemia with excess blasts in transformation',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9984',4,5,'RAEB-T',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9985',4,4,'Myelodysplastic syndrome with multilineage dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9985',4,5,'Refractory cytopenia with multilineage dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9985',4,6,'Refractory cytopenia of childhood',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9986',4,4,'Myelodysplastic syndrome with isolated del (5q)',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9986',4,5,'Myelodysplastic syndrome with 5q deletion (5q-) syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9987',4,4,'Therapy-related myelodysplastic syndrome, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9987',4,5,'Therapy-related myelodysplastic syndrome, alkylating agent related',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9987',4,5,'Therapy-related myelodysplastic syndrome, epipodophyllotoxin-related',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9989',4,4,'Myelodysplastic syndrome, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9989',4,5,'Preleukemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9989',4,5,'Preleukemic syndrome',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9989',4,6,'Myelodysplastic syndrome, unclassifiable',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9993',4,4,'Myelodysplastic syndrome with ring sideroblasts and multilineage dysplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8721',4,7,'Nodular malignant melanoma of skin',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8744',4,7,'Acral lentiginous malignant melanoma of skin',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8010',4,7,'Carcinoma of breast',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8520',4,7,'Lobular carcinoma of breast',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of colorectum',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of colorectum',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of colorectum',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of colorectum',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8120',4,7,'Transitional cell carcinoma of kidney',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of prostate',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8890',4,7,'Leiomyosarcoma of prostate',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9591',4,7,'Non-Hodgkin''s lymphoma',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9650',4,7,'Hodgkin''s lymphoma',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9861',4,7,'Acute myeloid leukemia, disease',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9835',4,7,'Acute lymphoid leukemia, disease',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9863',4,7,'Chronic myeloid leukemia, disease',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9823',4,7,'Chronic lymphoid leukemia, disease',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8120',4,7,'Transitional cell carcinoma of bladder',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,7,'Squamous cell carcinoma of bladder',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of bladder',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8980',4,7,'Carcinosarcoma of bladder',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of stomach',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of small intestine',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8140',4,7,'Adenocarcinoma of esophagus',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,7,'Squamous cell carcinoma of esophagus',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8000',2,7,'Neoplasm of endometrium',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9100',4,7,'Choriocarcinoma of placenta',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8000',2,7,'Neoplasm of ovary',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8140',4,7,'Adenocarcinoma of pancreas',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8000',2,7,'Neoplasm of liver',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9061',4,7,'Seminoma of testis',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9065',4,7,'Non-seminomatous germ cell neoplasm of testis',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8000',2,7,'Neoplasm of brain',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8140',4,7,'Ovarian Adenocarcinoma',NULL,false,NULL,'2020-09-23 15:48:18.964266+02',true,NULL),
	 ('8010',4,7,'Ureter Carcinoma',NULL,false,NULL,'2020-09-23 15:48:18.989231+02',true,NULL),
	 ('8500',4,7,'Infiltrating duct carcinoma of breast',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8900',4,7,'Primary rhabdomyosarcoma of male genital organ',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8148',1,7,'Prostatic intraepithelial neoplasia',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8000',2,7,'Neoplasm of thyroid gland',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',3,7,'Squamous cell carcinoma in situ of uterine cervix',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,7,'Head and neck squamous cell carcinoma',NULL,false,NULL,'2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8046',4,8,'NSCLC',NULL,false,'Non-small cell lung cancer','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,8,'LSCC',NULL,false,'Squamous cell carcinoma of lung','2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8012',4,8,'LCC',NULL,false,'Large cell carcinoma of lung','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8041',4,8,'SCLC',NULL,false,'Small cell carcinoma of lung','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8120',4,8,'KTCC',NULL,false,'Transitional cell carcinoma of kidney','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8312',4,8,'RCC',NULL,false,'Renal cell carcinoma','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9310',1,5,'Adamantinoma, NOS',NULL,false,'(except of long bones M-9261/3)','2020-12-18 00:00:00+01',false,1),
	 ('9310',4,5,'Adamantinoma, malignant',NULL,false,'(except of long bones M-9261/3)','2020-12-18 00:00:00+01',false,1),
	 ('925',7,2,'Giant cell tumors',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9591',4,8,'NHL',NULL,false,'Non-Hodgkin''s lymphoma','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9650',4,8,'HL',NULL,false,'Hodgkin''s lymphoma','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9861',4,8,'AML',NULL,false,'Acute myeloid leukemia, disease','2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9835',4,8,'ALL',NULL,false,'Acute lymphoid leukemia, disease','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9863',4,8,'CML',NULL,false,'Chronic myeloid leukemia, disease','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('9823',4,8,'CLL',NULL,false,'Chronic lymphoid leukemia, disease','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8120',4,8,'BTCC',NULL,false,'Transitional cell carcinoma of bladder','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,8,'BSCC',NULL,false,'Squamous cell carcinoma of bladder','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8936',4,8,'GIST',NULL,false,'Gastrointestinal stromal tumor','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8936',4,8,'GIST',NULL,false,'Gastrointestinal stromal tumor','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,8,'ESCC',NULL,false,'Squamous cell carcinoma of esophagus','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',3,8,'SIL',NULL,false,'Squamous cell carcinoma in situ of uterine cervix','2020-07-15 00:07:45.959574+02',true,NULL),
	 ('8070',4,8,'HNSCC',NULL,false,'Head and neck squamous cell carcinoma','2020-07-15 00:07:45.959574+02',true,NULL);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9380',4,5,'Glioma, NOS','(C71._)',false,'(except nasal glioma: not neoplastic)','2020-12-18 00:00:00+01',false,1),
	 ('9440',4,6,'Diffuse midline glioma, NOS','(C71._)',false,'(see also M-9385/3)','2020-12-18 00:00:00+01',false,1),
	 ('9440',4,6,'Diffuse intrinsic pontine glioma','(C71._)',false,'(see also M-9385/3)','2020-12-18 00:00:00+01',false,1),
	 ('9580',1,4,'Granular cell tumor, NOS',NULL,false,'(except of sellar region M-9582/0)','2020-12-18 00:00:00+01',false,1),
	 ('9591',2,4,'Monoclonal B-cell lymphocytosis, NOS',NULL,false,'(see also M-9823/1)','2020-12-18 00:00:00+01',false,1),
	 ('9671',4,4,'Lymphoplasmacytic lymphoma',NULL,false,'(see also M-9761/3)','2020-12-18 00:00:00+01',false,1),
	 ('9673',4,4,'Mantle cell lymphoma',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('9675',4,4,'Malignant lymphoma, mixed small and large cell, diffuse',NULL,false,'(see also M-9690/3)','2020-12-18 00:00:00+01',false,1),
	 ('9687',4,4,'Burkitt lymphoma, NOS',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('9690',4,4,'Follicular lymphoma, NOS',NULL,false,'(see also M-9675/3)','2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9727',4,4,'Precursor cell lymphoblastic lymphoma, NOS',NULL,false,'(see also M-9835/3)','2020-12-18 00:00:00+01',false,1),
	 ('9727',4,5,'Malignant lymphoma, lymphoblastic, NOS',NULL,false,'(see also M-9835/3)','2020-12-18 00:00:00+01',false,1),
	 ('9734',4,4,'Plasmacytoma, extramedullary',NULL,false,'not occurring in bone','2020-12-18 00:00:00+01',false,1),
	 ('9761',4,4,'Waldenstrom macroglobulinemia','(C42.0)',false,'(see also M-9671/3)','2020-12-18 00:00:00+01',false,1),
	 ('9823',4,5,'Chronic lymphocytic leukemia, B-cell type',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('8000',1,5,'Tumor, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9827',4,4,'Adult T-cell leukemia/lymphoma (HTLV-1 positive)',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('9835',4,4,'Precursor cell lymphoblastic leukemia, NOS',NULL,false,'(see also M-9727/3)','2020-12-18 00:00:00+01',false,1),
	 ('9835',4,5,'Acute lymphoblastic leukemia, NOS',NULL,false,'(see also M-9727/3)','2020-12-18 00:00:00+01',false,1),
	 ('9861',4,4,'Acute myeloid leukemia, NOS',NULL,false,'(see also M-9930/3)','2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9866',4,5,'FAB M3',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('9871',4,4,'Acute myeloid leukemia with abnormal marrow eosinophils',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('9891',4,5,'FAB M5',NULL,false,'includes all variants','2020-12-18 00:00:00+01',false,1),
	 ('9930',4,4,'Myeloid sarcoma',NULL,false,'(see also M-9861/3)','2020-12-18 00:00:00+01',false,1),
	 ('9971',2,4,'Post-transplant lymphoproliferative disorder, NOS',NULL,false,'(see also M-9650/3)','2020-12-18 00:00:00+01',false,1),
	 ('-',7,1,'MORPHOLOGY',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('800',7,2,'Neoplasms, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',1,4,'Neoplasm, benign',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8042',4,4,'Oat cell carcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8000',2,5,'Neoplasm, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8044',4,6,'Small cell carcinoma, hypercalcemic type','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8046',4,4,'Non-small cell carcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8071',3,6,'Differentiated penile intraepithelial neoplasia (PeIN)','(C60._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8071',3,6,'Differentiated vulvar intraepithelial neoplasia (VIN)','(C51._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',1,6,'Anal intraepithelial neoplasia, low grade','(C21.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8162',4,5,'Klatskin tumor','(C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',1,6,'Cervical intraepithelial neoplasia, low grade','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',1,5,'Pilomatrixoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',1,6,'Esophageal squamous intraepithelial neoplasia (dysplasia), low grade','(C15._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,6,'Anal intraepithelial neoplasia, grade III','(C21.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8077',3,5,'AIN III','(C21.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,6,'Cervical intraepithelial neoplasia, grade III','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'CIN III, NOS','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'CIN III with severe dysplasia','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,6,'Esophageal squamous intraepithelial neoplasia (dysplasia), high grade','(C15._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,6,'Vaginal intraepithelial neoplasia, grade III','(C52._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'VAIN III','(C52._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,6,'Vulvar intraepithelial neoplasia, grade III','(C51._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8077',3,5,'VIN III','(C51._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8080',3,4,'Queyrat erythroplasia','(C60._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8081',3,4,'Bowen disease','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8081',3,5,'Intraepidermal squamous cell carcinoma, Bowen type','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8082',4,6,'Schmincke tumor','(C11._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8090',2,4,'Basal cell tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8090',4,5,'Basal cell epithelioma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8090',4,5,'Rodent ulcer','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8090',4,6,'Pigmented basal cell carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8090',4,6,'Basal cell carcinoma with adnexal differentiation','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8091',4,4,'Superficial basal cell carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8091',4,5,'Multifocal superficial basal cell carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8091',4,5,'Multicentric basal cell carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8092',4,4,'Infiltrating basal cell carcinoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8092',4,6,'Infiltrating basal cell carcinoma, non-sclerosing','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8092',4,6,'Infiltrating basal cell carcinoma, sclerosing','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8092',4,5,'Basal cell carcinoma, desmoplastic type','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8092',4,5,'Basal cell carcinoma, morpheic','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8092',4,6,'Basal cell carcinoma, sarcomatoid','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8093',4,4,'Basal cell carcinoma, fibroepithelial','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8094',4,4,'Basosquamous carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8094',4,5,'Mixed basal-squamous cell carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8095',4,4,'Metatypical carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8096',1,4,'Intraepidermal epithelioma of Jadassohn','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8097',4,4,'Basal cell carcinoma, nodular','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8097',4,6,'Basal cell carcinoma, micronodular','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8098',4,4,'Adenoid basal carcinoma','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8100',1,4,'Trichoepithelioma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8100',1,5,'Brooke tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8100',1,5,'Epithelioma adenoides cysticum','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8100',1,6,'Trichoblastoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8100',1,6,'Trichogerminoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8100',4,4,'Trichoblastic carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8100',4,6,'Trichoblastic carcinosarcoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8101',1,4,'Trichofolliculoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8102',1,4,'Trichilemmoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8102',4,4,'Trichilemmocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8102',4,5,'Trichilemmal carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8103',1,4,'Pilar tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8103',2,4,'Proliferating trichilemmal cyst','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8103',2,5,'Proliferating trichilemmal tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8104',1,4,'Pilar sheath acanthoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8104',1,6,'Tumor of follicular infundibulum','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',1,4,'Pilomatricoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',1,5,'Calcifying epithelioma of Malherbe','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',1,6,'Melanocytic matricoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',4,4,'Pilomatrical carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',4,5,'Pilomatrix carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',4,5,'Matrical carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',4,5,'Pilomatricoma, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8110',4,5,'Pilomatrixoma, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8120',1,5,'Papilloma of bladder','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8121',1,4,'Sinonasal papilloma, exophytic','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',1,5,'Schneiderian papilloma, NOS','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',1,5,'Sinonasal papilloma, NOS','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',1,5,'Sinonasal papilloma, fungiform','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',2,4,'Sinonasal papilloma, inverted','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',2,6,'Cylindrical cell papilloma','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',2,6,'Schneiderian papilloma, oncocytic','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',2,6,'Schneiderian papilloma, inverted','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',2,6,'Sinonasal papilloma, oncocytic','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8121',4,4,'Schneiderian carcinoma','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8121',4,6,'Cylindrical cell carcinoma','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8124',4,4,'Cloacogenic carcinoma','(C21.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8130',2,4,'Papillary urothelial neoplasm of low malignant potential','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8130',2,5,'Papillary transitional cell neoplasm of low malignant potential','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8130',3,4,'Papillary urothelial carcinoma, non-invasive','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8130',3,5,'Papillary transitional cell carcinoma, non-invasive','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8130',4,4,'Papillary urothelial carcinoma','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8130',4,5,'Papillary transitional cell carcinoma','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8131',4,4,'Urothelial carcinoma, micropapillary','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8131',4,5,'Transitional cell carcinoma, micropapillary','(C67._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8140',2,5,'Bronchial adenoma, NOS','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',4,6,'Parathyroid carcinoma','(C75.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8140',4,6,'Acinar adenocarcinoma of prostate','(C61.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8142',4,4,'Linitis plastica','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8144',4,4,'Adenocarcinoma, intestinal type','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8144',4,5,'Carcinoma, intestinal type','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8145',4,4,'Carcinoma, diffuse type','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8145',4,5,'Adenocarcinoma, diffuse type','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8147',4,6,'Basal cell carcinoma of prostate','(C61.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',1,6,'Esophageal glandular dysplasia (intraepithelial neoplasia), low grade','(C15._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8148',3,6,'Esophageal glandular dysplasia (intraepithelial neoplasia), high grade','(C15._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,5,'Esophageal intraepithelial neoplasia, high grade','(C15._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,6,'Prostatic intraepithelial neoplasia, grade III','(C61.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,5,'PIN III','(C61.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8148',3,5,'Prostatic intraepithelial neoplasia, high grade','(C61.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',1,4,'Pancreatic neuroendocrine microadenoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',1,5,'Pancreatic endocrine tumor, benign','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',1,5,'Islet cell tumor, benign','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',1,6,'Pancreatic microadenoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,4,'Pancreatic neuroendocrine tumor, nonfunctioning','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8150',4,5,'Pancreatic endocrine tumor, nonfunctioning','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,5,'Pancreatic endocrine tumor, NOS','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,6,'Islet cell adenoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,6,'Islet cell adenomatosis','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,6,'Nesidioblastoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,6,'Islet cell tumor, NOS','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,6,'Islet cell adenocarcinoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8150',4,6,'Islet cell carcinoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8151',4,4,'Insulinoma, NOS','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8151',4,5,'Beta cell adenoma','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8151',4,5,'Beta cell tumor','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8152',4,6,'Pancreatic peptide and pancreatic peptide-like peptide within terminal tyrosine amide producing tumor','(C25.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,6,'Mixed pancreatic endocrine and exocrine tumor, malignant','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,5,'Mixed islet cell and exocrine adenocarcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,6,'Mixed acinar-endocrine carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,5,'Mixed acinar-neuroendocrine carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,6,'Mixed acinar-endocrine-ductal carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,6,'Mixed ductal-endocrine carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,5,'Mixed ductal-neuroendocrine carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8154',4,6,'Mixed endocrine and exocrine adenocarcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8160',1,4,'Bile duct adenoma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8160',1,5,'Cholangioma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8160',4,4,'Cholangiocarcinoma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8160',4,5,'Bile duct adenocarcinoma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8160',4,5,'Bile duct carcinoma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8161',1,4,'Bile duct cystadenoma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8161',4,4,'Bile duct cystadenocarcinoma','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8162',4,4,'Perihilar cholangiocarcinoma','(C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',3,4,'Papillary neoplasm, pancreatobiliary type, with high grade intraepithelial neoplasia','(C24.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',3,5,'Non-invasive pancreatobiliary papillary neoplasm with high grade dysplasia','(C24.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8163',3,5,'Non-invasive pancreatobiliary papillary neoplasm with high grade intraepithelial neoplasia','(C24.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',4,4,'Pancreatobiliary type carcinoma','(C24.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8163',4,5,'Adenocarcinoma, pancreatobiliary type','(C24.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',1,4,'Liver cell adenoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',1,5,'Hepatocellular adenoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',1,5,'Hepatoma, benign','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',4,4,'Hepatocellular carcinoma, NOS','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',4,5,'Hepatoma, NOS','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',4,5,'Hepatocarcinoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8170',4,5,'Hepatoma, malignant','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8170',4,5,'Liver cell carcinoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8171',4,4,'Hepatocellular carcinoma, fibrolamellar','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8172',4,4,'Hepatocellular carcinoma, scirrhous','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8172',4,5,'Sclerosing hepatic carcinoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8173',4,4,'Hepatocellular carcinoma, spindle cell variant','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8173',4,5,'Hepatocellular carcinoma, sarcomatoid','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8174',4,4,'Hepatocellular carcinoma, clear cell type','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8175',4,4,'Hepatocellular carcinoma, pleomorphic type','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8180',4,4,'Combined hepatocellular carcinoma and cholangiocarcinoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8180',4,5,'Hepatocholangiocarcinoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8180',4,5,'Mixed hepatocellular and bile duct carcinoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',1,4,'Eccrine dermal cylindroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',1,6,'Cylindroma of skin','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',1,6,'Cylindroma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',1,6,'Turban tumor','(C44.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',4,6,'Bronchial adenoma, cylindroid','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8200',4,6,'Thymic carcinoma with adenoid cystic carcinoma-like features','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8201',3,4,'Cribriform carcinoma in situ','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8201',3,5,'Ductal carcinoma in situ, cribriform type','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8201',4,5,'Ductal carcinoma, cribriform type','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8201',4,6,'Cribriform comedo type carcinoma','(C18._, C19.9, C20.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8201',4,5,'Adenocarcinoma, cribriform comedo type','(C18._, C19.9, C20.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8204',1,4,'Lactating adenoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8213',1,4,'Serrated adenoma, NOS','(C18._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8213',1,6,'Mixed adenomatous and hyperplastic polyp','(C18._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8214',4,4,'Parietal cell carcinoma','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8214',4,5,'Parietal cell adenocarcinoma','(C16._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8215',4,4,'Adenocarcinoma of anal glands','(C21.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8215',4,5,'Adenocarcinoma of anal ducts','(C21.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8220',1,4,'Adenomatous polyposis coli','(C18._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8220',1,5,'Familial polyposis coli','(C18._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8220',4,4,'Adenocarcinoma in adenomatous polyposis coli','(C18._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8230',3,4,'Ductal carcinoma in situ, solid type','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8240',4,6,'Bronchial adenoma, carcinoid','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8247',4,4,'Merkel cell carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8247',4,5,'Merkel cell tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8247',4,5,'Primary cutaneous neuroendocrine carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',2,4,'Pulmonary adenomatosis','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',3,4,'Adenocarcinoma in situ of lung, non-mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',4,4,'Lepidic adenocarcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8250',4,5,'Bronchiolo-alveolar adenocarcinoma, NOS','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',4,5,'Bronchiolo-alveolar carcinoma, NOS','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',4,5,'Alveolar cell carcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',4,5,'Bronchiolar adenocarcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8250',4,5,'Bronchiolar carcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8251',1,4,'Alveolar adenoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8251',4,4,'Alveolar adenocarcinoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8252',4,4,'Bronchiolo-alveolar carcinoma, non-mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8252',4,5,'Bronchiolo-alveolar carcinoma, Clara cell','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8252',4,5,'Bronchiolo-alveolar carcinoma, type II pneumocyte','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8253',3,4,'Adenocarcinoma in situ of lung, mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8253',4,4,'Adenocarcinoma of lung, mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8253',4,5,'Bronchiolo-alveolar carcinoma, mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8253',4,5,'Bronchiolo-alveolar carcinoma, goblet cell type','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8254',4,4,'Adenocarcinoma of lung, mixed mucinous and non-mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8254',4,5,'Bronchiolo-alveolar carcinoma, mixed mucinous and non-mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8254',4,5,'Bronchiolo-alveolar carcinoma, Clara cell and goblet cell type','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8254',4,5,'Bronchiolo-alveolar carcinoma, indeterminate type','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8254',4,5,'Bronchiolo-alveolar carcinoma, type II pneumocyte and goblet cell type','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8256',4,4,'Minimally invasive adenocarcinoma, non-mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8257',4,4,'Minimally invasive adenocarcinoma, mucinous','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8260',4,6,'Papillary carcinoma of thyroid','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8260',4,6,'Papillary renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8264',1,6,'Biliary papillomatosis','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8265',4,4,'Micropapillary carcinoma, NOS','(C18._, C19.9, C20.9, C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8265',4,6,'Micropapillary adenocarcinoma','(C18._, C19.9, C20.9, C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8270',1,4,'Chromophobe adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8270',4,4,'Chromophobe carcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8270',4,5,'Chromophobe adenocarcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8271',1,4,'Lactotroph adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8271',1,5,'Prolactinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,4,'Pituitary adenoma, NOS','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Corticotroph adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Null cell adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Plurihormonal adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Gonodotroph adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Somatotroph adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',1,6,'Thyrotroph adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8272',4,4,'Pituitary carcinoma, NOS','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8273',4,4,'Pituitary blastoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8280',1,4,'Acidophil adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8280',1,5,'Eosinophil adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8280',4,4,'Acidophil carcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8280',4,5,'Acidophil adenocarcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8280',4,5,'Eosinophil adenocarcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8280',4,5,'Eosinophil carcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8281',1,4,'Mixed acidophil-basophil adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8281',4,4,'Mixed acidophil-basophil carcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',1,6,'Follicular adenoma, oxyphilic cell','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',1,6,'Hurthle cell adenoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8290',1,6,'Hurthle cell tumor','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',1,6,'Spindle cell oncocytoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',4,6,'Hurthle cell carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',4,6,'Hurthle cell adenocarcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8290',4,6,'Follicular carcinoma, oxyphilic cell','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8300',1,4,'Basophil adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8300',1,5,'Mucoid cell adenoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8300',4,4,'Basophil carcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8300',4,5,'Basophil adenocarcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8300',4,5,'Mucoid cell adenocarcinoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8311',4,4,'Hereditary leiomyomatosis and renal cell carcinoma (HLRCC) syndrome-associated renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8311',4,6,'MiT family translocation carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8311',4,6,'Succinate dehydrogenase deficient renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8312',4,4,'Renal cell carcinoma, NOS','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8312',4,5,'Renal cell adenocarcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8312',4,6,'Renal cell carcinoma, unclassified','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8312',4,5,'Grawitz tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8312',4,5,'Hypernephroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',1,4,'Clear cell adenofibroma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',1,5,'Clear cell cystadenofibroma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8313',2,4,'Clear cell borderline tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',2,5,'Clear cell tumor, atypical proliferative','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',2,5,'Clear cell cystic tumor of borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',2,6,'Clear cell adenofibroma of borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',2,5,'Clear cell cystadenofibroma of borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',4,4,'Clear cell adenocarcinofibroma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8313',4,5,'Clear cell cystadenocarcinofibroma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8314',4,4,'Lipid-rich carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8315',4,5,'Glycogen-rich clear cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8316',4,4,'Cyst-associated renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8316',4,6,'Acquired cystic disease-associated renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8316',4,6,'Tubulocystic renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8317',4,4,'Renal cell carcinoma, chromophobe type','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8317',4,5,'Chromophobe cell renal carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8318',4,4,'Renal cell carcinoma, sarcomatoid','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8318',4,5,'Renal cell carcinoma, spindle cell','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8319',4,4,'Collecting duct carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8319',4,5,'Bellini duct carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8319',4,5,'Renal carcinoma, collecting duct type','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8321',1,4,'Chief cell adenoma','(C75.0)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8322',1,4,'Water-clear cell adenoma','(C75.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8322',4,4,'Water-clear cell adenocarcinoma','(C75.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8322',4,5,'Water-clear cell carcinoma','(C75.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8323',2,4,'Clear cell papillary renal cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8325',1,4,'Metanephric adenoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8330',1,4,'Follicular adenoma, NOS','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8330',2,4,'Atypical follicular adenoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8330',4,4,'Follicular carcinoma, NOS','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8330',4,5,'Follicular adenocarcinoma, NOS','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8331',4,4,'Follicular adenocarcinoma, well differentiated','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8331',4,5,'Follicular carcinoma, well differentiated','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8332',4,4,'Follicular adenocarcinoma, trabecular','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8332',4,5,'Follicular carcinoma, trabecular','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8332',4,6,'Follicular adenocarcinoma, moderately differentiated','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8332',4,5,'Follicular carcinoma, moderately differentiated','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8333',1,4,'Microfollicular adenoma, NOS','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8333',1,5,'Fetal adenoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8334',1,4,'Macrofollicular adenoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8334',1,5,'Colloid adenoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8335',2,4,'Follicular tumor of uncertain malignant potential','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8335',2,5,'Follicular carcinoma, encapsulated, NOS','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8335',4,4,'Follicular carcinoma, minimally invasive','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8336',2,4,'Hyalinizing trabecular tumor','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8336',2,5,'Hyalinizing trabecular adenoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8337',4,4,'Poorly differentiated thyroid carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8337',4,5,'Insular carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8339',4,4,'Follicular carcinoma, encapsulated, angioinvasive','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8340',4,4,'Papillary carcinoma, follicular variant','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8340',4,5,'Papillary adenocarcinoma, follicular variant','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8340',4,6,'Papillary and follicular adenocarcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8340',4,6,'Papillary and follicular carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8341',4,4,'Papillary microcarcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8342',4,4,'Papillary carcinoma, oncocytic variant','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8342',4,5,'Papillary carcinoma, oxyphilic cell','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8343',4,4,'Papillary carcinoma, encapsulated, of thyroid','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8344',4,4,'Papillary carcinoma, columnar cell','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8344',4,5,'Papillary carcinoma, tall cell','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8345',4,4,'Medullary thyroid carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8345',4,5,'C cell carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8345',4,5,'Parafollicular cell carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8345',4,6,'Medullary carcinoma with amyloid stroma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8346',4,4,'Mixed medullary-follicular carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8347',4,4,'Mixed medullary-papillary carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8348',2,4,'Well differentiated tumor of uncertain malignant potential','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8349',2,4,'Non-invasive follicular thyroid neoplasm with papillary-like nuclear features (NIFTP)','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8350',4,4,'Nonencapsulated sclerosing carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8350',4,5,'Nonencapsulated sclerosing adenocarcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8350',4,5,'Nonencapsulated sclerosing tumor','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8350',4,6,'Papillary carcinoma, diffuse sclerosing','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8361',1,4,'Juxtaglomerular tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8361',1,5,'Juxtaglomerular cell tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8361',1,5,'Reninoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8370',1,4,'Adrenal cortical adenoma, NOS','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8370',1,5,'Adrenal cortical tumor, NOS','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8370',1,5,'Adrenal cortical tumor, benign','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8370',4,4,'Adrenal cortical carcinoma','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8370',4,5,'Adrenal cortical adenocarcinoma','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8370',4,5,'Adrenal cortical tumor, malignant','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8371',1,4,'Adrenal cortical adenoma, compact cell','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8372',1,4,'Adrenal cortical adenoma, pigmented','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8372',1,5,'Black adenoma','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8372',1,5,'Pigmented adenoma','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8373',1,4,'Adrenal cortical adenoma, clear cell','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8374',1,4,'Adrenal cortical adenoma, glomerulosa cell','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8375',1,4,'Adrenal cortical adenoma, mixed cell','(C74.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',3,4,'Endometrioid intraepithelial neoplasia','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8380',3,5,'Atypical hyperplasia of endometrium','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8390',1,4,'Skin appendage adenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8390',1,5,'Adnexal tumor, benign','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8390',1,5,'Skin appendage tumor, benign','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8390',4,4,'Adnexal adenocarcinoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8390',4,5,'Skin appendage carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8390',4,5,'Adnexal carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8391',1,4,'Follicular fibroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8391',1,5,'Fibrofolliculoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8391',1,5,'Perifollicular fibroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8391',1,5,'Trichodiscoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8391',1,6,'Spindle cell predominant trichodiscoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8392',1,4,'Syringofibroadenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8400',1,4,'Sweat gland adenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8400',1,5,'Syringadenoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8400',1,5,'Sweat gland tumor, benign','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8400',2,4,'Sweat gland tumor, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8400',4,4,'Sweat gland adenocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8400',4,5,'Sweat gland carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8400',4,5,'Sweat gland tumor, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8402',1,4,'Hidradenoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8402',1,5,'Nodular hidradenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8402',1,6,'Clear cell hidradenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8402',1,6,'Eccrine acrospiroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8402',4,4,'Hidradenocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8402',4,5,'Nodular hidradenoma, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8403',1,4,'Spiradenoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8403',1,5,'Eccrine spiradenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8403',4,4,'Malignant eccrine spiradenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8403',4,6,'Malignant neoplasm arising from pre-existing spiradenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8403',4,6,'Malignant neoplasm arising from pre-existing cylindroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8403',4,6,'Malignant neoplasm arising from pre-existing spiradenocylindroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8404',1,4,'Hidrocystoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8404',1,5,'Hidrocystadenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8404',1,5,'Eccrine cystadenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8406',1,4,'Syringocystadenoma papilliferum','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8406',1,5,'Papillary syringadenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8406',1,5,'Papillary syringocystadenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8407',1,4,'Syringoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8407',1,6,'Syringomatous tumor of nipple','(C50.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8407',1,5,'Syringomatous adenoma of nipple','(C50.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8407',1,5,'Infiltrating syringomatous adenoma of nipple','(C50.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8407',4,4,'Microcystic adnexal carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8407',4,5,'Sclerosing sweat duct carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8407',4,5,'Syringomatous carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8408',1,4,'Eccrine papillary adenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8408',4,4,'Digital papillary adenocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8408',4,5,'Aggressive digital papillary adenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8408',4,5,'Eccrine papillary adenocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8409',1,4,'Poroma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8409',4,4,'Porocarcinoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8409',4,5,'Eccrine poroma, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8410',1,4,'Sebaceoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8410',1,6,'Sebaceous adenoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8410',1,6,'Sebaceous epithelioma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8410',4,4,'Sebaceous carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8410',4,5,'Sebaceous adenocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8413',4,4,'Eccrine adenocarcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8420',1,4,'Ceruminous adenoma','(C44.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8420',4,4,'Ceruminous adenocarcinoma','(C44.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8420',4,5,'Ceruminous carcinoma','(C44.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',1,5,'Papillary serous cystadenoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',3,6,'Serous tubal intraepithelial carcinoma (STIC)','(C57.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',3,6,'Serous endometrial intraepithelial carcinoma','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8441',4,5,'Serous adenocarcinoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',4,5,'Serous papillary adenocarcinoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',4,5,'Papillary serous cystadenocarcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',4,5,'Papillary serous adenocarcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8441',4,5,'Serous surface papillary carcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,4,'Serous borderline tumor, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Serous tumor, atypical proliferative','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Serous cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Serous tumor, NOS, of low malignant potential','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Serous papillary cystic tumor of borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8442',2,5,'Atypical proliferative papillary serous tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Papillary serous cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Papillary serous tumor of low malignant potential','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8442',2,5,'Serous surface papillary tumor of borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8443',1,4,'Clear cell cystadenoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8450',1,4,'Papillary cystadenoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8450',4,4,'Papillary cystadenocarcinoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8451',2,4,'Papillary cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8452',2,4,'Solid pseudopapillary tumor of ovary','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8452',2,5,'Papillary cystic tumor','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8452',2,5,'Solid and cystic tumor','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8452',2,5,'Solid and papillary epithelial neoplasm','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8452',4,4,'Solid pseudopapillary neoplasm of pancreas','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',1,4,'Intraductal papillary mucinous adenoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',1,6,'Intraductal papillary mucinous tumor with intermediate dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',1,6,'Intraductal papillary mucinous tumor with low grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',1,5,'Intraductal papillary mucinous neoplasm with low grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',1,6,'Intraductal papillary mucinous tumor with moderate dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',1,5,'Intraductal papillary mucinous neoplasm with moderate dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',3,4,'Intraductal papillary mucinous neoplasm with high grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8453',3,6,'Intraductal papillary mucinous carcinoma, non-invasive','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',4,4,'Intraductal papillary mucinous neoplasm with an associated invasive carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8453',4,6,'Intraductal papillary mucinous carcinoma, invasive','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8454',1,4,'Cystic tumor of atrio-ventricular node','(C38.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8460',3,4,'Serous borderline tumor, micropapillary variant','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8460',3,5,'Serous carcinoma, non-invasive, low grade','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8460',4,4,'Low grade serous carcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8460',4,6,'Micropapillary serous carcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8461',1,4,'Serous surface papilloma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8461',4,4,'High grade serous carcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8470',1,4,'Mucinous cystadenoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,5,'Papillary mucinous cystadenoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,5,'Papillary pseudomucinous cystadenoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,5,'Pseudomucinous cystadenoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,5,'Mucinous cystoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,6,'Mucinous cystic neoplasm with intermediate grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,6,'Mucinous cystic neoplasm with intermediate grade intraepithelial neoplasia','(C22._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,6,'Mucinous cystic neoplasm with low grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,6,'Mucinous cystic neoplasm with low grade intraepithelial neoplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,6,'Mucinous cystic tumor with intermediate dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8470',1,6,'Mucinous cystic tumor with low grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',1,6,'Mucinous cystic tumor with moderate dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',3,4,'Mucinous cystic neoplasm with high grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',3,6,'Mucinous cystadenocarcinoma, non-invasive','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',3,6,'Mucinous cystic tumor with high grade dysplasia','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',3,5,'Mucinous cystic neoplasm with high grade intraepithelial neoplasia','(C22._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',4,4,'Mucinous cystadenocarcinoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',4,5,'Pseudomucinous cystadenocarcinoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',4,5,'Pseudomucinous adenocarcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',4,6,'Mucinous cystic tumor with an associated invasive carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8470',4,5,'Mucinous cystic neoplasm with an associated invasive carcinoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',4,5,'Papillary mucinous cystadenocarcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8470',4,5,'Papillary pseudomucinous cystadenocarcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,4,'Mucinous cystic tumor of borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Mucinous borderline tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Mucinous tumor, NOS, of low malignant potential','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Atypical proliferative mucinous tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Mucinous cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Pseudomucinous cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Papillary mucinous cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8472',2,5,'Papillary pseudomucinous cystadenoma, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8472',2,5,'Papillary mucinous tumor of low malignant potential','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8474',4,4,'Seromucinous carcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',2,4,'Low grade appendiceal mucinous neoplasm','(C18.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,6,'Pseudomyxoma peritonei with unknown primary site','(C80.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8480',4,6,'Mucinous tubular and spindle cell carcinoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8482',4,4,'Mucinous carcinoma, gastric type','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8482',4,5,'Mucinous adenocarcinoma, endocervical type','(C53._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,6,'Ductal carcinoma in situ, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,5,'DCIS, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8500',3,5,'DIN 3','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,5,'Ductal intraepithelial neoplasia 3','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',3,6,'Cystic hypersecretory carcinoma, intraductal','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,4,'Infiltrating duct carcinoma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,5,'Invasive breast carcinoma of no special type','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,5,'Infiltrating duct adenocarcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,6,'Basal-like carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8500',4,6,'Carcinoma of male breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8501',3,4,'Comedocarcinoma, noninfiltrating','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8501',3,5,'Ductal carcinoma in situ, comedo type','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8501',3,5,'DCIS, comedo type','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8502',4,6,'Juvenile carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,6,'Intracystic papillary neoplasm with low grade intraepithelial neoplasia','(C23.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,5,'Intracystic papillary neoplasm with intermediate grade intraepithelial neoplasia','(C23.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,5,'Intraglandular papillary neoplasm with low grade intraepithelial neoplasia','(C22.1, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,5,'Intraductal papillary neoplasm with intermediate grade neoplasia','(C22._, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,6,'Intraductal papillary neoplasm with low grade intraepithelial neoplasia','(C22._, C24.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,6,'Intraductal papilloma with atypical ductal hyperplasia','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,4,'Noninfiltrating intraductal papillary adenocarcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Intraductal papillary adenocarcinoma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8503',3,5,'Intraductal papillary carcinoma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'DCIS, papillary','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Ductal carcinoma in situ, papillary','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Noninfiltrating intraductal papillary carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,6,'Intraductal papilloma with DCIS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Intracystic papillary neoplasm with high grade intraepithelial neoplasia','(C23.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Intracystic papillary tumor with high grade dysplasia','(C23.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',3,5,'Intracystic papillary tumor with high grade intraepithelial neoplasia','(C23.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',4,4,'Intraductal papillary adenocarcinoma with invasion','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',4,6,'Papillary carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8503',4,5,'Intracystic papillary neoplasm with associated invasive carcinoma','(C23.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8506',1,4,'Adenoma of nipple','(C50.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8506',1,5,'Subareolar duct papillomatosis','(C50.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8507',3,4,'Intraductal micropapillary carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8507',3,5,'Ductal carcinoma in situ, micropapillary','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8507',3,6,'Intraductal carcinoma, clinging, high grade','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8507',4,4,'Invasive micropapillary carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8507',4,5,'Micropapillary carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8508',4,4,'Cystic hypersecretory carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8509',3,4,'Solid papillary carcinoma in situ','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8509',3,6,'Endocrine mucin-producing sweat gland carcinoma in situ','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8503',1,5,'Duct adenoma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8509',4,4,'Solid papillary carcinoma with invasion','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8509',4,6,'Endocrine mucin-producing sweat gland carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8513',4,4,'Atypical medullary carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8519',3,4,'Lobular carcinoma in situ, pleomorphic','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8519',3,5,'LCIS, pleomorphic','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',3,4,'Lobular carcinoma in situ, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',3,5,'Lobular carcinoma, noninfiltrating','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',3,5,'Lobular carcinoma in situ, classic','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8520',3,6,'Intraductal papilloma with lobular carcinoma in situ','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',4,4,'Lobular carcinoma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',4,5,'Infiltrating lobular carcinoma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',4,5,'Lobular adenocarcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8520',4,6,'Lobular carcinoma, pleomorphic','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8522',3,4,'Intraductal carcinoma and lobular carcinoma in situ','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8522',4,4,'Infiltrating duct and lobular carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8522',4,5,'Lobular and ductal carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8522',4,6,'Intraductal and lobular carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8522',4,6,'Infiltrating duct and lobular carcinoma in situ','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8522',4,6,'Infiltrating lobular carcinoma and ductal carcinoma in situ','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8523',4,4,'Infiltrating duct mixed with other types of carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8523',4,6,'Infiltrating duct and colloid carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8523',4,6,'Infiltrating duct and cribriform carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8523',4,6,'Infiltrating duct and mucinous carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8523',4,6,'Infiltrating duct and tubular carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8524',4,4,'Infiltrating lobular mixed with other types of carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8530',4,4,'Inflammatory carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8530',4,5,'Inflammatory adenocarcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8540',4,4,'Paget disease, mammary','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8540',4,5,'Paget disease of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8540',4,5,'Paget disease of nipple','(C50.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8541',4,4,'Paget disease and infiltrating duct carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8543',4,4,'Paget disease and intraductal carcinoma of breast','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8551',4,6,'Acinar adenocarcinoma of lung','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8560',4,6,'Squamoid eccrine ductal carcinoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8561',1,4,'Adenolymphoma','(C07._, C08._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8561',1,5,'Papillary cystadenoma lymphomatosum','(C07._, C08._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8561',1,5,'Warthin tumor','(C07._, C08._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8580',1,4,'Microscopic thymoma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8580',1,6,'Thymoma, benign','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8580',2,4,'Micronodular thymoma with lymphoid stroma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8580',4,4,'Thymoma, NOS','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8580',4,6,'Intrapulmonary thymoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8580',4,6,'Sclerosing thymoma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8580',4,6,'Metaplastic thymoma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8581',4,4,'Thymoma, type A','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8581',4,5,'Thymoma, medullary','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8581',4,5,'Thymoma, spindle cell','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8582',4,4,'Thymoma, type AB','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8582',4,5,'Thymoma, mixed type','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8583',4,4,'Thymoma, type B1','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8583',4,5,'Thymoma, lymphocyte-rich','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8583',4,5,'Thymoma, lymphocytic','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8583',4,5,'Thymoma, organoid','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8583',4,5,'Thymoma, predominantly cortical','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8584',4,4,'Thymoma, type B2','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8584',4,5,'Thymoma, cortical','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8585',4,4,'Thymoma, type B3','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8585',4,5,'Thymoma, atypical','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8585',4,5,'Thymoma, epithelial','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8585',4,5,'Well differentiated thymic carcinoma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8586',4,4,'Thymic carcinoma, NOS','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8586',4,5,'Thymoma, type C','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8589',4,4,'Intrathyroid thymic carcinoma','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',2,5,'Ovarian stromal tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8590',2,5,'Testicular stromal tumor','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8593',2,4,'Stromal tumor with minor sex cord elements','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8600',1,4,'Thecoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8600',1,5,'Theca cell tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8600',4,4,'Thecoma, malignant','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8601',1,4,'Thecoma, luteinized','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8602',1,4,'Sclerosing stromal tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8610',1,4,'Luteoma, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8610',1,5,'Luteinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8620',2,4,'Adult granulosa cell tumor of testis','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8588',4,5,'SETTLE',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8620',2,5,'Granulosa cell tumor of testis, NOS','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8620',4,4,'Adult granulosa cell tumor of ovary','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8620',4,6,'Granulosa cell tumor, adult type','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8620',4,6,'Granulosa cell carcinoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8620',4,6,'Granulosa cell tumor, sarcomatoid','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8621',2,4,'Granulosa cell-theca cell tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8621',2,5,'Theca cell-granulosa cell tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8622',1,4,'Granulosa cell tumor of testis, juvenile','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8623',2,4,'Sex cord tumor with annular tubules','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8632',2,4,'Gynandroblastoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8640',4,4,'Sertoli cell carcinoma','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8641',1,5,'Folliculome lipidique','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8641',1,5,'Lipid-rich Sertoli cell tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8641',1,5,'Tubular androblastoma with lipid storage','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8650',1,4,'Leydig cell tumor of ovary, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8650',2,4,'Leydig cell tumor of testis, NOS','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8650',4,4,'Leydig cell tumor, malignant','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8660',1,4,'Hilus cell tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8660',1,5,'Hilar cell tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8670',1,4,'Lipid cell tumor of ovary','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8670',1,5,'Lipoid cell tumor of ovary','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8670',1,6,'Masculinovoblastoma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8680',4,4,'Paraganglioma, NOS','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8683',1,4,'Gangliocytic paraganglioma','(C17.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8690',4,4,'Middle ear paraganglioma','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8690',4,5,'Glomus jugulare tumor, NOS','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8690',4,5,'Jugular paraganglioma','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8690',4,5,'Jugulotympanic paraganglioma','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8691',4,4,'Aortic body tumor','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8691',4,5,'Aortic body paraganglioma','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8691',4,5,'Aorticopulmonary paraganglioma','(C75.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8692',4,4,'Carotid body paraganglioma','(C75.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8692',4,5,'Carotid body tumor','(C75.4)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8700',4,4,'Pheochromocytoma, NOS','(C74.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8700',4,5,'Adrenal medullary paraganglioma','(C74.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8700',4,6,'Composite pheochromocytoma','(C74.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8700',4,5,'Pheochromoblastoma','(C74.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,4,'Pigmented nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,5,'Nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,5,'Melanocytic nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,6,'Hairy nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,6,'Nevus spilus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,6,'Meyerson nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8720',1,6,'Deep penetrating nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,6,'Combined nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',1,6,'Conjunctival nevus','(C69.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',4,6,'Nevoid melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8720',4,6,'Melanoma, meningeal','(C70._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8721',4,4,'Nodular melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8722',1,4,'Balloon cell nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8722',4,4,'Balloon cell melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8723',1,4,'Halo nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8723',1,5,'Regressing nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8723',4,4,'Malignant melanoma, regressing','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8725',1,4,'Neuronevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8726',1,4,'Magnocellular nevus','(C69.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8726',1,5,'Melanocytoma, eyeball','(C69.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8727',1,4,'Dysplastic nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8728',1,4,'Meningeal melanocytosis','(C70.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8728',1,6,'Diffuse melanocytosis','(C70.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8728',2,4,'Meningeal melanocytoma','(C70.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8728',4,4,'Meningeal melanomatosis','(C70.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8730',1,4,'Nonpigmented nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8730',1,5,'Achromic nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8730',4,4,'Amelanotic melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8740',1,4,'Junctional nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8740',1,5,'Intraepidermal nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8740',1,5,'Junction nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8740',4,4,'Malignant melanoma in junctional nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8741',3,4,'Precancerous melanosis, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8741',4,4,'Malignant melanoma in precancerous melanosis','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8742',1,4,'Lentiginous melanocytic nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8742',1,6,'Simple lentigo','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8742',1,5,'Lentigo simplex','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8742',3,4,'Lentigo maligna','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8742',3,5,'Hutchinson melanotic freckle, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8742',4,4,'Lentigo maligna melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8742',4,5,'Malignant melanoma in Hutchinson melanotic freckle','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8743',4,4,'Low cumulative sun damage melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8743',4,6,'Superficial spreading melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8744',1,4,'Acral nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8744',4,4,'Acral melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8744',4,5,'Acral lentiginous melanoma, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8745',4,4,'Desmoplastic melanoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8745',4,6,'Desmoplastic melanoma, amelanotic','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8745',4,6,'Neurotropic melanoma, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8750',1,4,'Dermal nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8750',1,5,'Intradermal nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8760',1,4,'Compound nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8760',1,5,'Dermal and epidermal nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8761',1,4,'Congenital melanocytic nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8761',2,4,'Giant pigmented nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8761',2,6,'Intermediate and giant congenital nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8761',4,4,'Malignant melanoma arising in giant congenital nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8761',4,5,'Malignant melanoma in giant pigmented nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8761',4,5,'Malignant melanoma in congenital melanocytic nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8762',2,4,'Proliferative dermal lesion in congenital nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8762',2,5,'Proliferative nodule in congenital melanocytic nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',1,4,'Epithelioid and spindle cell nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',1,5,'Juvenile melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',1,5,'Juvenile nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',1,5,'Spitz nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',1,6,'Spitz nevus, atypical','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8770',1,6,'Pigmented spindle cell nevus of Reed','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',1,5,'Pigmented spindle cell Spitz nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',4,4,'Malignant Spitz tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',4,5,'Spitz melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8770',4,5,'Spitzoid melanoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8771',1,4,'Epithelioid cell nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8772',1,4,'Spindle cell nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8773',4,4,'Spindle cell melanoma, type A','(C69._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8774',4,4,'Spindle cell melanoma, type B','(C69._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8780',1,4,'Blue nevus, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8780',1,5,'Jadassohn blue nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8780',2,4,'Pigmented epithelioid melanocytoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8780',2,5,'Blue nevus, epithelioid','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8780',4,4,'Blue nevus, malignant','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8780',4,5,'Melanoma arising in blue nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8790',1,4,'Cellular blue nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8802',4,6,'Pleomorphic dermal sarcoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',1,6,'Plaque-like CD34 positive dermal fibroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8810',2,4,'Cellular fibroma','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8812',1,4,'Periosteal fibroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8812',4,4,'Periosteal fibrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8812',4,6,'Periosteal sarcoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8815',2,6,'Hemangiopericytic meningioma','(C70._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8822',2,5,'Mesenteric fibromatosis','(C48.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8822',2,5,'Retroperitoneal fibromatosis','(C48.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8827',2,4,'Myofibroblastic tumor, peribronchial','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8827',2,5,'Congenital peribronchial myofibroblastic tumor','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8830',4,5,'Undifferentiated high grade pleomorphic sarcoma of bone','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',1,4,'Dermatofibroma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',1,5,'Cutaneous histiocytoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8832',1,5,'Dermatofibroma lenticulare','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',1,5,'Sclerosing hemangioma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',1,5,'Subepidermal nodular fibrosis','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',1,6,'Sclerosing pneumocytoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',1,6,'Pleomorphic fibroma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',2,4,'Dermatofibrosarcoma protuberans, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',2,5,'Dermatofibrosarcoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',4,4,'Dermatofibrosarcoma protuberans, fibrosarcomatous','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8832',4,5,'Dermatofibrosarcoma, sarcomatous','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8833',2,4,'Pigmented dermatofibrosarcoma protuberans','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8833',2,5,'Bednar tumor','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8842',4,6,'Pulmonary myxoid sarcoma with EWSR1-CREB1 translocation','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8850',1,6,'Thymolipoma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8890',1,5,'Fibroid uterus','(C55.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8897',2,6,'Leiomyosarcoma, cutaneous','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8905',1,4,'Genital rhabdomyoma','(C51._, C52.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8930',1,4,'Endometrial stromal nodule','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8930',4,4,'Endometrial stromal sarcoma, NOS','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8930',4,5,'Endometrial sarcoma, NOS','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8930',4,6,'Endometrial stromal sarcoma, high grade','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8931',4,4,'Endometrial stromal sarcoma, low grade','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8931',4,5,'Endolymphatic stromal myosis','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8931',4,5,'Endometrial stromatosis','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8931',4,5,'Stromal endometriosis','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8931',4,5,'Stromal myosis, NOS','(C54.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8935',2,6,'Metanephric stromal tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',1,5,'Mixed tumor, salivary gland type, NOS','(C07._, C08._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',1,6,'Chondroid syringoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',4,5,'Mixed tumor, salivary gland type, malignant','(C07._, C08._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8940',4,6,'Malignant chondroid syringoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8941',4,4,'Carcinoma ex pleomorphic adenoma','(C07._, C08._) ',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8941',4,5,'Carcinoma in pleomorphic adenoma','(C07._, C08._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8950',4,4,'Mullerian mixed tumor','(C54._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',1,4,'Benign cystic nephroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',1,6,'Mixed epithelial and stromal tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',1,6,'Pediatric cystic nephroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',1,6,'Adult cystic nephroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',2,4,'Cystic partially differentiated nephroblastoma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',4,4,'Malignant cystic nephroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8959',4,5,'Malignant multilocular cystic nephroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8960',4,4,'Nephroblastoma, NOS','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8960',4,5,'Nephroma, NOS','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8960',4,5,'Wilms tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8964',4,4,'Clear cell sarcoma of kidney','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8966',1,4,'Renomedullary interstitial cell tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8966',1,5,'Renomedullary fibroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8966',1,5,'Medullary fibroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8967',1,4,'Ossifying renal tumor','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8970',4,4,'Hepatoblastoma, NOS','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8970',4,5,'Embryonal hepatoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8970',4,6,'Hepatoblastoma, epithelioid','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8970',4,6,'Hepatoblastoma, mixed epithelial-mesenchymal','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8971',4,4,'Pancreatoblastoma','(C25._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8972',4,4,'Pulmonary blastoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8972',4,5,'Pneumoblastoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8975',2,4,'Calcifying nested stromal-epithelial tumor','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8983',1,4,'Adenomyoepithelioma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8983',1,6,'Adenomyoepithelioma, benign','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8983',4,4,'Adenomyoepithelioma with carcinoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('8983',4,5,'Malignant adenomyoepithelioma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('8992',1,4,'Pulmonary hamartoma','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9000',1,4,'Brenner tumor, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9000',2,4,'Brenner tumor, borderline malignancy','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9000',2,5,'Borderline Brenner tumor','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9000',2,5,'Brenner tumor, atypical proliferative','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9000',2,5,'Brenner tumor, proliferating','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9000',4,4,'Brenner tumor, malignant','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9010',1,4,'Fibroadenoma, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9011',1,4,'Intracanalicular fibroadenoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9012',1,4,'Pericanalicular fibroadenoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9013',1,6,'Metanephric adenofibroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9013',1,5,'Nephrogenic adenofibroma','(C64.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9016',1,4,'Giant fibroadenoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',1,4,'Phyllodes tumor, benign','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',1,5,'Cystosarcoma phyllodes, benign','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',2,4,'Phyllodes tumor, borderline','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',2,5,'Cystosarcoma phyllodes, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',2,5,'Phyllodes tumor, NOS','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',4,4,'Phyllodes tumor, malignant','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9020',4,5,'Cystosarcoma phyllodes, malignant','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9020',4,6,'Periductal stromal tumor, low grade','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9030',1,4,'Juvenile fibroadenoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9044',4,6,'Malignant melanoma of soft parts','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9045',4,4,'Biphenotypic sinonasal sarcoma','(C30.0, C31._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9052',2,4,'Well differentiated papillary mesothelioma of pleura','(C38.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9055',1,4,'Peritoneal inclusion cysts','(C48._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9055',1,5,'Cystic mesothelioma','(C48._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9055',1,5,'Multicystic mesothelioma','(C48._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9061',4,4,'Seminoma, NOS','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9062',4,4,'Seminoma, anaplastic','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9062',4,5,'Seminoma with high mitotic index','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9063',4,4,'Spermatocytic seminoma','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9063',4,5,'Spermatocytoma','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9063',4,5,'Spermatocytic tumor','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9064',3,4,'Intratubular malignant germ cells','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9064',3,5,'Intratubular germ cell neoplasia','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9064',3,5,'Germ cell neoplasia in situ','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9065',4,4,'Germ cell tumor, nonseminomatous','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9071',4,5,'Orchioblastoma','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',2,6,'Immature teratoma of lung','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9080',2,6,'Immature teratoma of thymus','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9080',2,6,'Immature teratoma of thyroid','(C73.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',1,6,'Teratoma, prepubertal type','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',1,5,'Teratoma, mature, prepubertal type','(C62._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9084',4,5,'Dermoid cyst with malignant transformation','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9090',1,4,'Struma ovarii, NOS','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9090',4,4,'Struma ovarii, malignant','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9091',2,4,'Strumal carcinoid','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9091',2,5,'Struma ovarii and carcinoid','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',1,4,'Hydatidiform mole, NOS','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9100',1,5,'Complete hydatidiform mole','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',1,5,'Hydatid mole','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',2,4,'Invasive hydatidiform mole','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',2,5,'Invasive mole, NOS','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',2,5,'Chorioadenoma, NOS','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',2,5,'Chorioadenoma destruens','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9100',2,5,'Malignant hydatidiform mole','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9103',1,4,'Partial hydatidiform mole','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9104',2,4,'Placental site trophoblastic tumor','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9110',1,4,'Adenoma of rete ovarii','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9110',4,6,'Adenocarcinoma of rete ovarii','(C56.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9120',1,5,'Chorioangioma','(C58.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9124',4,4,'Kupffer cell sarcoma','(C22.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9125',1,6,'Cutaneous epithelioid angiomatoid nodule','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9133',4,6,'Intravascular bronchial alveolar tumor','(C34._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9160',1,5,'Fibrous papule of nose','(C44.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9160',1,5,'Involuting nevus','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9180',1,4,'Osteoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9180',4,4,'Osteosarcoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9180',4,5,'Osteogenic sarcoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9180',4,5,'Osteoblastic sarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9180',4,5,'Osteochondrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9181',4,4,'Chondroblastic osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9182',4,4,'Fibroblastic osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9182',4,5,'Osteofibrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9183',4,4,'Telangiectatic osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9184',4,4,'Osteosarcoma in Paget disease of bone','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9184',4,5,'Secondary osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9185',4,4,'Small cell osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9185',4,5,'Round cell osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9186',4,4,'Central osteosarcoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9186',4,5,'Conventional central osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9186',4,5,'Medullary osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9187',4,4,'Low grade central osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9187',4,5,'Low grade intramedullary osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9187',4,6,'Intraosseous well differentiated osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9187',4,5,'Intraosseous low grade osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9191',1,4,'Osteoid osteoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9192',4,4,'Parosteal osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9192',4,5,'Juxtacortical osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9193',4,4,'Periosteal osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9194',4,4,'High grade surface osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9195',4,4,'Intracortical osteosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9200',1,4,'Osteoblastoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9200',1,5,'Giant osteoid osteoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9200',2,4,'Aggressive osteoblastoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9210',1,4,'Osteochondroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9210',1,5,'Cartilaginous exostosis','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9210',1,5,'Ecchondroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9210',1,5,'Osteocartilaginous exostosis','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9210',2,4,'Osteochondromatosis, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9210',2,5,'Ecchondrosis','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',1,4,'Chondroma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',1,6,'Enchondroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',4,4,'Chondrosarcoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',4,6,'Fibrochondrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',4,6,'Chondrosarcoma, grade 2','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9220',4,6,'Chondrosarcoma, grade 3','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9221',1,4,'Periosteal chondroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9221',1,6,'Juxtacortical chondroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9221',4,4,'Periosteal chondrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9221',4,6,'Juxtacortical chondrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9222',2,5,'Chondrosarcoma, grade 1','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9230',2,4,'Chondroblastoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9230',2,5,'Chondromatous giant cell tumor','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9230',2,5,'Codman tumor','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9230',4,4,'Chondroblastoma, malignant','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9241',1,4,'Chondromyxoid fibroma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9242',4,4,'Clear cell chondrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9243',4,4,'Dedifferentiated chondrosarcoma','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9250',2,4,'Giant cell tumor of bone, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9250',2,5,'Osteoclastoma, NOS','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9250',4,4,'Giant cell tumor of bone, malignant','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9250',4,5,'Giant cell sarcoma of bone','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9250',4,5,'Osteoclastoma, malignant','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',1,4,'Tenosynovial giant cell tumor, NOS','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',1,6,'Tenosynovial giant cell tumor, localised','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',1,5,'Fibrous histiocytoma of tendon sheath','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',1,5,'Giant cell tumor of tendon sheath, NOS','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',2,4,'Tenosynovial giant cell tumor, diffuse','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9252',4,4,'Malignant tenosynovial giant cell tumor','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9252',4,5,'Giant cell tumor of tendon sheath, malignant','(C49._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9261',4,4,'Adamantinoma of long bones','(C40._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9350',2,4,'Craniopharyngioma, NOS','(C75.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9350',2,5,'Rathke pouch tumor','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9351',2,4,'Craniopharyngioma, adamantinomatous','(C75.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9352',2,4,'Craniopharyngioma, papillary','(C75.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9360',2,4,'Pinealoma','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9361',2,4,'Pineocytoma','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9362',4,4,'Pineoblastoma','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9362',4,6,'Mixed pineal tumor','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9362',4,5,'Mixed pineocytoma-pineoblastoma','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9362',4,6,'Pineal parenchymal tumor of intermediate differentiation','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9362',4,6,'Transitional pineal tumor','(C75.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9380',4,4,'Glioma, malignant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9381',4,4,'Gliomatosis cerebri','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9382',4,4,'Oligoastrocytoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9382',4,5,'Mixed glioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9382',4,5,'Anaplastic oligoastrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9383',2,4,'Subependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9383',2,5,'Subependymal astrocytoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9383',2,5,'Subependymal glioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9383',2,6,'Mixed subependymoma-ependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9384',2,4,'Subependymal giant cell astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9385',4,4,'Diffuse midline glioma, H3 K27M-mutant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9385',4,6,'Diffuse intrinsic pontine glioma, H3 K27M-mutant','(C71.7)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9390',1,4,'Choroid plexus papilloma, NOS','(C71.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9390',2,4,'Atypical choroid plexus papilloma','(C71.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9390',4,4,'Choroid plexus carcinoma','(C71.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9390',4,5,'Choroid plexus papilloma, anaplastic','(C71.5)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9390',4,5,'Choroid plexus papilloma, malignant','(C71.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9391',2,4,'Sellar ependymoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9391',4,4,'Ependymoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9391',4,5,'Epithelial ependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9391',4,6,'Cellular ependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9391',4,6,'Clear cell ependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9391',4,6,'Tanycytic ependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9392',4,4,'Ependymoma, anaplastic','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9392',4,5,'Ependymoblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9393',4,4,'Papillary ependymoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9394',2,4,'Myxopapillary ependymoma','(C72.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9396',4,4,'Ependymoma, RELA fusion positive','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,4,'Astrocytoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,5,'Astrocytic glioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,5,'Astroglioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,6,'Astrocytoma, low grade','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,6,'Cystic astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,6,'Diffuse astrocytoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,6,'Diffuse astrocytoma, low grade','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9400',4,6,'Diffuse astrocytoma, IDH-mutant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9400',4,6,'Diffuse astrocytoma, IDH-wildtype','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9401',4,4,'Astrocytoma, anaplastic, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9401',4,6,'Astrocytoma, anaplastic, IDH-mutant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9401',4,6,'Astrocytoma, anaplastic, IDH-wildtype','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9410',4,4,'Protoplasmic astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9411',4,4,'Gemistocytic astrocytoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9411',4,5,'Gemistocytic astrocytoma, IDH-mutant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9411',4,5,'Gemistocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9412',2,4,'Desmoplastic infantile astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9412',2,6,'Desmoplastic infantile ganglioglioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9420',4,4,'Fibrillary astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9420',4,5,'Fibrous astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9421',2,4,'Pilocytic astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9421',2,5,'Spongioblastoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9421',2,5,'Juvenile astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9421',2,5,'Piloid astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9423',4,4,'Polar spongioblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9423',4,5,'Primitive polar spongioblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9423',4,5,'Spongioblastoma polare','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9424',4,4,'Pleomorphic xanthoastrocytoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9424',4,6,'Anaplastic pleomorphic xanthoastrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9425',4,4,'Pilomyxoid astrocytoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9430',4,4,'Astroblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9432',2,4,'Pituicytoma','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9364',4,5,'PPNET',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9440',4,4,'Glioblastoma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9440',4,6,'Epithelioid glioblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9440',4,6,'Glioblastoma, IDH-wildtype','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9440',4,6,'Glioblastoma, primary, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9440',4,5,'Glioblastoma multiforme','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9440',4,5,'Spongioblastoma multiforme','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9441',4,4,'Giant cell glioblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9441',4,5,'Monstrocellular sarcoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9442',2,4,'Gliofibroma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9442',4,4,'Gliosarcoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9442',4,5,'Glioblastoma with sarcomatous component','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9444',2,4,'Chordoid glioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9444',2,6,'Chordoid glioma of third ventricle','(C71.5)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9445',4,4,'Glioblastoma, IDH-mutant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9445',4,5,'Glioblastoma, secondary, IDH-mutant','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9445',4,6,'Glioblastoma, secondary, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9450',4,4,'Oligodendroglioma, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9450',4,6,'Oligodendroglioma, IDH-mutant and 1p/19q-codeleted','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9451',4,4,'Oligodendroglioma, anaplastic, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9451',4,6,'Oligodendroglioma, anaplastic, IDH-mutant and 1p/19q codeleted','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9460',4,4,'Oligodendroblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9470',4,4,'Medulloblastoma, NOS','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9470',4,6,'Classic medulloblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9470',4,6,'Melanotic medulloblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9471',4,4,'Desmoplastic nodular medulloblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9471',4,5,'Circumscribed arachnoidal cerebellar sarcoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9471',4,5,'Desmoplastic medulloblastoma, NOS','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9471',4,6,'Medulloblastoma with extensive nodularity','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9471',4,6,'Medulloblastoma, SHH-activated and TP53-wildtype','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9471',4,6,'Medulloblastoma, SHH activated, NOS','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9472',4,4,'Medullomyoblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9473',4,6,'Central primitive neuroectodermal tumor','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9473',4,5,'CPNET','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9473',4,6,'Supratentorial PNET','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9474',4,4,'Large cell medulloblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9474',4,6,'Anaplastic medulloblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9475',4,4,'Medulloblastoma, WNT-activated, NOS','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9475',4,6,'Medulloblastoma, WNT-activated, classic','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9475',4,6,'Medulloblastoma, WNT-activated, large cell type','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9475',4,6,'Medulloblastoma, WNT-activated, anaplastic type','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9476',4,4,'Medulloblastoma, SHH-activated and TP53-mutant','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9477',4,4,'Medulloblastoma, non-WNT/non-SHH','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9477',4,6,'Medulloblastoma, group 3','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9477',4,6,'Medulloblastoma, group 4','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9478',4,4,'Embryonal tumor with multilayered rosettes with C19MC alteration','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9478',4,6,'Embryonal tumor with multilayered rosettes, NOS','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9480',4,4,'Cerebellar sarcoma, NOS','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9493',1,4,'Dysplastic gangliocytoma of cerebellum (Lhermitte-Duclos)','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9500',4,5,'Central neuroblastoma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9501',1,4,'Medulloepithelioma, benign','(C69.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9501',1,5,'Diktyoma, benign','(C69._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9501',4,5,'Diktyoma, malignant','(C69._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9502',1,4,'Teratoid medulloepithelioma, benign','(C69.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9506',2,6,'Cerebellar liponeurocytoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9506',2,5,'Lipomatous medulloblastoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9506',2,5,'Medullocytoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9506',2,5,'Neurolipocytoma','(C71.6)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9508',4,4,'Atypical teratoid/rhabdoid tumor','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9508',4,6,'CNS embryonal tumor with rhabdoid features','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9510',1,4,'Retinocytoma','(C69.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9510',4,4,'Retinoblastoma, NOS','(C69.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9511',4,4,'Retinoblastoma, differentiated','(C69.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9512',4,4,'Retinoblastoma, undifferentiated','(C69.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9513',4,4,'Retinoblastoma, diffuse','(C69.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9514',2,4,'Retinoblastoma, spontaneously regressed','(C69.2)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9521',4,4,'Olfactory neurocytoma','(C30.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9521',4,5,'Esthesioneurocytoma','(C30.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9522',4,4,'Olfactory neuroblastoma','(C30.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9522',4,5,'Esthesioneuroblastoma','(C30.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9523',4,4,'Olfactory neuroepithelioma','(C30.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9523',4,5,'Esthesioneuroepithelioma','(C30.0)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9560',1,6,'Acoustic neuroma','(C72.4)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9582',1,4,'Granular cell tumor of sellar region','(C75.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9590',4,5,'Microglioma','(C71._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9597',4,4,'Primary cutaneous follicle center lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9679',4,4,'Mediastinal large B-cell lymphoma','(C38.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9679',4,5,'Thymic large B-cell lymphoma','(C37.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9659',4,5,'Hodgkin paragranuloma, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Primary cutaneous diffuse large B-cell lymphoma, leg type','(C44.7)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Primary diffuse large B-cell lymphoma of CNS','(C70._, C71._, C72._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9680',4,6,'Vitreoretinal lymphoma','(C69._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9689',4,4,'Splenic marginal zone B-cell lymphoma','(C42.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9689',4,5,'Splenic marginal zone lymphoma, NOS','(C42.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9689',4,5,'Splenic lymphoma with villous lymphocytes','(C42.2)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9695',4,6,'Follicular lymphoma, duodenal type','(C17.0)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9699',4,6,'Primary choroidal lymphoma','(C69.3)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9684',4,5,'Immunoblastic sarcoma',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9700',4,4,'Mycosis fungoides','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9700',4,6,'Granulomatous slack skin','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9709',2,4,'Primary cutaneous CD4 positive small/medium T-cell lymphoproliferative disorder','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9709',2,6,'Primary cutaneous CD4 positive small/medium T-cell lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9709',4,4,'Cutaneous T-cell lymphoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9709',4,5,'Cutaneous lymphoma, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9709',4,6,'Primary cutaneous CD8 positive aggressive epidermotropic cytotoxic T-cell lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9709',4,6,'Primary cutaneous acral CD8 positive T-cell lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9712',4,4,'Intravascular large B-cell lymphoma','(C49.9)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9715',4,6,'Breast implant-associated anaplastic large cell lymphoma','(C50._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9718',2,4,'Primary cutaneous CD30 positive T-cell lymphoproliferative disorder','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9718',2,5,'Lymphomatoid papulosis','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9718',4,4,'Primary cutaneous anaplastic large cell lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9718',4,5,'Primary cutaneous CD30 positive large T-cell lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9726',4,4,'Primary cutaneous gamma-delta T-cell lymphoma','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('970-971',7,3,'Mature T- and NK-cell lymphomas',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9731',4,5,'Plasmacytoma of bone','(C40._, C41._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9732',4,4,'Plasma cell myeloma','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9732',4,5,'Multiple myeloma','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9732',4,5,'Myeloma, NOS','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9732',4,5,'Myelomatosis','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9733',4,4,'Plasma cell leukemia','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9733',4,5,'Plasmacytic leukemia','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',2,6,'Cutaneous mastocytosis, NOS','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',2,6,'Diffuse cutaneous mastocytosis','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9740',2,6,'Solitary mastocytoma of skin','(C44._)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9742',4,4,'Mast cell leukemia','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9764',4,4,'Immunoproliferative small intestinal disease','(C17._)',false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('980-994',7,2,'Leukemias',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9931',4,4,'Acute panmyelosis with myelofibrosis','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9940',4,4,'Hairy cell leukemia, NOS','(C42.1)',false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9872',4,5,'FAB M0',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9950',4,5,'Proliferative polycythemia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9960',4,4,'Myeloproliferative neoplasm, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9960',4,5,'Chronic myeloproliferative disease, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9960',4,5,'Chronic myeloproliferative disorder',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9960',4,5,'Myeloproliferative disease, NOS',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9961',4,4,'Primary myelofibrosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);
INSERT INTO public.icd_o_morpho (cell_type_code,icd_o_morpho_behavior_id,icd_o_morpho_level_id,term,code_reference,obs,additional_information,created_on,user_created,morpho_version) VALUES
	 ('9961',4,5,'Agnogenic myeloid metaplasia',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1),
	 ('9961',4,5,'Chronic idiopathic myelofibrosis',NULL,false,NULL,'2020-12-18 00:00:00+01',false,1);


INSERT INTO public.icd_o_topo_level ("level") VALUES
	 ('3'),
	 ('incl'),
	 ('4'),
	 ('b'),
	 ('k');


INSERT INTO public.icd_o_topo_version ("version") VALUES
	 ('ICD-O-3 Topoenglish.txt from 06 July 2007');


INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C00',1,'LIP',1),
	 ('C00.0',2,'Upper lip, NOS',1),
	 ('C00.0',2,'skin of upper lip',1),
	 ('C00.0',3,'External upper lip',1),
	 ('C00.0',2,'Vermilion border of upper lip',1),
	 ('C00.1',3,'External lower lip',1),
	 ('C00.1',2,'Vermilion border of lower lip',1),
	 ('C00.1',2,'Lower lip, NOS',1),
	 ('C00.1',2,'skin of lower lip',1),
	 ('C00.2',3,'External lip, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C00.3',2,'Frenulum of upper lip',1),
	 ('C00.3',3,'Mucosa of upper lip',1),
	 ('C00.4',3,'Mucosa of lower lip',1),
	 ('C00.4',2,'Inner aspect of lower lip',1),
	 ('C00.4',2,'Frenulum of lower lip',1),
	 ('C00.5',2,'Frenulum labii, NOS',1),
	 ('C00.5',2,'Frenulum of lip, NOS',1),
	 ('C00.5',2,'Inner aspect of lip, NOS',1),
	 ('C00.5',2,'Internal lip, NOS',1),
	 ('C00.5',3,'Mucosa of lip, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C00.6',3,'Commissure of lip',1),
	 ('C00.6',2,'Labial commissure',1),
	 ('C00.8',3,'Overlapping lesion of lip',1),
	 ('C00.9',3,'Lip, NOS',1),
	 ('C01',1,'BASE OF TONGUE',1),
	 ('C01.9',2,'Posterior third of tongue',1),
	 ('C01.9',2,'Posterior tongue, NOS',1),
	 ('C01.9',2,'Dorsal surface of base of tongue',1),
	 ('C01.9',3,'Base of tongue, NOS',1),
	 ('C01.9',2,'Root of tongue',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C02',1,'OTHER AND UNSPECIFIED PARTS OF TONGUE',1),
	 ('C02.0',3,'Dorsal surface of tongue, NOS',1),
	 ('C02.0',2,'Anterior 2/3 of tongue, dorsal surface',1),
	 ('C02.0',2,'Midline of tongue',1),
	 ('C02.0',2,'Dorsal surface of anterior tongue',1),
	 ('C02.1',3,'Border of tongue',1),
	 ('C02.1',2,'Tip of tongue',1),
	 ('C02.2',2,'Ventral surface of anterior tongue, NOS',1),
	 ('C02.2',3,'Ventral surface of tongue, NOS',1),
	 ('C02.2',2,'Anterior 2/3 of tongue, ventral surface',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C02.2',2,'Frenulum linguae',1),
	 ('C02.3',3,'Anterior 2/3 of tongue, NOS',1),
	 ('C02.3',2,'Anterior tongue, NOS',1),
	 ('C02.4',3,'Lingual tonsil',1),
	 ('C02.8',3,'Overlapping lesion of tongue',1),
	 ('C02.8',2,'Junctional zone of tongue',1),
	 ('C02.9',3,'Tongue, NOS',1),
	 ('C02.9',2,'Lingual, NOS',1),
	 ('C03',1,'GUM',1),
	 ('C03.0',3,'Upper gum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C03.0',2,'Upper gingiva',1),
	 ('C03.0',2,'Upper alveolus',1),
	 ('C03.0',2,'Upper alveolar mucosa',1),
	 ('C03.0',2,'Upper alveolar ridge mucosa',1),
	 ('C03.1',3,'Lower gum',1),
	 ('C03.1',2,'Lower alveolar mucosa',1),
	 ('C03.1',2,'Lower alveolar ridge mucosa',1),
	 ('C03.1',2,'Lower alveolus',1),
	 ('C03.1',2,'Lower gingiva',1),
	 ('C03.9',2,'Alveolus, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C03.9',2,'Periodontal tissue',1),
	 ('C03.9',2,'Tooth socket',1),
	 ('C03.9',3,'Gum, NOS',1),
	 ('C03.9',2,'Alveolar mucosa, NOS',1),
	 ('C03.9',2,'Alveolar ridge mucosa, NOS',1),
	 ('C04',1,'FLOOR OF MOUTH',1),
	 ('C04.0',3,'Anterior floor of mouth',1),
	 ('C04.1',3,'Lateral floor of mouth',1),
	 ('C04.8',3,'Overlapping lesion of floor of mouth',1),
	 ('C04.9',3,'Floor of mouth, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C05',1,'PALATE',1),
	 ('C05.0',3,'Hard palate',1),
	 ('C05.1',3,'Soft palate, NOS',1),
	 ('C05.2',3,'Uvula',1),
	 ('C05.8',3,'Overlapping lesion of palate',1),
	 ('C05.8',2,'Junction of hard and soft palate',1),
	 ('C05.9',2,'Roof of mouth',1),
	 ('C05.9',3,'Palate, NOS',1),
	 ('C06',1,'OTHER AND UNSPECIFIED PARTS OF MOUTH',1),
	 ('C06.0',3,'Cheek mucosa',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C06.0',2,'Internal cheek',1),
	 ('C06.0',2,'Buccal mucosa',1),
	 ('C06.1',3,'Vestibule of mouth',1),
	 ('C06.1',2,'Buccal sulcus',1),
	 ('C06.1',2,'Labial sulcus',1),
	 ('C06.2',3,'Retromolar area',1),
	 ('C06.2',2,'Retromolar triangle',1),
	 ('C06.2',2,'Retromolar trigone',1),
	 ('C06.8',3,'Overlapping lesion of other and unspecified parts of mouth',1),
	 ('C06.9',2,'Minor salivary gland, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C06.9',2,'Oral mucosa',1),
	 ('C06.9',2,'Oral cavity',1),
	 ('C06.9',3,'Mouth, NOS',1),
	 ('C06.9',2,'Buccal cavity',1),
	 ('C07',1,'PAROTID GLAND',1),
	 ('C07.9',2,'Parotid gland duct',1),
	 ('C07.9',3,'Parotid gland',1),
	 ('C07.9',2,'Parotid, NOS',1),
	 ('C07.9',2,'Stensen duct',1),
	 ('C08',1,'OTHER AND UNSPECIFIED MAJOR SALIVARY GLANDS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C08.0',3,'Submandibular gland',1),
	 ('C08.0',2,'Submaxillary gland',1),
	 ('C08.0',2,'Wharton duct',1),
	 ('C08.0',2,'Submaxillary gland duct',1),
	 ('C08.1',3,'Sublingual gland',1),
	 ('C08.1',2,'Sublingual gland duct',1),
	 ('C08.8',3,'Overlapping lesion of major salivary glands',1),
	 ('C08.9',2,'Salivary gland, NOS',1),
	 ('C08.9',2,'minor salivary gland, NOS',1),
	 ('C08.9',3,'Major salivary gland, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C09',1,'TONSIL',1),
	 ('C09.0',3,'Tonsillar fossa',1),
	 ('C09.1',3,'Tonsillar pillar',1),
	 ('C09.1',2,'Faucial pillar',1),
	 ('C09.1',2,'Glossopalatine fold',1),
	 ('C09.8',3,'Overlapping lesion of tonsil',1),
	 ('C09.9',2,'Faucial tonsil',1),
	 ('C09.9',3,'Tonsil, NOS',1),
	 ('C09.9',2,'Palatine tonsil',1),
	 ('C10',1,'OROPHARYNX',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C10.0',3,'Vallecula',1),
	 ('C10.1',3,'Anterior surface of epiglottis',1),
	 ('C10.2',3,'Lateral wall of oropharynx',1),
	 ('C10.2',2,'Lateral wall of mesopharynx',1),
	 ('C10.3',3,'Posterior wall of oropharynx',1),
	 ('C10.3',2,'Posterior wall of mesopharynx',1),
	 ('C10.4',3,'Branchial cleft',1),
	 ('C10.8',2,'Junctional region of oropharynx',1),
	 ('C10.8',3,'Overlapping lesion of oropharynx',1),
	 ('C10.9',2,'Mesopharynx, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C10.9',2,'Fauces, NOS',1),
	 ('C10.9',3,'Oropharynx, NOS',1),
	 ('C11',1,'NASOPHARYNX',1),
	 ('C11.0',3,'Superior wall of nasopharynx',1),
	 ('C11.0',2,'Roof of nasopharynx',1),
	 ('C11.1',2,'Pharyngeal tonsil',1),
	 ('C11.1',3,'Posterior wall of nasopharynx',1),
	 ('C11.1',2,'Adenoid',1),
	 ('C11.2',3,'Lateral wall of nasopharynx',1),
	 ('C11.2',2,'Fossa of Rosenmuller',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C11.3',2,'Posterior margin of nasal septum',1),
	 ('C11.3',2,'Choana',1),
	 ('C11.3',2,'Pharyngeal fornix',1),
	 ('C11.3',2,'Nasopharyngeal surface of soft palate',1),
	 ('C11.3',3,'Anterior wall of nasopharynx',1),
	 ('C11.8',3,'Overlapping lesion of nasopharynx',1),
	 ('C11.9',2,'Nasopharyngeal wall',1),
	 ('C11.9',3,'Nasopharynx, NOS',1),
	 ('C12',1,'PYRIFORM SINUS',1),
	 ('C12.9',2,'Piriform fossa',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C12.9',3,'Pyriform sinus',1),
	 ('C12.9',2,'Pyriform fossa',1),
	 ('C12.9',2,'Piriform sinus',1),
	 ('C13',1,'HYPOPHARYNX',1),
	 ('C13.0',2,'Cricopharynx',1),
	 ('C13.0',3,'Postcricoid region',1),
	 ('C13.0',2,'Cricoid, NOS',1),
	 ('C13.1',3,'Hypopharyngeal aspect of aryepiglottic fold',1),
	 ('C13.1',2,'Arytenoid fold',1),
	 ('C13.1',2,'laryngeal aspect of aryepiglottic fold',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C13.1',2,'Aryepiglottic fold, NOS',1),
	 ('C13.2',3,'Posterior wall of hypopharynx',1),
	 ('C13.8',3,'Overlapping lesion of hypopharynx',1),
	 ('C13.9',3,'Hypopharynx, NOS',1),
	 ('C13.9',2,'Hypopharyngeal wall',1),
	 ('C13.9',2,'Laryngopharynx',1),
	 ('C14',1,'OTHER AND ILL-DEFINED SITES IN LIP, ORAL CAVITY AND PHARYNX',1),
	 ('C14.0',2,'Pharyngeal wall, NOS',1),
	 ('C14.0',2,'Wall of pharynx, NOS',1),
	 ('C14.0',2,'Lateral wall of pharynx, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C14.0',2,'Posterior wall of pharynx, NOS',1),
	 ('C14.0',2,'Retropharynx',1),
	 ('C14.0',2,'Throat',1),
	 ('C14.0',3,'Pharynx, NOS',1),
	 ('C14.2',3,'Waldeyer ring',1),
	 ('C14.8',3,'Overlapping lesion of lip, oral cavity and pharynx',1),
	 ('C15',1,'ESOPHAGUS',1),
	 ('C15.0',3,'Cervical esophagus',1),
	 ('C15.1',3,'Thoracic esophagus',1),
	 ('C15.2',3,'Abdominal esophagus',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C15.3',2,'Proximal third of esophagus',1),
	 ('C15.3',3,'Upper third of esophagus',1),
	 ('C15.4',3,'Middle third of esophagus',1),
	 ('C15.5',3,'Lower third of esophagus',1),
	 ('C15.5',2,'Distal third of esophagus',1),
	 ('C15.8',3,'Overlapping lesion of esophagus',1),
	 ('C15.9',3,'Esophagus, NOS',1),
	 ('C16',1,'STOMACH',1),
	 ('C16.0',2,'Gastroesophageal junction',1),
	 ('C16.0',2,'Esophagogastric junction',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C16.0',2,'Cardioesophageal junction',1),
	 ('C16.0',3,'Cardia, NOS',1),
	 ('C16.0',2,'Gastric cardia',1),
	 ('C16.1',3,'Fundus of stomach',1),
	 ('C16.1',2,'Gastric fundus',1),
	 ('C16.2',2,'Corpus of stomach',1),
	 ('C16.2',2,'Gastric corpus',1),
	 ('C16.2',3,'Body of stomach',1),
	 ('C16.3',3,'Gastric antrum',1),
	 ('C16.3',2,'Antrum of stomach',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C16.3',2,'Pyloric antrum',1),
	 ('C16.4',3,'Pylorus',1),
	 ('C16.4',2,'Pyloric canal',1),
	 ('C16.4',2,'Prepylorus',1),
	 ('C16.5',3,'Lesser curvature of stomach, NOS',1),
	 ('C16.6',3,'Greater curvature of stomach, NOS',1),
	 ('C16.8',3,'Overlapping lesion of stomach',1),
	 ('C16.8',2,'Posterior wall of stomach, NOS',1),
	 ('C16.8',2,'Anterior wall of stomach, NOS',1),
	 ('C16.9',3,'Stomach, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C16.9',2,'Gastric, NOS',1),
	 ('C17',1,'SMALL INTESTINE',1),
	 ('C17.0',3,'Duodenum',1),
	 ('C17.1',3,'Jejunum',1),
	 ('C17.2',3,'Ileum',1),
	 ('C17.3',3,'Meckel diverticulum',1),
	 ('C17.8',3,'Overlapping lesion of smallintestine',1),
	 ('C17.9',3,'Small intestine, NOS',1),
	 ('C17.9',2,'Small bowel, NOS',1),
	 ('C18',1,'COLON',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C18.0',3,'Cecum',1),
	 ('C18.0',2,'Ileocecal valve',1),
	 ('C18.0',2,'Ileocecal junction',1),
	 ('C18.1',3,'Appendix',1),
	 ('C18.2',2,'Right colon',1),
	 ('C18.2',3,'Ascending colon',1),
	 ('C18.3',3,'Hepatic flexure of colon',1),
	 ('C18.4',3,'Transverse colon',1),
	 ('C18.5',3,'Splenic flexure of colon',1),
	 ('C18.6',3,'Descending colon',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C18.6',2,'Left colon',1),
	 ('C18.7',3,'Sigmoid colon',1),
	 ('C18.7',2,'Sigmoid, NOS',1),
	 ('C18.7',2,'Sigmoid flexure of colon',1),
	 ('C18.7',2,'Pelvic colon',1),
	 ('C18.8',3,'Overlapping lesion of colon',1),
	 ('C18.9',2,'Large intestine',1),
	 ('C18.9',2,'rectum, NOS',1),
	 ('C18.9',3,'Colon, NOS',1),
	 ('C18.9',2,'and rectosigmoid junction',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C18.9',2,'Large bowel, NOS',1),
	 ('C19',1,'RECTOSIGMOID JUNCTION',1),
	 ('C19.9',2,'Pelvirectal junction',1),
	 ('C19.9',2,'Rectosigmoid colon',1),
	 ('C19.9',2,'Rectosigmoid, NOS',1),
	 ('C19.9',2,'Colon and rectum',1),
	 ('C19.9',3,'Rectosigmoid junction',1),
	 ('C20',1,'RECTUM',1),
	 ('C20.9',2,'Rectal ampulla',1),
	 ('C20.9',3,'Rectum, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C21',1,'ANUS AND ANAL CANAL',1),
	 ('C21.0',3,'Anus, NOS',1),
	 ('C21.1',2,'Anal sphincter',1),
	 ('C21.1',3,'Anal canal',1),
	 ('C21.2',3,'Cloacogenic zone',1),
	 ('C21.8',2,'Anorectal junction',1),
	 ('C21.8',2,'Anorectum',1),
	 ('C21.8',3,'Overlapping lesion of rectum, anus and anal canal',1),
	 ('C22',1,'LIVER AND INTRAHEPATIC BILE DUCTS',1),
	 ('C22.0',2,'Hepatic, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C22.0',3,'Liver',1),
	 ('C22.1',3,'Intrahepatic bile duct',1),
	 ('C22.1',2,'Biliary canaliculus',1),
	 ('C22.1',2,'Cholangiole',1),
	 ('C23',1,'GALLBLADDER',1),
	 ('C23.9',3,'Gallbladder',1),
	 ('C24',1,'OTHER AND UNSPECIFIED PARTS OF BILIARY TRACT',1),
	 ('C24.0',3,'Extrahepatic bile duct',1),
	 ('C24.0',2,'Sphincter of Oddi',1),
	 ('C24.0',2,'Cystic bile duct',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C24.0',2,'Hepatic duct',1),
	 ('C24.0',2,'Cystic duct',1),
	 ('C24.0',2,'Common duct',1),
	 ('C24.0',2,'Common bile duct',1),
	 ('C24.0',2,'Choledochal duct',1),
	 ('C24.0',2,'Bile duct, NOS',1),
	 ('C24.0',2,'Biliary duct, NOS',1),
	 ('C24.0',2,'Hepatic bile duct',1),
	 ('C24.1',3,'Ampulla of Vater',1),
	 ('C24.1',2,'Periampullary',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C24.8',3,'Overlapping lesion of biliary tract Note:',1),
	 ('C24.9',3,'Biliary tract, NOS',1),
	 ('C25',1,'PANCREAS',1),
	 ('C25.0',3,'Head of pancreas',1),
	 ('C25.1',3,'Body of pancreas',1),
	 ('C25.2',3,'Tail of pancreas',1),
	 ('C25.3',2,'Duct of Wirsung',1),
	 ('C25.3',3,'Pancreatic duct',1),
	 ('C25.3',2,'Duct of Santorini',1),
	 ('C25.4',3,'Islets of Langerhans',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C25.4',2,'Islands of Langerhans',1),
	 ('C25.4',2,'Endocrine pancreas',1),
	 ('C25.7',3,'Other specified parts of pancreas',1),
	 ('C25.7',2,'Neck of pancreas',1),
	 ('C25.8',3,'Overlapping lesion of pancreas',1),
	 ('C25.9',3,'Pancreas, NOS',1),
	 ('C26',1,'OTHER AND ILL-DEFINED DIGESTIVE ORGANS',1),
	 ('C26.0',3,'Intestinal tract, NOS',1),
	 ('C26.0',2,'Bowel, NOS',1),
	 ('C26.0',2,'Intestine, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C26.8',3,'Overlapping lesion of digestive system',1),
	 ('C26.9',3,'Gastrointestinal tract, NOS',1),
	 ('C26.9',2,'Digestive organs, NOS',1),
	 ('C30',1,'NASAL CAVITY AND MIDDLE EAR',1),
	 ('C30.0',2,'Nostril',1),
	 ('C30.0',2,'posterior margin of nasal septum',1),
	 ('C30.0',2,'Nasal septum, NOS',1),
	 ('C30.0',2,'Nasal mucosa',1),
	 ('C30.0',2,'Nasal cartilage',1),
	 ('C30.0',2,'Naris',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C30.0',3,'Nasal cavity',1),
	 ('C30.0',2,'Nasal turbinate',1),
	 ('C30.0',2,'Internal nose',1),
	 ('C30.0',2,'Vestibule of nose',1),
	 ('C30.1',2,'Eustachian tube',1),
	 ('C30.1',3,'Middle ear',1),
	 ('C30.1',2,'Inner ear',1),
	 ('C30.1',2,'Auditory tube',1),
	 ('C30.1',2,'Mastoid antrum',1),
	 ('C30.1',2,'Tympanic cavity',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C31',1,'ACCESSORY SINUSES',1),
	 ('C31.0',3,'Maxillary sinus',1),
	 ('C31.0',2,'Maxillary antrum',1),
	 ('C31.0',2,'Antrum, NOS',1),
	 ('C31.1',3,'Ethmoid sinus',1),
	 ('C31.2',3,'Frontal sinus',1),
	 ('C31.3',3,'Sphenoid sinus',1),
	 ('C31.8',3,'Overlapping lesion of accessory sinuses',1),
	 ('C31.9',2,'Paranasal sinus',1),
	 ('C31.9',3,'Accessory sinus, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C31.9',2,'Accessory nasal sinus',1),
	 ('C32',1,'LARYNX',1),
	 ('C32.0',2,'Intrinsic larynx',1),
	 ('C32.0',2,'Laryngeal commissure',1),
	 ('C32.0',2,'Vocal cord, NOS',1),
	 ('C32.0',2,'True vocal cord',1),
	 ('C32.0',2,'True cord',1),
	 ('C32.0',3,'Glottis',1),
	 ('C32.1',2,'anterior surface of epiglottis',1),
	 ('C32.1',2,'False cord',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C32.1',2,'False vocal cord',1),
	 ('C32.1',2,'Ventricular band of larynx',1),
	 ('C32.1',2,'Posterior surface of epiglottis',1),
	 ('C32.1',2,'Extrinsic larynx',1),
	 ('C32.1',2,'Epiglottis, NOS',1),
	 ('C32.1',3,'Supraglottis',1),
	 ('C32.1',2,'Laryngeal aspect of aryepiglottic fold',1),
	 ('C32.2',3,'Subglottis',1),
	 ('C32.3',2,'Cuneiform cartilage',1),
	 ('C32.3',2,'Thyroid cartilage',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C32.3',3,'Laryngeal cartilage',1),
	 ('C32.3',2,'Cricoid cartilage',1),
	 ('C32.3',2,'Arytenoid cartilage',1),
	 ('C32.8',3,'Overlapping lesion of larynx',1),
	 ('C32.9',3,'Larynx, NOS',1),
	 ('C33',1,'TRACHEA',1),
	 ('C33.9',3,'Trachea',1),
	 ('C34',1,'BRONCHUS AND LUNG',1),
	 ('C34.0',2,'Hilus of lung',1),
	 ('C34.0',2,'Carina',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C34.0',3,'Main bronchus',1),
	 ('C34.1',2,'Upper lobe, bronchus',1),
	 ('C34.1',2,'Lingula of lung',1),
	 ('C34.1',3,'Upper lobe, lung',1),
	 ('C34.2',3,'Middle lobe, lung',1),
	 ('C34.2',2,'Middle lobe, bronchus',1),
	 ('C34.3',2,'Lower lobe, bronchus',1),
	 ('C34.3',3,'Lower lobe, lung',1),
	 ('C34.8',3,'Overlapping lesion of lung',1),
	 ('C34.9',2,'Pulmonary, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C34.9',3,'Lung, NOS',1),
	 ('C34.9',2,'Bronchus, NOS',1),
	 ('C34.9',2,'Bronchiole',1),
	 ('C34.9',2,'Bronchogenic',1),
	 ('C37',1,'THYMUS',1),
	 ('C37.9',3,'Thymus',1),
	 ('C38',1,'HEART, MEDIASTINUM, AND PLEURA',1),
	 ('C38.0',2,'Cardiac atrium',1),
	 ('C38.0',2,'Epicardium',1),
	 ('C38.0',2,'Myocardium',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C38.0',2,'Cardiac ventricle',1),
	 ('C38.0',3,'Heart',1),
	 ('C38.0',2,'Endocardium',1),
	 ('C38.0',2,'Pericardium',1),
	 ('C38.1',3,'Anterior mediastinum',1),
	 ('C38.2',3,'Posterior mediastinum',1),
	 ('C38.3',3,'Mediastinum, NOS',1),
	 ('C38.4',3,'Pleura, NOS',1),
	 ('C38.4',2,'Parietal pleura',1),
	 ('C38.4',2,'Visceral pleura',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C38.8',3,'Overlapping lesion of heart, mediastinum and pleura',1),
	 ('C39',1,'OTHER AND ILL-DEFINED SITES WITHIN RESPIRATORY SYSTEM AND INTRATHORACIC ORGANS',1),
	 ('C39.0',3,'Upper respiratory tract, NOS',1),
	 ('C39.8',3,'Overlapping lesion of respiratory system and intrathoracic organs',1),
	 ('C39.9',3,'Ill-defined sites within respiratory system',1),
	 ('C39.9',2,'Respiratory tract, NOS',1),
	 ('C40',1,'BONES, JOINTS AND ARTICULAR CARTILAGE OF LIMBS',1),
	 ('C40.0',2,'Bone of shoulder',1),
	 ('C40.0',2,'Ulna',1),
	 ('C40.0',2,'Shoulder joint',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C40.0',2,'Shoulder girdle',1),
	 ('C40.0',2,'Scapula',1),
	 ('C40.0',2,'Radius',1),
	 ('C40.0',2,'Elbow joint',1),
	 ('C40.0',2,'Bone of forearm',1),
	 ('C40.0',2,'Bone of arm',1),
	 ('C40.0',2,'Acromioclavicular joint',1),
	 ('C40.0',3,'Long bones of upper limb, scapula and associated joints',1),
	 ('C40.0',2,'Humerus',1),
	 ('C40.1',2,'Hand joint',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C40.1',2,'Bone of hand',1),
	 ('C40.1',2,'Wrist joint',1),
	 ('C40.1',2,'Phalanx of hand',1),
	 ('C40.1',2,'Metacarpal bone',1),
	 ('C40.1',3,'Short bones of upper limb and associated joints',1),
	 ('C40.1',2,'Bone of thumb',1),
	 ('C40.1',2,'Bone of finger',1),
	 ('C40.1',2,'Bone of wrist',1),
	 ('C40.1',2,'Carpal bone',1),
	 ('C40.2',2,'Knee joint, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C40.2',2,'Tibia',1),
	 ('C40.2',2,'Medial meniscus of knee joint',1),
	 ('C40.2',2,'Semilunar cartilage',1),
	 ('C40.2',2,'Fibula',1),
	 ('C40.2',2,'Femur',1),
	 ('C40.2',2,'Bone of leg',1),
	 ('C40.2',3,'Long bones of lower limb and associated joints',1),
	 ('C40.2',2,'Lateral meniscus of knee joint',1),
	 ('C40.3',2,'Ankle joint',1),
	 ('C40.3',2,'Phalanx of foot',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C40.3',2,'Foot joint',1),
	 ('C40.3',2,'Patella',1),
	 ('C40.3',2,'Tarsal bone',1),
	 ('C40.3',2,'Metatarsal bone',1),
	 ('C40.3',2,'Bone of heel',1),
	 ('C40.3',2,'Bone of ankle',1),
	 ('C40.3',3,'Short bones of lower limb and associated joints',1),
	 ('C40.3',2,'Bone of toe',1),
	 ('C40.3',2,'Bone of foot',1),
	 ('C40.8',3,'Overlapping lesion of bones, joints and articular cartilage of limbs',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C40.9',2,'Articular cartilage of limb, NOS',1),
	 ('C40.9',3,'Bone of limb, NOS',1),
	 ('C40.9',2,'Cartilage of limb, NOS',1),
	 ('C40.9',2,'Joint of limb, NOS',1),
	 ('C41',1,'BONES, JOINTS AND ARTICULAR CARTILAGE OF OTHER AND UNSPECIFIED SITES',1),
	 ('C41.0',2,'Hyoid bone',1),
	 ('C41.0',2,'Sphenoid bone',1),
	 ('C41.0',2,'Skull, NOS',1),
	 ('C41.0',2,'Parietal bone',1),
	 ('C41.0',2,'Orbital bone',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C41.0',2,'Occipital bone',1),
	 ('C41.0',2,'Zygomatic bone',1),
	 ('C41.0',2,'Nasal bone',1),
	 ('C41.0',2,'Temporal bone',1),
	 ('C41.0',2,'Frontal bone',1),
	 ('C41.0',2,'Facial bone',1),
	 ('C41.0',2,'Ethmoid bone',1),
	 ('C41.0',2,'Cranial bone',1),
	 ('C41.0',2,'Calvarium',1),
	 ('C41.0',3,'Bones of skull and face and associated joints',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C41.0',2,'Maxilla',1),
	 ('C41.0',2,'Upper jaw bone',1),
	 ('C41.1',3,'Mandible',1),
	 ('C41.1',2,'Temporomandibular joint',1),
	 ('C41.1',2,'Lower jaw bone',1),
	 ('C41.1',2,'Jaw bone, NOS',1),
	 ('C41.2',2,'Spine',1),
	 ('C41.2',2,'Spinal column',1),
	 ('C41.2',2,'Nucleus pulposus',1),
	 ('C41.2',2,'Intervertebral disc',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C41.2',2,'Axis',1),
	 ('C41.2',2,'Atlas',1),
	 ('C41.2',3,'Vertebral column',1),
	 ('C41.2',2,'Bone of back',1),
	 ('C41.2',2,'Vertebra',1),
	 ('C41.3',3,'Rib, sternum, clavicle and associated joints',1),
	 ('C41.3',2,'Costal cartilage',1),
	 ('C41.3',2,'Costovertebral joint',1),
	 ('C41.3',2,'Sternocostal joint',1),
	 ('C41.4',2,'Coccyx',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C41.4',2,'Symphysis pubis',1),
	 ('C41.4',2,'Sacrum',1),
	 ('C41.4',2,'Pubic bone',1),
	 ('C41.4',2,'Pelvic bone',1),
	 ('C41.4',2,'Ischium',1),
	 ('C41.4',2,'Innominate bone',1),
	 ('C41.4',2,'Hip joint',1),
	 ('C41.4',2,'Bone of hip',1),
	 ('C41.4',2,'Acetabulum',1),
	 ('C41.4',3,'Pelvic bones, sacrum, coccyx and associated joints',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C41.4',2,'Ilium',1),
	 ('C41.8',3,'Overlapping lesion of bones, joints and articular cartilage',1),
	 ('C41.9',2,'Articular cartilage, NOS',1),
	 ('C41.9',3,'Bone, NOS',1),
	 ('C41.9',2,'Cartilage, NOS',1),
	 ('C41.9',2,'Joint, NOS',1),
	 ('C41.9',2,'Skeletal bone',1),
	 ('C42',1,'HEMATOPOIETIC AND RETICULOENDOTHELIAL SYSTEMS',1),
	 ('C42.0',3,'Blood',1),
	 ('C42.1',3,'Bone marrow',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C42.2',3,'Spleen',1),
	 ('C42.3',3,'Reticuloendothelial system,NOS',1),
	 ('C42.4',3,'Hematopoietic system, NOS',1),
	 ('C44',1,'SKIN',1),
	 ('C44.0',3,'Skin of lip, NOS',1),
	 ('C44.0',2,'Skin of lower lip',1),
	 ('C44.0',2,'Skin of upper lip',1),
	 ('C44.1',2,'Canthus, NOS',1),
	 ('C44.1',2,'Upper lid',1),
	 ('C44.1',2,'Outer canthus',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.1',2,'Meibomian gland',1),
	 ('C44.1',2,'Inner canthus',1),
	 ('C44.1',2,'Palpebra',1),
	 ('C44.1',2,'Lid, NOS',1),
	 ('C44.1',3,'Eyelid',1),
	 ('C44.1',2,'Lower lid',1),
	 ('C44.2',2,'Auricular canal, NOS',1),
	 ('C44.2',2,'Tragus',1),
	 ('C44.2',2,'Skin of ear, NOS',1),
	 ('C44.2',2,'Skin of auricle',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.2',2,'Helix',1),
	 ('C44.2',2,'External auditory meatus',1),
	 ('C44.2',2,'Ear canal',1),
	 ('C44.2',2,'Concha',1),
	 ('C44.2',2,'External auricular canal',1),
	 ('C44.2',2,'Auricle, NOS',1),
	 ('C44.2',2,'Auditory canal, NOS',1),
	 ('C44.2',2,'Ear lobule',1),
	 ('C44.2',3,'External ear',1),
	 ('C44.2',2,'Pinna',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.2',2,'Ceruminal gland',1),
	 ('C44.2',2,'Ear, NOS',1),
	 ('C44.2',2,'Earlobe',1),
	 ('C44.2',2,'External auditory canal',1),
	 ('C44.3',2,'Temple, NOS',1),
	 ('C44.3',2,'Brow',1),
	 ('C44.3',2,'Ala nasi',1),
	 ('C44.3',2,'External cheek',1),
	 ('C44.3',2,'Eyebrow',1),
	 ('C44.3',2,'Columnella',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.3',2,'Chin, NOS',1),
	 ('C44.3',2,'Forehead, NOS',1),
	 ('C44.3',4,'nose',1),
	 ('C44.3',4,'jaw',1),
	 ('C44.3',4,'forehead',1),
	 ('C44.3',4,'face',1),
	 ('C44.3',4,'chin',1),
	 ('C44.3',4,'cheek',1),
	 ('C44.3',5,'Skin of:',1),
	 ('C44.3',3,'Skin of other and unspecified parts of face',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.3',2,'External nose',1),
	 ('C44.3',4,'temple',1),
	 ('C44.4',2,'Scalp, NOS',1),
	 ('C44.4',2,'Skin of cervical region',1),
	 ('C44.4',2,'Skin of scalp',1),
	 ('C44.4',2,'Skin of head, NOS',1),
	 ('C44.4',3,'Skin of scalp and neck',1),
	 ('C44.4',2,'Skin of neck',1),
	 ('C44.4',2,'Skin of supraclavicular region',1),
	 ('C44.5',4,'inguinal region',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.5',4,'perineum',1),
	 ('C44.5',2,'Umbilicus, NOS',1),
	 ('C44.5',4,'thoracic wall',1),
	 ('C44.5',4,'thorax',1),
	 ('C44.5',4,'trunk',1),
	 ('C44.5',4,'umbilicus',1),
	 ('C44.5',4,'infraclavicular region',1),
	 ('C44.5',4,'sacrococcygeal region',1),
	 ('C44.5',4,'scapular region',1),
	 ('C44.5',2,'Perianal skin',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.5',4,'chest wall',1),
	 ('C44.5',4,'gluteal region',1),
	 ('C44.5',4,'abdomen',1),
	 ('C44.5',4,'flank',1),
	 ('C44.5',4,'groin',1),
	 ('C44.5',5,'Skin of:',1),
	 ('C44.5',4,'abdominal wall',1),
	 ('C44.5',4,'anus',1),
	 ('C44.5',4,'axilla',1),
	 ('C44.5',4,'back',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.5',4,'breast',1),
	 ('C44.5',4,'buttock',1),
	 ('C44.5',4,'chest',1),
	 ('C44.5',3,'Skin of trunk',1),
	 ('C44.6',4,'elbow',1),
	 ('C44.6',4,'palm',1),
	 ('C44.6',2,'Finger nail',1),
	 ('C44.6',4,'wrist',1),
	 ('C44.6',4,'upper limb',1),
	 ('C44.6',4,'thumb',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.6',4,'shoulder',1),
	 ('C44.6',3,'Skin of upper limb and shoulder',1),
	 ('C44.6',4,'finger',1),
	 ('C44.6',2,'Palmar skin',1),
	 ('C44.6',4,'arm',1),
	 ('C44.6',4,'antecubital space',1),
	 ('C44.6',5,'Skin of:',1),
	 ('C44.6',4,'hand',1),
	 ('C44.6',4,'forearm',1),
	 ('C44.7',4,'lower limb',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.7',4,'popliteal space',1),
	 ('C44.7',4,'thigh',1),
	 ('C44.7',4,'toe',1),
	 ('C44.7',2,'Plantar skin',1),
	 ('C44.7',2,'Toe nail',1),
	 ('C44.7',4,'leg',1),
	 ('C44.7',2,'Sole of foot',1),
	 ('C44.7',4,'hip',1),
	 ('C44.7',4,'heel',1),
	 ('C44.7',4,'foot',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C44.7',4,'calf',1),
	 ('C44.7',4,'ankle',1),
	 ('C44.7',5,'Skin of:',1),
	 ('C44.7',3,'Skin of lower limb and hip',1),
	 ('C44.7',4,'knee',1),
	 ('C44.8',3,'Overlapping lesion of skin',1),
	 ('C44.9',3,'Skin, NOS',1),
	 ('C44.9',2,'C51.0, skin of vulva C51.9, skin of penis C60.9 and skin of scrotum C63.2)',1),
	 ('C47',1,'PERIPHERAL NERVES AND AUTONOMIC NERVOUS SYSTEM',1),
	 ('C47.0',4,'scalp',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.0',4,'supraclavicular region',1),
	 ('C47.0',5,'Peripheral nerves and autonomic nervous system of:',1),
	 ('C47.0',4,'pterygoid fossa',1),
	 ('C47.0',2,'Cervical plexus',1),
	 ('C47.0',4,'cervical region',1),
	 ('C47.0',4,'temple',1),
	 ('C47.0',4,'head',1),
	 ('C47.0',4,'forehead',1),
	 ('C47.0',4,'face',1),
	 ('C47.0',4,'cheek',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.0',3,'Peripheral nerves and autonomic nervous system of head, face, and neck',1),
	 ('C47.0',4,'chin',1),
	 ('C47.0',4,'neck',1),
	 ('C47.1',2,'Radial nerve',1),
	 ('C47.1',2,'Ulnar nerve',1),
	 ('C47.1',2,'Median nerve',1),
	 ('C47.1',2,'Brachial plexus',1),
	 ('C47.1',2,'Brachial nerve',1),
	 ('C47.1',4,'wrist',1),
	 ('C47.1',4,'thumb',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.1',4,'shoulder',1),
	 ('C47.1',3,'Peripheral nerves and autonomic nervous system of upper limb and shoulder',1),
	 ('C47.1',4,'forearm',1),
	 ('C47.1',4,'finger',1),
	 ('C47.1',4,'elbow',1),
	 ('C47.1',4,'arm',1),
	 ('C47.1',4,'antecubital space',1),
	 ('C47.1',5,'Peripheral nerves and autonomic nervous system of :',1),
	 ('C47.1',4,'hand',1),
	 ('C47.2',4,'popliteal space',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.2',4,'thigh',1),
	 ('C47.2',4,'toe',1),
	 ('C47.2',2,'Femoral nerve',1),
	 ('C47.2',4,'leg',1),
	 ('C47.2',2,'Sciatic nerve',1),
	 ('C47.2',4,'heel',1),
	 ('C47.2',2,'Obturator nerve',1),
	 ('C47.2',3,'Peripheral nerves and autonomic nervous system of lower limband hip',1),
	 ('C47.2',4,'hip',1),
	 ('C47.2',4,'foot',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.2',4,'calf',1),
	 ('C47.2',4,'ankle',1),
	 ('C47.2',5,'Peripheral nerves and autonomic nervous system of:',1),
	 ('C47.2',4,'knee',1),
	 ('C47.3',4,'thoracic wall',1),
	 ('C47.3',3,'Peripheral nerves and autonomic nervous system of thorax',1),
	 ('C47.3',5,'Peripheral nerves and autonomic nervous system of:',1),
	 ('C47.3',4,'axilla',1),
	 ('C47.3',4,'chest',1),
	 ('C47.3',4,'infraclavicular region',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.3',4,'scapular region',1),
	 ('C47.3',2,'Intercostal nerve',1),
	 ('C47.3',4,'chest wall',1),
	 ('C47.4',3,'Peripheral nerves and autonomic nervous system of abdomen',1),
	 ('C47.4',5,'Peripheral nerves and autonomic nervous system of:',1),
	 ('C47.4',4,'abdominal wall',1),
	 ('C47.4',4,'umbilicus',1),
	 ('C47.5',4,'buttock',1),
	 ('C47.5',2,'Sacral plexus',1),
	 ('C47.5',2,'Sacral nerve',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.5',2,'Lumbosacral plexus',1),
	 ('C47.5',4,'sacrococcygeal region',1),
	 ('C47.5',4,'inguinal region',1),
	 ('C47.5',4,'gluteal region',1),
	 ('C47.5',4,'groin',1),
	 ('C47.5',5,'Peripheral nerves and autonomic nervous system of:',1),
	 ('C47.5',3,'Peripheral nerves and autonomic nervous system of pelvis',1),
	 ('C47.5',4,'perineum',1),
	 ('C47.6',4,'trunk',1),
	 ('C47.6',4,'flank',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.6',3,'Peripheral nerves and autonomic nervous system of trunk, NOS',1),
	 ('C47.6',5,'Peripheral nerves and autonomic nervous system of:',1),
	 ('C47.6',2,'Lumbar nerve',1),
	 ('C47.6',4,'back',1),
	 ('C47.8',3,'Overlapping lesion of peripheral nerves and autonomic nervous system',1),
	 ('C47.9',2,'Sympathetic nervous system, NOS',1),
	 ('C47.9',3,'Autonomic nervous system, NOS',1),
	 ('C47.9',2,'Ganglia, NOS',1),
	 ('C47.9',2,'Nerve, NOS',1),
	 ('C47.9',2,'Parasympathetic nervous system, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C47.9',2,'Peripheral nerve, NOS',1),
	 ('C47.9',2,'Spinal nerve, NOS',1),
	 ('C48',1,'RETROPERITONEUM AND PERITONEUM',1),
	 ('C48.0',2,'Periadrenal tissue',1),
	 ('C48.0',2,'Perinephric tissue',1),
	 ('C48.0',2,'Peripancreatic tissue',1),
	 ('C48.0',2,'Perirenal tissue',1),
	 ('C48.0',2,'Retrocecal tissue',1),
	 ('C48.0',2,'Retroperitoneal tissue',1),
	 ('C48.0',3,'Retroperitoneum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C48.1',2,'Pelvic peritoneum',1),
	 ('C48.1',2,'Pouch of Douglas',1),
	 ('C48.1',2,'Cul de sac',1),
	 ('C48.1',2,'Rectouterine pouch',1),
	 ('C48.1',2,'Mesocolon',1),
	 ('C48.1',2,'Mesoappendix',1),
	 ('C48.1',2,'Mesentery',1),
	 ('C48.1',3,'Specified parts of peritoneum',1),
	 ('C48.1',2,'Omentum',1),
	 ('C48.2',3,'Peritoneum, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C48.2',2,'Peritoneal cavity',1),
	 ('C48.8',3,'Overlapping lesion of retroperitoneum and peritoneum',1),
	 ('C49',1,'CONNECTIVE, SUBCUTANEOUS AND OTHER SOFT TISSUES',1),
	 ('C49.0',4,'cervical region',1),
	 ('C49.0',4,'pterygoid fossa',1),
	 ('C49.0',4,'supraclavicular region',1),
	 ('C49.0',2,'Auricular cartilage',1),
	 ('C49.0',2,'Cartilage of ear',1),
	 ('C49.0',2,'Masseter muscle',1),
	 ('C49.0',4,'neck',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.0',2,'Sternocleidomastoid muscle',1),
	 ('C49.0',2,'Carotid artery',1),
	 ('C49.0',3,'Connective, subcutaneous and other soft tissues of head, face, and neck',1),
	 ('C49.0',4,'head',1),
	 ('C49.0',4,'forehead',1),
	 ('C49.0',4,'face',1),
	 ('C49.0',4,'chin',1),
	 ('C49.0',4,'cheek',1),
	 ('C49.0',5,'Connective, subcutaneous and other soft tissues of:',1),
	 ('C49.0',2,'C69.6 and nasal cartilage C30.0)',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.0',4,'scalp',1),
	 ('C49.0',4,'temple',1),
	 ('C49.1',2,'Biceps brachii muscle',1),
	 ('C49.1',2,'Brachialis muscle',1),
	 ('C49.1',2,'Coracobrachialis muscle',1),
	 ('C49.1',2,'Palmar aponeurosis',1),
	 ('C49.1',2,'Radial artery',1),
	 ('C49.1',2,'Triceps brachii muscle',1),
	 ('C49.1',2,'Ulnar artery',1),
	 ('C49.1',4,'wrist',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.1',2,'Deltoideus muscle',1),
	 ('C49.1',4,'antecubital space',1),
	 ('C49.1',5,'Connective, subcutaneous and other soft tissues of:',1),
	 ('C49.1',4,'arm',1),
	 ('C49.1',4,'thumb',1),
	 ('C49.1',4,'elbow',1),
	 ('C49.1',3,'Connective, subcutaneous and other soft tissues of upper limb and shoulder',1),
	 ('C49.1',4,'finger',1),
	 ('C49.1',4,'forearm',1),
	 ('C49.1',4,'hand',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.1',4,'shoulder',1),
	 ('C49.1',2,'Palmar fascia',1),
	 ('C49.2',4,'knee',1),
	 ('C49.2',4,'thigh',1),
	 ('C49.2',2,'Quadriceps femoris muscle',1),
	 ('C49.2',2,'Plantar fascia',1),
	 ('C49.2',2,'Plantar aponeurosis',1),
	 ('C49.2',2,'Gastrocnemius muscle',1),
	 ('C49.2',2,'Femoral artery',1),
	 ('C49.2',2,'Biceps femoris muscle',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.2',4,'toe',1),
	 ('C49.2',5,'Connective, subcutaneous and other soft tissues of:',1),
	 ('C49.2',4,'popliteal space',1),
	 ('C49.2',3,'Connective, subcutaneous and other soft tissues of lower limb and hip',1),
	 ('C49.2',4,'ankle',1),
	 ('C49.2',4,'calf',1),
	 ('C49.2',4,'foot',1),
	 ('C49.2',4,'heel',1),
	 ('C49.2',4,'hip',1),
	 ('C49.2',4,'leg',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.3',2,'Aorta, NOS',1),
	 ('C49.3',2,'Pectoralis major muscle',1),
	 ('C49.3',2,'Subclavian artery',1),
	 ('C49.3',2,'Trapezius muscle',1),
	 ('C49.3',2,'Latissimus dorsi muscle',1),
	 ('C49.3',2,'Internal mammary artery',1),
	 ('C49.3',2,'Intercostal muscle',1),
	 ('C49.3',2,'Diaphragm',1),
	 ('C49.3',2,'Axillary artery',1),
	 ('C49.3',2,'Thoracic duct',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.3',2,'C38._)',1),
	 ('C49.3',4,'scapular region',1),
	 ('C49.3',3,'Connective, subcutaneous and other soft tissues of thorax',1),
	 ('C49.3',5,'Connective, subcutaneous and other soft tissues of :',1),
	 ('C49.3',4,'axilla',1),
	 ('C49.3',4,'chest',1),
	 ('C49.3',4,'chest wall',1),
	 ('C49.3',4,'thorax',1),
	 ('C49.3',4,'thoracic wall',1),
	 ('C49.3',4,'infraclavicular region',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.3',2,'Superior vena cava',1),
	 ('C49.4',4,'umbilicus',1),
	 ('C49.4',2,'Celiac artery',1),
	 ('C49.4',2,'Renal artery',1),
	 ('C49.4',2,'Rectus abdominis muscle',1),
	 ('C49.4',2,'Psoas muscle',1),
	 ('C49.4',2,'Mesenteric artery',1),
	 ('C49.4',2,'Inferior vena cava',1),
	 ('C49.4',2,'Iliopsoas muscle',1),
	 ('C49.4',2,'Abdominal wall muscle',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.4',2,'Abdominal aorta',1),
	 ('C49.4',2,'Vena cava, NOS',1),
	 ('C49.4',4,'abdominal wall',1),
	 ('C49.4',4,'abdomen',1),
	 ('C57.1',2,'Mesovarium',1),
	 ('C49.4',5,'Connective, subcutaneous and other soft tissues of :',1),
	 ('C49.4',3,'Connective, subcutaneous and other soft tissues of abdomen',1),
	 ('C49.4',2,'Abdominal vena cava',1),
	 ('C49.5',4,'inguinal region',1),
	 ('C49.5',2,'Iliac artery',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.5',2,'Iliac vein',1),
	 ('C49.5',2,'Gluteus maximus muscle',1),
	 ('C49.5',4,'sacrococcygeal region',1),
	 ('C49.5',4,'perineum',1),
	 ('C49.5',4,'groin',1),
	 ('C49.5',4,'buttock',1),
	 ('C49.5',3,'Connective, subcutaneous and other soft tissues of pelvis',1),
	 ('C49.5',5,'Connective, subcutaneous and other soft tissues of:',1),
	 ('C49.5',4,'gluteal region',1),
	 ('C49.6',4,'trunk',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.6',3,'Connective, subcutaneous and other soft tissues of trunk NOS',1),
	 ('C49.6',5,'Connective, subcutaneous and other soft tissues of:',1),
	 ('C49.6',4,'back',1),
	 ('C49.6',4,'flank',1),
	 ('C49.8',3,'Overlapping lesion of connective, subcutaneous and other soft tissues',1),
	 ('C49.9',2,'Lymphatic, NOS',1),
	 ('C49.9',2,'Vein, NOS',1),
	 ('C49.9',2,'Tendon sheath, NOS',1),
	 ('C49.9',2,'Tendon, NOS',1),
	 ('C49.9',2,'Aponeurosis, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.9',2,'Synovia, NOS',1),
	 ('C49.9',2,'Subcutaneous tissue, NOS',1),
	 ('C49.9',2,'Skeletal muscle, NOS',1),
	 ('C49.9',2,'Muscle, NOS',1),
	 ('C49.9',2,'Vessel, NOS',1),
	 ('C49.9',2,'Fibrous tissue, NOS',1),
	 ('C49.9',2,'Fatty tissue, NOS',1),
	 ('C49.9',2,'Fascia, NOS',1),
	 ('C49.9',2,'Connective tissue, NOS',1),
	 ('C49.9',2,'Bursa, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C49.9',2,'Artery, NOS',1),
	 ('C49.9',2,'Blood vessel, NOS',1),
	 ('C49.9',2,'Adipose tissue, NOS',1),
	 ('C49.9',3,'Connective, subcutaneous and other soft tissues, NOS',1),
	 ('C49.9',2,'Ligament, NOS',1),
	 ('C50',1,'BREAST',1),
	 ('C50.0',3,'Nipple',1),
	 ('C50.0',2,'Areola',1),
	 ('C50.1',3,'Central portion of breast',1),
	 ('C50.2',3,'Upper-inner quadrant of breast',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C50.3',3,'Lower-inner quadrant of breast',1),
	 ('C50.4',3,'Upper-outer quadrant of breast',1),
	 ('C50.5',3,'Lower-outer quadrant of breast',1),
	 ('C50.6',3,'Axillary tail of breast',1),
	 ('C50.6',2,'Tail of breast, NOS',1),
	 ('C50.8',3,'Overlapping lesion of breast',1),
	 ('C50.8',2,'Upper breast',1),
	 ('C50.8',2,'Outer breast',1),
	 ('C50.8',2,'Inner breast',1),
	 ('C50.8',2,'Lower breast',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C50.8',2,'Midline of breast',1),
	 ('C50.9',3,'Breast, NOS',1),
	 ('C50.9',2,'Mammary gland',1),
	 ('C51',1,'VULVA',1),
	 ('C51.0',2,'Bartholin gland',1),
	 ('C51.0',2,'Skin of labia majora',1),
	 ('C51.0',2,'Labia majora, NOS',1),
	 ('C51.0',3,'Labium majus',1),
	 ('C51.1',2,'Labia minora',1),
	 ('C51.1',3,'Labium minus',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C51.2',3,'Clitoris',1),
	 ('C51.8',3,'Overlapping lesion of vulva',1),
	 ('C51.9',2,'Fourchette',1),
	 ('C51.9',2,'Skin of vulva',1),
	 ('C51.9',2,'Pudendum',1),
	 ('C51.9',2,'Mons veneris',1),
	 ('C51.9',2,'Mons pubis',1),
	 ('C51.9',2,'Labia, NOS',1),
	 ('C51.9',2,'External female genitalia',1),
	 ('C51.9',3,'Vulva, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C51.9',2,'Labium, NOS',1),
	 ('C52',1,'VAGINA',1),
	 ('C52.9',2,'Hymen',1),
	 ('C52.9',3,'Vagina, NOS',1),
	 ('C52.9',2,'Vaginal vault',1),
	 ('C52.9',2,'Fornix of vagina',1),
	 ('C52.9',2,'Gartner duct',1),
	 ('C53',1,'CERVIX UTERI',1),
	 ('C53.0',2,'Internal os',1),
	 ('C53.0',2,'Cervical canal',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C53.0',2,'Endocervical canal',1),
	 ('C53.0',2,'Endocervical gland',1),
	 ('C53.0',2,'Nabothian gland',1),
	 ('C53.0',3,'Endocervix',1),
	 ('C53.1',2,'External os',1),
	 ('C53.1',3,'Exocervix',1),
	 ('C53.8',2,'Squamocolumnar junction of cervix',1),
	 ('C53.8',2,'Cervical stump',1),
	 ('C53.8',3,'Overlapping lesion of cervix uteri',1),
	 ('C53.9',3,'Cervix uteri',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C53.9',2,'Cervix, NOS',1),
	 ('C53.9',2,'Uterine cervix',1),
	 ('C54',1,'CORPUS UTERI',1),
	 ('C54.0',3,'Isthmus uteri',1),
	 ('C54.0',2,'Lower uterine segment',1),
	 ('C54.1',3,'Endometrium',1),
	 ('C54.1',2,'Endometrial gland',1),
	 ('C54.1',2,'Endometrial stroma',1),
	 ('C54.2',3,'Myometrium',1),
	 ('C54.3',3,'Fundus uteri',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C54.8',3,'Overlapping lesion of corpus uteri',1),
	 ('C54.9',3,'Corpus uteri',1),
	 ('C54.9',2,'Body of uterus',1),
	 ('C55',1,'UTERUS, NOS',1),
	 ('C55.9',3,'Uterus, NOS',1),
	 ('C55.9',2,'Uterine, NOS',1),
	 ('C56',1,'OVARY',1),
	 ('C56.9',3,'Ovary',1),
	 ('C57',1,'OTHER AND UNSPECIFIED FEMALE GENITAL ORGANS',1),
	 ('C57.0',3,'Fallopian tube',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C57.0',2,'Uterine tube',1),
	 ('C57.1',3,'Broad ligament',1),
	 ('C57.1',2,'Parovarian region',1),
	 ('C57.2',3,'Round ligament',1),
	 ('C57.3',2,'Uterosacral ligament',1),
	 ('C57.3',3,'Parametrium',1),
	 ('C57.3',2,'Uterine ligament',1),
	 ('C57.4',3,'Uterine adnexa',1),
	 ('C57.4',2,'Adnexa, NOS',1),
	 ('C57.7',3,'Other specified parts of female genital organs',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C57.7',2,'Wolffian body',1),
	 ('C57.7',2,'Wolffian duct',1),
	 ('C57.8',2,'Utero-ovarian',1),
	 ('C57.8',2,'Tubo-ovarian',1),
	 ('C57.8',3,'Overlapping lesion of female genital organs',1),
	 ('C57.9',2,'Female genital organs, NOS',1),
	 ('C57.9',2,'Female genitourinary tract, NOS',1),
	 ('C57.9',2,'Urethrovaginal septum',1),
	 ('C57.9',2,'Vesicocervical tissue',1),
	 ('C57.9',2,'Vesicovaginal septum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C57.9',3,'Female genital tract, NOS',1),
	 ('C58',1,'PLACENTA',1),
	 ('C58.9',2,'Fetal membranes',1),
	 ('C58.9',3,'Placenta',1),
	 ('C60',1,'PENIS',1),
	 ('C60.0',2,'Foreskin',1),
	 ('C60.0',3,'Prepuce',1),
	 ('C60.1',3,'Glans penis',1),
	 ('C60.2',3,'Body of penis',1),
	 ('C60.2',2,'Corpus cavernosum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C60.2',2,'Corpus of penis',1),
	 ('C60.8',3,'Overlapping lesion of penis',1),
	 ('C60.9',3,'Penis, NOS',1),
	 ('C61',1,'PROSTATE GLAND',1),
	 ('C61.9',3,'Prostate gland',1),
	 ('C61.9',2,'Prostate, NOS',1),
	 ('C62',1,'TESTIS',1),
	 ('C62.0',3,'Undescended testis',1),
	 ('C62.0',2,'Retained testis (site of neoplasm)',1),
	 ('C62.0',2,'Ectopic testis (site of neoplasm)',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C62.1',3,'Descended testis',1),
	 ('C62.1',2,'Scrotal testis',1),
	 ('C62.9',2,'Testicle, NOS',1),
	 ('C62.9',3,'Testis, NOS',1),
	 ('C63',1,'OTHER AND UNSPECIFIED MALE GENITAL ORGANS',1),
	 ('C63.0',3,'Epididymis',1),
	 ('C63.1',3,'Spermatic cord',1),
	 ('C63.1',2,'Vas deferens',1),
	 ('C63.2',3,'Scrotum, NOS',1),
	 ('C63.2',2,'Skin of scrotum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C63.7',3,'Other specified parts of male genital organs',1),
	 ('C63.7',2,'Seminal vesicle',1),
	 ('C63.7',2,'Tunica vaginalis',1),
	 ('C63.8',3,'Overlapping lesion of male genital organs Note:',1),
	 ('C63.9',2,'Male genitourinary tract, NOS',1),
	 ('C63.9',2,'Male genital tract, NOS',1),
	 ('C63.9',3,'Male genital organs, NOS',1),
	 ('C64',1,'KIDNEY',1),
	 ('C64.9',3,'Kidney, NOS',1),
	 ('C64.9',2,'Renal, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C64.9',2,'Kidney parenchyma',1),
	 ('C65',1,'RENAL PELVIS',1),
	 ('C65.9',2,'Renal calyces',1),
	 ('C65.9',2,'Renal calyx',1),
	 ('C65.9',2,'Pelvis of kidney',1),
	 ('C65.9',3,'Renal pelvis',1),
	 ('C65.9',2,'Pelviureteric junction',1),
	 ('C66',1,'URETER',1),
	 ('C66.9',3,'Ureter',1),
	 ('C67',1,'BLADDER',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C67.0',3,'Trigone of bladder',1),
	 ('C67.1',3,'Dome of bladder',1),
	 ('C67.2',3,'Lateral wall of bladder',1),
	 ('C67.3',3,'Anterior wall of bladder',1),
	 ('C67.4',3,'Posterior wall of bladder',1),
	 ('C67.5',3,'Bladder neck',1),
	 ('C67.5',2,'Internal urethral orifice',1),
	 ('C67.6',3,'Ureteric orifice',1),
	 ('C67.7',3,'Urachus',1),
	 ('C67.8',3,'Overlapping lesion of bladder',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C67.9',3,'Bladder, NOS',1),
	 ('C67.9',2,'Bladder wall, NOS',1),
	 ('C67.9',2,'Urinary bladder, NOS',1),
	 ('C68',1,'OTHER AND UNSPECIFIED URINARY ORGANS',1),
	 ('C68.0',3,'Urethra',1),
	 ('C68.0',2,'Urethral gland',1),
	 ('C68.0',2,'Cowper gland',1),
	 ('C68.0',2,'Prostatic utricle',1),
	 ('C68.1',3,'Paraurethral gland',1),
	 ('C68.8',3,'Overlapping lesion of urinary organs',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C68.9',3,'Urinary system, NOS',1),
	 ('C69',1,'EYE AND ADNEXA',1),
	 ('C69.0',3,'Conjunctiva',1),
	 ('C69.1',3,'Cornea, NOS',1),
	 ('C69.1',2,'Limbus of cornea',1),
	 ('C69.2',3,'Retina',1),
	 ('C69.3',3,'Choroid',1),
	 ('C69.4',2,'Crystalline lens',1),
	 ('C69.4',2,'Iris',1),
	 ('C69.4',2,'Sclera',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C69.4',2,'Uveal tract',1),
	 ('C69.4',2,'Intraocular',1),
	 ('C69.4',2,'Eyeball',1),
	 ('C69.4',3,'Ciliary body',1),
	 ('C69.5',2,'Lacrimal duct, NOS',1),
	 ('C69.5',2,'Lacrimal sac',1),
	 ('C69.5',2,'Nasal lacrimal duct',1),
	 ('C69.5',3,'Lacrimal gland',1),
	 ('C69.5',2,'Nasolacrimal duct',1),
	 ('C69.6',3,'Orbit, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C69.6',2,'Autonomic nervous system of orbit',1),
	 ('C69.6',2,'Connective tissue of orbit',1),
	 ('C69.6',2,'Extraocular muscle',1),
	 ('C69.6',2,'Peripheral nerves of orbit',1),
	 ('C69.6',2,'Retrobulbar tissue',1),
	 ('C69.6',2,'Soft tissue of orbit',1),
	 ('C69.8',3,'Overlapping lesion of eye and adnexa',1),
	 ('C69.9',3,'Eye, NOS',1),
	 ('C70',1,'MENINGES',1),
	 ('C70.0',2,'Falx, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C70.0',2,'Tentorium, NOS',1),
	 ('C70.0',2,'Tentorium cerebelli',1),
	 ('C70.0',2,'Intracranial arachnoid',1),
	 ('C70.0',2,'Falx cerebri',1),
	 ('C70.0',2,'Falx cerebelli',1),
	 ('C70.0',2,'Cranial pia mater',1),
	 ('C70.0',2,'Cranial meninges',1),
	 ('C70.0',2,'Cranial dura mater',1),
	 ('C70.0',3,'Cerebral meninges',1),
	 ('C70.0',2,'Intracranial meninges',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C70.1',3,'Spinal meninges',1),
	 ('C70.1',2,'Spinal arachnoid',1),
	 ('C70.1',2,'Spinal dura mater',1),
	 ('C70.1',2,'Spinal pia mater',1),
	 ('C70.9',2,'Dura mater, NOS',1),
	 ('C70.9',2,'Pia mater, NOS',1),
	 ('C70.9',2,'Arachnoid, NOS',1),
	 ('C70.9',3,'Meninges, NOS',1),
	 ('C70.9',2,'Dura, NOS',1),
	 ('C71',1,'BRAIN',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C71.0',2,'Corpus striatum',1),
	 ('C71.0',2,'Thalamus',1),
	 ('C71.0',2,'Supratentorial brain, NOS',1),
	 ('C71.0',2,'Rhinencephalon',1),
	 ('C71.0',2,'Putamen',1),
	 ('C71.0',2,'Pallium',1),
	 ('C71.0',2,'Operculum',1),
	 ('C71.0',2,'Island of Reil',1),
	 ('C71.0',2,'Internal capsule',1),
	 ('C71.0',2,'Insula',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C71.0',2,'Globus pallidus',1),
	 ('C71.0',2,'Cerebral white matter',1),
	 ('C71.0',2,'Cerebral hemisphere',1),
	 ('C71.0',2,'Cerebral cortex',1),
	 ('C71.0',2,'Central white matter',1),
	 ('C71.0',2,'Basal ganglia',1),
	 ('C71.0',3,'Cerebrum',1),
	 ('C71.0',2,'Hypothalamus',1),
	 ('C71.1',3,'Frontal lobe',1),
	 ('C71.1',2,'Frontal pole',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C71.2',2,'Hippocampus',1),
	 ('C71.2',2,'Uncus',1),
	 ('C71.2',3,'Temporal lobe',1),
	 ('C71.3',3,'Parietal lobe',1),
	 ('C71.4',3,'Occipital lobe',1),
	 ('C71.4',2,'Occipital pole',1),
	 ('C71.5',2,'Choroid plexus of third ventricle',1),
	 ('C71.5',2,'Third ventricle, NOS',1),
	 ('C71.5',2,'Ependyma',1),
	 ('C71.5',2,'Choroid plexus of lateral ventricle',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C71.5',2,'Choroid plexus, NOS',1),
	 ('C71.5',2,'Cerebral ventricle',1),
	 ('C71.5',3,'Ventricle, NOS',1),
	 ('C71.5',2,'Lateral ventricle, NOS',1),
	 ('C71.6',3,'Cerebellum, NOS',1),
	 ('C71.6',2,'Cerebellopontine angle',1),
	 ('C71.6',2,'Vermis of cerebellum',1),
	 ('C71.7',2,'Choroid plexus of fourth ventricle',1),
	 ('C71.7',2,'Pyramid',1),
	 ('C71.7',2,'Pons',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C71.7',2,'Olive',1),
	 ('C71.7',2,'Midbrain',1),
	 ('C71.7',2,'Medulla oblongata',1),
	 ('C71.7',2,'Basis pedunculi',1),
	 ('C71.7',2,'Cerebral peduncle',1),
	 ('C71.7',3,'Brain stem',1),
	 ('C71.7',2,'Fourth ventricle, NOS',1),
	 ('C71.7',2,'Infratentorial brain, NOS',1),
	 ('C71.8',3,'Overlapping lesion of brain',1),
	 ('C71.8',2,'Corpus callosum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C71.8',2,'Tapetum',1),
	 ('C71.9',2,'Intracranial site',1),
	 ('C71.9',2,'Suprasellar',1),
	 ('C71.9',2,'Posterior cranial fossa',1),
	 ('C71.9',2,'Middle cranial fossa',1),
	 ('C71.9',2,'Cranial fossa, NOS',1),
	 ('C71.9',3,'Brain, NOS',1),
	 ('C71.9',2,'Anterior cranial fossa',1),
	 ('C72',1,'SPINAL CORD, CRANIAL NERVES, AND OTHER PARTS OF CENTRAL NERVOUS SYSTEM',1),
	 ('C72.0',2,'Cervical cord',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C72.0',2,'Sacral cord',1),
	 ('C72.0',2,'Thoracic cord',1),
	 ('C72.0',2,'Lumbar cord',1),
	 ('C72.0',3,'Spinal cord',1),
	 ('C72.0',2,'Filum terminale',1),
	 ('C72.0',2,'Conus medullaris',1),
	 ('C72.1',3,'Cauda equina',1),
	 ('C72.2',3,'Olfactory nerve',1),
	 ('C72.3',3,'Optic nerve',1),
	 ('C72.3',2,'Optic chiasm',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C72.3',2,'Optic tract',1),
	 ('C72.4',3,'Acoustic nerve',1),
	 ('C72.5',3,'Cranial nerve, NOS',1),
	 ('C72.5',2,'Trochlear nerve',1),
	 ('C72.5',2,'Trigeminal nerve',1),
	 ('C72.5',2,'Oculomotor nerve',1),
	 ('C72.5',2,'Hypoglossal nerve',1),
	 ('C72.5',2,'Glossopharyngeal nerve',1),
	 ('C72.5',2,'Facial nerve',1),
	 ('C72.5',2,'Spinal accessory nerve',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C72.5',2,'Abducens nerve',1),
	 ('C72.5',2,'Vagus nerve',1),
	 ('C72.5',2,'Accessory nerve, NOS',1),
	 ('C72.8',3,'Overlapping lesion of brain and central nervous system',1),
	 ('C72.9',3,'Nervous system, NOS',1),
	 ('C72.9',2,'Central nervous system',1),
	 ('C72.9',2,'Epidural',1),
	 ('C72.9',2,'Extradural',1),
	 ('C72.9',2,'Parasellar',1),
	 ('C73',1,'THYROID GLAND',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C73.9',2,'Thyroglossal duct',1),
	 ('C73.9',3,'Thyroid gland',1),
	 ('C73.9',2,'Thyroid, NOS',1),
	 ('C74',1,'ADRENAL GLAND',1),
	 ('C74.0',3,'Cortex of adrenal gland',1),
	 ('C74.1',3,'Medulla of adrenal gland',1),
	 ('C74.9',3,'Adrenal gland, NOS',1),
	 ('C74.9',2,'Suprarenal gland',1),
	 ('C74.9',2,'Adrenal, NOS',1),
	 ('C75',1,'OTHER ENDOCRINE GLANDS AND RELATED STRUCTURES',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C75.0',3,'Parathyroid gland',1),
	 ('C75.1',2,'Pituitary, NOS',1),
	 ('C75.1',2,'Sella turcica',1),
	 ('C75.1',2,'Pituitary fossa',1),
	 ('C75.1',3,'Pituitary gland',1),
	 ('C75.1',2,'Hypophysis',1),
	 ('C75.1',2,'Rathke pouch',1),
	 ('C75.2',3,'Craniopharyngeal duct',1),
	 ('C75.3',3,'Pineal gland',1),
	 ('C75.4',3,'Carotid body',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C75.5',2,'Glomus jugulare',1),
	 ('C75.5',2,'Paraganglion',1),
	 ('C75.5',2,'Para-aortic body',1),
	 ('C75.5',2,'Coccygeal glomus',1),
	 ('C75.5',2,'Coccygeal body',1),
	 ('C75.5',3,'Aortic body and other paraganglia',1),
	 ('C75.5',2,'Organ of Zuckerkandl',1),
	 ('C75.8',3,'Overlapping lesion of endocrine glands and related structures',1),
	 ('C75.8',2,'Multiple endocrine glands',1),
	 ('C75.8',2,'Pluriglandular',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C75.9',3,'Endocrine gland, NOS',1),
	 ('C76',1,'OTHER AND ILL-DEFINED SITES',1),
	 ('C76.0',2,'Cheek, NOS',1),
	 ('C76.0',2,'Cervical region, NOS',1),
	 ('C76.0',2,'Supraclavicular region, NOS',1),
	 ('C76.0',2,'Jaw, NOS',1),
	 ('C76.0',3,'Head, face or neck, NOS',1),
	 ('C76.0',2,'Nose, NOS',1),
	 ('C76.1',2,'Infraclavicular region, NOS',1),
	 ('C76.1',2,'Scapular region, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C76.1',2,'Thoracic wall, NOS',1),
	 ('C76.1',2,'Intrathoracic site, NOS',1),
	 ('C76.1',2,'Chest wall, NOS',1),
	 ('C76.1',2,'Chest, NOS',1),
	 ('C76.1',2,'Axilla, NOS',1),
	 ('C76.1',3,'Thorax, NOS',1),
	 ('C76.2',2,'Abdominal wall, NOS',1),
	 ('C76.2',2,'Intra-abdominal site, NOS',1),
	 ('C76.2',3,'Abdomen, NOS',1),
	 ('C76.3',2,'Rectovesical septum',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C76.3',2,'Sacrococcygeal region, NOS',1),
	 ('C76.3',2,'Presacral region, NOS',1),
	 ('C76.3',2,'Perirectal region, NOS',1),
	 ('C76.3',2,'Inguinal region, NOS',1),
	 ('C76.3',2,'Rectovaginal septum',1),
	 ('C76.3',2,'Perineum, NOS',1),
	 ('C76.3',2,'Pelvic wall, NOS',1),
	 ('C76.3',2,'Ischiorectal fossa',1),
	 ('C76.3',2,'Groin, NOS',1),
	 ('C76.3',2,'Buttock, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C76.3',3,'Pelvis, NOS',1),
	 ('C76.3',2,'Gluteal region, NOS',1),
	 ('C76.4',2,'Elbow, NOS',1),
	 ('C76.4',2,'Wrist, NOS',1),
	 ('C76.4',2,'Thumb, NOS',1),
	 ('C76.4',2,'Shoulder, NOS',1),
	 ('C76.4',2,'Hand, NOS',1),
	 ('C76.4',2,'Finger, NOS',1),
	 ('C76.4',2,'Arm, NOS',1),
	 ('C76.4',2,'Antecubital space, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C76.4',3,'Upper limb, NOS',1),
	 ('C76.4',2,'Forearm, NOS',1),
	 ('C76.5',2,'Foot, NOS',1),
	 ('C76.5',2,'Toe, NOS',1),
	 ('C76.5',2,'Thigh, NOS',1),
	 ('C76.5',2,'Popliteal space, NOS',1),
	 ('C76.5',2,'Leg, NOS',1),
	 ('C76.5',2,'Knee, NOS',1),
	 ('C76.5',2,'Hip, NOS',1),
	 ('C76.5',2,'Calf, NOS',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C76.5',2,'Ankle, NOS',1),
	 ('C76.5',3,'Lower limb, NOS',1),
	 ('C76.5',2,'Heel, NOS',1),
	 ('C76.7',3,'Other ill-defined sites',1),
	 ('C76.7',2,'Back, NOS',1),
	 ('C76.7',2,'Flank, NOS',1),
	 ('C76.7',2,'Trunk, NOS',1),
	 ('C76.8',3,'Overlapping lesion of ill-defined sites',1),
	 ('C77',1,'LYMPH NODES',1),
	 ('C77.0',2,'Parotid lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.0',2,'Submaxillary lymph node',1),
	 ('C77.0',2,'Submandibular lymph node',1),
	 ('C77.0',2,'Sublingual lymph node',1),
	 ('C77.0',2,'Scalene lymph node',1),
	 ('C77.0',2,'Retropharyngeal lymph node',1),
	 ('C77.0',2,'Pretracheal lymph node',1),
	 ('C77.0',2,'Supraclavicular lymph node',1),
	 ('C77.0',2,'Submental lymph node',1),
	 ('C77.0',3,'Lymph nodes of head, face and neck',1),
	 ('C77.0',2,'Preauricular lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.0',2,'Auricular lymph node',1),
	 ('C77.0',2,'Cervical lymph node',1),
	 ('C77.0',2,'Facial lymph node',1),
	 ('C77.0',2,'Jugular lymph node',1),
	 ('C77.0',2,'Mandibular lymph node',1),
	 ('C77.0',2,'Occipital lymph node',1),
	 ('C77.0',2,'Prelaryngeal lymph node',1),
	 ('C77.1',2,'Mediastinal lymph node',1),
	 ('C77.1',2,'Intercostal lymph node',1),
	 ('C77.1',2,'Tracheobronchial lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.1',2,'Tracheal lymph node',1),
	 ('C77.1',2,'Thoracic lymph node',1),
	 ('C77.1',2,'Pulmonary lymph node, NOS',1),
	 ('C77.1',2,'Parasternal lymph node',1),
	 ('C77.1',2,'Hilar lymph node, NOS',1),
	 ('C77.1',2,'Esophageal lymph node',1),
	 ('C77.1',2,'Diaphragmatic lymph node',1),
	 ('C77.1',2,'Bronchopulmonary lymph node',1),
	 ('C77.1',2,'Bronchial lymph node',1),
	 ('C77.1',2,'Innominate lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.1',2,'Pulmonary hilar lymph node',1),
	 ('C77.1',3,'Intrathoracic lymph nodes',1),
	 ('C77.2',2,'Splenic lymph node, NOS',1),
	 ('C77.2',2,'Midcolic lymph node',1),
	 ('C77.2',2,'Pancreatic lymph node, NOS',1),
	 ('C77.2',2,'Para-aortic lymph node',1),
	 ('C77.2',2,'Superior mesenteric lymph node',1),
	 ('C77.2',2,'Peripancreatic lymph node',1),
	 ('C77.2',2,'Portal lymph node',1),
	 ('C77.2',2,'Retroperitoneal lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.2',2,'Splenic hilar lymph node',1),
	 ('C77.2',2,'Mesenteric lymph node, NOS',1),
	 ('C77.2',2,'Periaortic lymph node',1),
	 ('C77.2',2,'Pyloric lymph node',1),
	 ('C77.2',2,'Celiac lymph node',1),
	 ('C77.2',2,'Lumbar lymph node',1),
	 ('C77.2',2,'Porta hepatis lymph node',1),
	 ('C77.2',3,'Intra-abdominal lymph nodes',1),
	 ('C77.2',2,'Aortic lymph node',1),
	 ('C77.2',2,'Colic lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.2',2,'Common duct lymph node',1),
	 ('C77.2',2,'Gastric lymph node',1),
	 ('C77.2',2,'Hepatic lymph node',1),
	 ('C77.2',2,'Ileocolic lymph node',1),
	 ('C77.2',2,'Inferior mesenteric lymph node',1),
	 ('C77.2',2,'Intestinal lymph node',1),
	 ('C77.2',2,'Abdominal lymph node',1),
	 ('C77.3',3,'Lymph nodes of axilla or arm',1),
	 ('C77.3',2,'Infraclavicular lymph node',1),
	 ('C77.3',2,'Subclavicular lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.3',2,'Pectoral lymph node',1),
	 ('C77.3',2,'Lymph node of upper limb',1),
	 ('C77.3',2,'Epitrochlear lymph node',1),
	 ('C77.3',2,'Cubital lymph node',1),
	 ('C77.3',2,'Axillary lymph node',1),
	 ('C77.3',2,'Subscapular lymph node',1),
	 ('C77.3',2,'Brachial lymph node',1),
	 ('C77.4',2,'Lymph node of lower limb',1),
	 ('C77.4',2,'Subinguinal lymph node',1),
	 ('C77.4',2,'Tibial lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.4',2,'Popliteal lymph node',1),
	 ('C77.4',2,'Lymph node of Rosenmuller',1),
	 ('C77.4',2,'Lymph node of Cloquet',1),
	 ('C77.4',2,'Inguinal lymph node',1),
	 ('C77.4',3,'Lymph nodes of inguinal region or leg',1),
	 ('C77.4',2,'Lymph node of groin',1),
	 ('C77.4',2,'Femoral lymph node',1),
	 ('C77.5',2,'Inferior epigastric lymph node',1),
	 ('C77.5',2,'Sacral lymph node',1),
	 ('C77.5',2,'Presymphysial lymph node',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C77.5',2,'Parametrial lymph node',1),
	 ('C77.5',2,'Paracervical lymph node',1),
	 ('C77.5',2,'Intrapelvic lymph node',1),
	 ('C77.5',2,'Iliac lymph node',1),
	 ('C77.5',2,'Hypogastric lymph node',1),
	 ('C77.5',3,'Pelvic lymph nodes',1),
	 ('C77.5',2,'Obturator lymph node',1),
	 ('C77.8',3,'Lymph nodes of multiple regions',1),
	 ('C77.9',3,'Lymph node, NOS',1),
	 ('C80',1,'UNKNOWN PRIMARY SITE',1);
INSERT INTO public.icd_o_topo (topo_code,topo_level_id,topo_term,topo_version) VALUES
	 ('C80.9',3,'Unknown primary site',1);


INSERT INTO public.icd_o_topo_api_disease (api_disease_id,icd_o_topo_id) VALUES
	 (40,187),
	 (39,187),
	 (36,210),
	 (35,210),
	 (38,218),
	 (37,218),
	 (15,239),
	 (16,247),
	 (17,250),
	 (48,261);
INSERT INTO public.icd_o_topo_api_disease (api_disease_id,icd_o_topo_id) VALUES
	 (47,296),
	 (5,371),
	 (4,371),
	 (3,371),
	 (2,371),
	 (1,371),
	 (9,617),
	 (8,617),
	 (7,617),
	 (10,617);
INSERT INTO public.icd_o_topo_api_disease (api_disease_id,icd_o_topo_id) VALUES
	 (6,617),
	 (13,871),
	 (11,871),
	 (12,871),
	 (44,910),
	 (43,915),
	 (46,927),
	 (45,954),
	 (22,966),
	 (21,966);
INSERT INTO public.icd_o_topo_api_disease (api_disease_id,icd_o_topo_id) VALUES
	 (24,966),
	 (50,974),
	 (49,974),
	 (18,989),
	 (20,989),
	 (19,989),
	 (34,1011),
	 (33,1011),
	 (32,1011),
	 (31,1011);
INSERT INTO public.icd_o_topo_api_disease (api_disease_id,icd_o_topo_id) VALUES
	 (51,1127),
	 (42,1163),
	 (41,1172),
	 (14,239),
	 (14,247),
	 (14,250),
	 (25,1339),
	 (26,1339),
	 (27,498),
	 (28,498);
INSERT INTO public.icd_o_topo_api_disease (api_disease_id,icd_o_topo_id) VALUES
	 (29,498),
	 (30,498),
	 (64,927),
	 (66,999),
	 (23,987),
	 (52,1197);