import pandas as pd
from pathlib import Path

configfile: 'config.yaml'
manifest = pd.read_csv(config['manifest'])

DATA_DIR = Path(config['data_dir'])
RESULT_DIR = Path(config['result_dir'])

single = manifest[manifest.library_layout == 'single'].name.values
paired = manifest[manifest.library_layout == 'paired'].name.values

tumor = manifest[manifest.is_tumor == 1].name.values
normal = manifest[manifest.is_tumor == 0].name.values
single_tumor = set(single) & set(tumor)
paired_tumor = set(paired) & set(tumor)

tumor2normal = {row['name']:row['matched_normal'] for _, row in manifest[manifest.is_tumor == 1].iterrows()}

BWA_SINGLE = expand(str(RESULT_DIR / config['bwa_result_dir'] / 'se' / '{sample}' / '{sample}.duplicates_marked.sorted.bam'), sample=single)
BWA_PAIRED = expand(str(RESULT_DIR / config['bwa_result_dir'] / 'pe' / '{sample}' / '{sample}.duplicates_marked.sorted.bam'), sample=paired)

STRELKA2_SINGLE = expand(str(RESULT_DIR / config['strelka2_result_dir'] / 'se' / '{tumor}' / '{tumor}_vs_{normal}.snvs.strelka.vcf.gz'), tumor=single_tumor, normal=[tumor2normal[t] for t in single_tumor])
STRELKA2_PAIRED = expand(str(RESULT_DIR / config['strelka2_result_dir'] / 'pe' / '{tumor}' / '{tumor}_vs_{normal}.snvs.strelka.vcf.gz'), tumor=paired_tumor, normal=[tumor2normal[t] for t in paired_tumor])

ALL = []
ALL.append(BWA_SINGLE)
ALL.append(BWA_PAIRED)
ALL.append(STRELKA2_SINGLE)
ALL.append(STRELKA2_PAIRED)

include: 'rules/bwa.smk'
include: 'rules/sambamba.smk'
include: 'rules/strelka2.smk'
include: 'rules/samtools.smk'

wildcard_constraints:
    library = '[sp]e'

rule all:
    input: ALL
