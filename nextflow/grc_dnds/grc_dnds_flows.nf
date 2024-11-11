include {getLongestIsoformAgat; filterIncompleteGeneModelsAGAT; select_proteins; orthofinder; select_orthogroups; concat_orthogroup_topologies; iqtree2; codeml; plot_dnds_distributions} from './grc_dnds_tasks.nf'

workflow grc_dnds_flow {

        take:
         input_tsv // channel: [ val(meta), /path/to/genome, /path/to/cds, /path/to/gff3, /path/to/prot_fa]
        
        main:
         datasets = Channel.fromPath(input_tsv) | splitCsv( header: true, sep: '\t')

         // select suitable proteins for orthology inference
         filterIncompleteGeneModelsAGAT(datasets.meta, datasets.gff3, datasets.genome)
         getLongestIsoformAGAT(filterIncompleteGeneModelsAGAT.out)
         select_proteins(getLongestIsoformAGAT.out.join(datasets.meta, datasets.prot_fa)

         // checking
         select_proteins.collect(flat:false).map{it.transpose()} | view

         // orthology inference
         orthofinder(select_proteins.collect(flat:false).map{it.transpose()})
}