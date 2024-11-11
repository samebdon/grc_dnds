include {getLongestIsoformAGAT; filterIncompleteGeneModelsAGAT; select_proteins; orthofinder; select_orthogroups; concat_orthogroup_topologies; iqtree2; codeml; plot_dnds_distributions} from './grc_dnds_tasks.nf'

workflow grc_dnds_flow {

        take:
         input_tsv // channel: [ val(meta), /path/to/genome, /path/to/cds, /path/to/gff3, /path/to/prot_fa]
        
        main:
         dataset_ch = Channel.fromPath(input_tsv).splitCsv( header: true, sep: '\t').map { row -> tuple(row.meta, row.genome, row.cds, row.gff3, row.prot_fa)}
         dataset_ch.view()
         // select suitable proteins for orthology inference
         filterIncompleteGeneModelsAGAT(dataset_ch.meta, datasets.gff3, datasets.genome)
         getLongestIsoformAGAT(filterIncompleteGeneModelsAGAT.out)
         select_proteins(getLongestIsoformAGAT.out.join(datasets.meta, datasets.prot_fa))

         // checking
         select_proteins.collect(flat:false).map{it.transpose()}.view()

         // orthology inference
         orthofinder(select_proteins.collect(flat:false).map{it.transpose()})
}