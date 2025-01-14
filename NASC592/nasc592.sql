--
-- load the NASC592 data into bartonlab
--

--
-- the experiment schema
--
DROP schema nasc592 CASCADE;
CREATE schema nasc592;

--
-- experiments (insert row in public table)
--
DELETE FROM experiments WHERE schema='nasc592';
INSERT INTO experiments VALUES (
'nasc592',
'Coordination of meristem and boundary functions by transcription factors in the SHOOT MERISTEMLESS regulatory network',
'Our findings highlight the central role of the STM GRN in coordinating SAM functions',
'Plants were grown in vitro (continuous white light, 22 o C) on GM (4.4g/L MS salts, 1.5% sucrose, 1% agar). Induction was by transfer to medium with 60 μM dexamethasone (DEX) or application of DEX solution (60μM) to agar surface (short-term experiments). To induce p35S::STM-GR (Brand et al., 2002), 60μM cycloheximide was added with DEX when applicable.',
NULL,
NULL,
29650590,
'RMA intensity',
'Scofield S, Murison A, Jones A, Fozard J, Aida M, Band LR, Bennett M, Murray JAH',
true,
'Microarray',
'TAIR10',
'Arabidopsis',
'thaliana'
);

--
-- nasc592.limmaresults
--
CREATE TABLE nasc592.limmaresults () INHERITS (public.limmaresults);
COPY nasc592.limmaresults (probe_set_id,logfc,aveexpr,t,pvalue,adjpvalue,b) FROM
'/home/shokin/BartonLab/NASC592/res.DEXvMOCK.tsv'
WITH CSV HEADER DELIMITER AS '	';
UPDATE nasc592.limmaresults SET decondition='DEX',basecondition='MOCK' WHERE decondition IS NULL;
COPY nasc592.limmaresults (probe_set_id,logfc,aveexpr,t,pvalue,adjpvalue,b) FROM
'/home/shokin/BartonLab/NASC592/res.CHXvMOCK.tsv'
WITH CSV HEADER DELIMITER AS '	';
UPDATE nasc592.limmaresults SET decondition='CHX',basecondition='MOCK' WHERE decondition IS NULL;
COPY nasc592.limmaresults (probe_set_id,logfc,aveexpr,t,pvalue,adjpvalue,b) FROM
'/home/shokin/BartonLab/NASC592/res.CHXDEXvMOCK.tsv'
WITH CSV HEADER DELIMITER AS '	';
UPDATE nasc592.limmaresults SET decondition='CHX+DEX',basecondition='MOCK' WHERE decondition IS NULL;
UPDATE nasc592.limmaresults SET id = (SELECT transcript_id FROM affxannot WHERE affxannot.probe_set_id=nasc592.limmaresults.probe_set_id);

--
-- nasc592.samples
--
CREATE TABLE nasc592.samples () INHERITS (public.samples);
INSERT INTO nasc592.samples  VALUES ('592-01', 1,  'MOCK',     true,   NULL, 'Mock-induced_Rep1',    1, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-02', 4,  'DEX',      false,  NULL, 'DEX-induced_Rep1',     1, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-03', 7,  'CHX',      false,  NULL, 'CHX-treated_Rep1',     1, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-04', 10, 'CHX+DEX',  false,  NULL, 'CHX+DEX-induced_Rep1', 1, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-05', 2,  'MOCK',     true,   NULL, 'Mock-induced_Rep2',    2, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-06', 5,  'DEX',      false,  NULL, 'DEX-induced_Rep2',     2, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-07', 8,  'CHX',      false,  NULL, 'CHX-treated_Rep2',     2, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-08', 11, 'CHX+DEX',  false,  NULL, 'CHX+DEX-induced_Rep2', 2, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-09', 3,  'MOCK',     true,   NULL, 'Mock-induced_Rep3',    3, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-10', 6,  'DEX',      false,  NULL, 'DEX-induced_Rep3',     3, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-11', 9,  'CHX',      false,  NULL, 'CHX-treated_Rep3',     3, 1.0);
INSERT INTO nasc592.samples  VALUES ('592-12', 12, 'CHX+DEX',  false,  NULL, 'CHX+DEX-induced_Rep3', 3, 1.0);

--
-- nasc592.expression - use ordering of samples above!
--
CREATE TABLE nasc592.expression () INHERITS (public.expression);

-- load the RMA data from a single text file
CREATE TEMP TABLE rma (
       probe_set_id   varchar,
       v59201	double precision,
       v59202	double precision,
       v59203	double precision,
       v59204	double precision,
       v59205	double precision,
       v59206	double precision,
       v59207	double precision,
       v59208	double precision,
       v59209	double precision,
       v59210	double precision,
       v59211	double precision,
       v59212   double precision
       );
COPY rma FROM '/home/shokin/BartonLab/NASC592/rma.exprs.tsv' WITH CSV HEADER DELIMITER AS '	';

-- drop not null so we can insert the probeset ids first
ALTER TABLE nasc592.expression ALTER COLUMN values DROP NOT NULL;

-- instantiate the by inserting the probeset ids
INSERT INTO nasc592.expression (probe_set_id) SELECT probe_set_id FROM rma;

-- update the table data column by data column using array(), being sure to order by num to get the array values in the correct order
-- convert to linear values by taking exp
UPDATE nasc592.expression SET values = (
       SELECT array[v59201,v59205,v59209,v59202,v59206,v59210,v59203,v59207,v59211,v59204,v59208,v59212]
       FROM rma WHERE rma.probe_set_id=expression.probe_set_id
       );

-- restore not null
ALTER TABLE nasc592.expression ALTER COLUMN values SET NOT NULL;

-- import the gene ids
UPDATE nasc592.expression SET id = (SELECT transcript_id FROM affxannot WHERE affxannot.probe_set_id=nasc592.expression.probe_set_id);
