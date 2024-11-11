#!/usr/bin/env bash

GFF="$1"
FASTA="$2"

awk '\$3=="transcript"' | awk '{print \$9}' | cut -f-1 -d';' | cut -f2- -d'=' $GFF > transcripts.txt

for TRANSCRIPT in transcripts.txt;
do
	awk '/^>/ {printf("\n%s\n",\$0);next; } { printf("%s",\$0);}  END {printf("\n");}' $FASTA | grep 'gene' -A1
done
