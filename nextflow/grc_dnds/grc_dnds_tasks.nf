// if genome and gff3

process getLongestIsoformAGAT{
        memory '4G'

        input:
        path(annotation)

        output:
        path("${annotation.simpleName}.agat.longest_isoform.gff3")

        script:
        """
        agat_sp_keep_longest_isoform.pl -gff ${annotation} -o ${annotation.simpleName}.agat.longest_isoform.gff3
        """
}

// awk '\$3=="exon"' ${meta}.longest_isoform.gff3 > ${meta}.longest_isoform.cds.gff3

process filterIncompleteGeneModelsAGAT{
        memory '4G'

        input:
        path(annotation)

        output:
        path("${annotation.simpleName}.agat.complete_genes.gff3")

        script:
        """
        agat_sp_filter_incomplete_gene_coding_models.pl -gff ${annotation} --fasta ${genome.fa} -o ${annotation.simpleName}.agat.complete_genes.gff3
        """
}

// This is not right - want to select the genes from the above filtered gff3s 
process getFasta{
        publishDir params.outdir, mode:'copy'
        memory '4G'

        input:
        path(fasta)
        path(intervals)

        output:
        path("${fasta.baseName}.longest_isoforms.fa")

        script:
        """
        bedtools getfasta -fi ${fasta} -bed ${intervals} > ${fasta.simpleName}.longest_isoforms.fa
        """
}

// else protein filtering

process orthofinder {
        publishDir params.outdir, mode:'copy'
        cpus 16
        scratch true

        input:
        path(prot_fastas, stageAs: "fastas/*")

        output:
        path("orthofinder_results/*")

        script:
        """
        orthofinder -f fastas -t ${task.cpus} -a ${task.cpus} -o orthofinder_results -M msa
        """
}

// Here Fede runs analyse_alignments_V2.R and filters OGs differently
process select_orthogroups{

        input:
        path(Orthogroups.GeneCount.tsv)

        output:
        path('*.SCOs.txt')

        script:
        """
        select_orthogroups.py ${Orthogroups.GeneCount.tsv}
        """
}

// Assuming the topology of these trees will be the same as the IQ trees?
process concat_orthogroup_topologies{

        input:
        path(gene_trees, stageAs: "gene_trees/*")

        output:
        path('OG_topologies.txt')

        script:
        """
        gawk 'BEGINFILE{printf("%s\t",FILENAME)}1' *.txt | sed 's/_tree.txt//g' > OG_topologies.tsv
        """
}

// Here Fede cleans alignments
// Runs analyse_alignments_with_identity_v2.R
// Runs clean_alignments.sh and meta_clean_alignments.sh (which does the following)
// Runs prequal # check?
// Aligns codon sequences based on amino acid translations with MACSEv2
// Uses BMGE to filter unreliably aligned columns # definitely seems like not a good idea
// https://academic.oup.com/sysbio/article/64/5/778/1685763

// is this step really needed for codeml? we have trees from orthofinder?
// look at /lustre/scratch126/tol/teams/jaron/users/fede/CDS_seqs/CleanAlignments/ for input
// what does -b do?
// Is it just because of the filtering and we could use the trees straight out of orthofinder?
// Can compare the orthofinder trees to iq trees
// Maybe here is where for each SCO set we can remove the relevant datasets from the alignment
// And then generate a new alignment with iqtree for codeml
// Then the previous phylogeny can be used to account for shared stuff?
// Where does the codon based alignment come in?

process iqtree2 {

        input:
        path(orthogroup_subset)
        path(aa.fa)

        output:

        script:
        """
        iqtree2 -s ${aa.fa} --seed 1234 -b 100 -redo
        """
}

// https://github.com/Obscuromics/Fly-Germ-Line-Chromosomes/blob/main/scripts/treefile2table_of_neighbors.py

// run_codeml.pl
// optim_blen.ctl
// two_omegas.ctl
process codeml {

        input:

        output:

        script:
        """

        """
}

// Is there a way we could make the most of tskit to
// plot the location of genes (using the gff3)?
process plot_dnds_distributions {

        input:

        output:

        script:
        """

        """
}


// Other to dos
// Look at why genes are split in the GRCs vs core
// Can I do the alignments with translatorx?
