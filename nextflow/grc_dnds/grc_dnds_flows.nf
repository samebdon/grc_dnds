include {getLongestIsoformAGAT; filterIncompleteGeneModelsAGAT; select_proteins; orthofinder; select_orthogroups; concat_orthogroup_topologies; iqtree2; codeml; plot_dnds_distributions} from './grc_dnds_tasks.nf'

workflow grc_dnds_flow {

        take:
         input_tsv // channel: [ val(meta), /path/to/genome, /path/to/cds, /path/to/gff3, /path/to/prot_fa]
        
        main:
         dataset_ch = Channel.fromPath(input_tsv).splitCsv( header: true, sep: '\t')
         dataset_ch.view()
         // select suitable proteins for orthology inference
         filterIncompleteGeneModelsAGAT(dataset_ch[0], dataset_ch[3], dataset_ch[1])
         getLongestIsoformAGAT(filterIncompleteGeneModelsAGAT.out)
         select_proteins(getLongestIsoformAGAT.out.join(dataset_ch[0], dataset_ch[4]))

         // checking
         select_proteins.collect(flat:false).map{it.transpose()}.view()

         // orthology inference
         orthofinder(select_proteins.collect(flat:false).map{it.transpose()})
}