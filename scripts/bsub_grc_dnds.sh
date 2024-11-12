#!/bin/bash

#BSUB -o logs/grc_dnds.out.%J
#BSUB -e logs/grc_dnds.err.%J
#BSUB -q normal
#BSUB -n 4
#BSUB -M 4096
#BSUB -R "select[mem>4096] rusage[mem=4096]"

module load nextflow/24.04.2-5914
module load mafft/7.525--h031d066_1
module load fasttree/2.1.11--h031d066_3
module load bedtools/2.31.1--hf5e1c6e_1
module load iqtree/2.3.4--h21ec9f0_0
nextflow run nextflow/grc_dnds/grc_dnds_main.nf -params-file nextflow/grc_dnds/params.json -c nextflow/conf/nextflow.config -with-conda /software/treeoflife/conda/users/envs/team360/se13/grc_dnds -w data/workdir/grc_dnds -resume # -with-report -with-trace -with-timeline -with-dag
