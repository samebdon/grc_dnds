include {getLongestIsoformAGAT; filterIncompleteGeneModelsAGAT; select_proteins; orthofinder; select_orthogroups; concat_orthogroup_topologies; iqtree2; codeml; plot_dnds_distributions} from './grc_dnds_tasks.nf'

workflow grc_dnds_flow {

        take:
         input_tsv // channel: [ val(meta), /path/to/genome, /path/to/cds, /path/to/gff, /path/to/prot_fa]
        
        main:
         // parse data
         Channel
                .fromPath( input_tsv )
                .splitCsv( header: true, sep: '\t')
                .multiMap{ row -> 
                        genome: [row.meta, row.genome]
                        cds:  [row.meta, row.cds]
                        gff: [row.meta, row.gff]
                        prot_fa: [row.meta, row.prot_fa]
                        }
                .set{ data_ch }
         // select suitable proteins for orthology inference
         filterIncompleteGeneModelsAGAT(data_ch.gff.join(data_ch.genome))
         //getLongestIsoformAGAT(filterIncompleteGeneModelsAGAT.out)
         //select_proteins(getLongestIsoformAGAT.out.join(data_ch.prot_fa))

         // checking
         //select_proteins.collect(flat:false).map{it.transpose()}.view()

         // orthology inference
         //orthofinder(select_proteins.collect(flat:false).map{it.transpose()})
}