#!/bin/bash
set -e

snakemake -s startup.smk -p -j 2
snakemake -s ../../Snakefile --configfile config.yaml --config result_dir=result0 -p -j 2 --use-conda
snakemake -s ../../Snakefile --configfile config.yaml --config result_dir=result1 -p -j 2 --use-conda

vcf_a=$(zcat result0/03_strelka2/pe/tumor/tumor_vs_normal.snvs.strelka.vcf.gz | grep -v '^#' | md5sum | cut -d' ' -f1)
vcf_b=$(zcat result1/03_strelka2/pe/tumor/tumor_vs_normal.snvs.strelka.vcf.gz | grep -v '^#' | md5sum | cut -d' ' -f1)

if [ "$vcf_a" == "$vcf_b" ]; then
    curl https://gist.githubusercontent.com/dohlee/3ea154d52932b27d042566605a2cb9e2/raw/update_reproducibility.sh -H 'Cache-control: no-cache' | bash /dev/stdin -y
else
    curl https://gist.githubusercontent.com/dohlee/3ea154d52932b27d042566605a2cb9e2/raw/update_reproducibility.sh -H 'Cache-control: no-cache' | bash /dev/stdin -n
fi

echo "Test exited with $?."
