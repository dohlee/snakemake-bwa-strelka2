REFERENCE = 'reference/hg38_chr20.fasta'
TUMOR = ['data/tumor.read1.fastq.gz', 'data/tumor.read2.fastq.gz']
NORMAL = ['data/normal.read1.fastq.gz', 'data/normal.read2.fastq.gz']

ALL = []
ALL.append(REFERENCE)
ALL.append(TUMOR)
ALL.append(NORMAL)

rule all:
    input: ALL

rule clean:
    shell:
        "if [ -d data ]; then rm -r data; fi; "
        "if [ -d reference ]; then rm -r reference; fi; "
        "if [ -d logs ]; then rm -r logs; fi; "
        "if [ -d benchmarks ]; then rm -r benchmarks; fi; "
        "if [ -d result0 ]; then rm -r result0; fi; "
        "if [ -d result1 ]; then rm -r result1; fi; "

rule reference:
    output: REFERENCE
    wrapper: 'http://dohlee-bio.info:9193/test/reference'

rule wxs_tumor:
    output: TUMOR
    wrapper: 'http://dohlee-bio.info:9193/test/wxs/tumor'

rule wxs_normal:
    output: NORMAL
    wrapper: 'http://dohlee-bio.info:9193/test/wxs/normal'
