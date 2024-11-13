include {filterIncompleteGeneModelsAGAT; getLongestIsoformAGAT; select_proteins; orthofinder; select_orthogroups; concat_orthogroup_topologies; iqtree2; codeml; plot_dnds_distributions} from './grc_dnds_tasks.nf'

workflow grc_dnds_flow {

        take:
         braker_tsv // channel: [ val(meta), /path/to/genome, /path/to/cds, /path/to/gff, /path/to/prot_fa]
         protein_tsv // channel: [ val(meta), /path/to/prot_fa]

        main:
         // parse denovo protein datasets
         Channel
                .fromPath( braker_tsv )
                .splitCsv( header: true, sep: '\t')
                .multiMap{ row -> 
                        genome: [row.meta, row.genome]
                        cds:  [row.meta, row.cds]
                        gff: [row.meta, row.gff]
                        prot_fa: [row.meta, row.prot_fa]
                        }
                .set{ braker_ch }

         // parse preprocessed protein datasets
         Channel
                .fromPath( protein_tsv )
                .splitCsv( header: true, sep: '\t')
                .map{ row ->
                        [row.meta, row.prot_fa]
                }
                .set{ prot_ch }

        braker_ch.view()
        prot_ch.view()

         // select suitable proteins for orthology inference
         filterIncompleteGeneModelsAGAT(braker_ch.gff.join(braker_ch.genome))
         getLongestIsoformAGAT(filterIncompleteGeneModelsAGAT.out)
         select_proteins(getLongestIsoformAGAT.out.join(braker_ch.prot_fa))

         // checking
         //select_proteins
         //       .collect{ flat:false }
         //       .concat(prot_ch)
         //       .map{ it.transpose() }
         //       .set( selected_prot_ch )

        //selected_prot_ch.view()

         // orthology inference
         //orthofinder(select_proteins.collect(flat:false).map{it.transpose()})
}