include {filterIncompleteGeneModelsAGAT; getLongestIsoformAGAT; select_proteins; orthofinder; select_orthogroups; concat_orthogroup_topologies; iqtree2; codeml; plot_dnds_distributions} from './grc_dnds_tasks.nf'

workflow split_tsv{

        take:
         input_tsv // channel: [ val(meta), val(annotation_source), /path/to/genome, /path/to/cds, /path/to/gff, /path/to/prot_fa]

        main:
         Channel
                .fromPath( input_tsv )
                .splitCsv( header: true, sep: '\t')
                .map{ row -> 
                        tuple( row.meta, row.annotation_source, row.genome, row.cds, row.gff, row.prot_fa)
                }
                .branch{ row ->
                        braker: row.annotation_source = "braker"
                        ncbi: row.annotation_source = 'ncbi'
                        flybase: row.annotation_source = 'FlyBase'      
                }
                .set{ data_ch }

        emit:
         braker = data_ch.braker.map{ tuple( row.meta, row.annotation_source, row.genome, row.cds, row.gff, row.prot_fa)
                                        tuple( row.meta, row.genome, row.cds, row.gff, row.prot_fa)
                                        }
         ncbi = data_ch.ncbi.map{ tuple( row.meta, row.annotation_source, row.genome, row.cds, row.gff, row.prot_fa)
                                        tuple( row.meta, row.genome, row.cds, row.gff, row.prot_fa)
                                }
         flybase = data_ch.flybase.map{ tuple( row.meta, row.annotation_source, row.genome, row.cds, row.gff, row.prot_fa)
                                        tuple( row.meta, row.genome, row.cds, row.gff, row.prot_fa)
                                        }
}

workflow split_data_ch{

        take:
         input_ch // channel: [ val(meta), /path/to/genome, /path/to/cds, /path/to/gff, /path/to/prot_fa]
        
        main:
         input_ch
                .multiMap{ row -> 
                        genome: [row.meta, row.genome]
                        cds:  [row.meta, row.cds]
                        gff: [row.meta, row.gff]
                        prot_fa: [row.meta, row.prot_fa]
                        }
                .set{ data_ch }
        emit:
         data_ch


}

workflow filter_braker{

        take:
         input_ch

        main:
         filterIncompleteGeneModelsAGAT(data_ch.gff.join(data_ch.genome))
         getLongestIsoformAGAT(filterIncompleteGeneModelsAGAT.out)
         select_proteins(getLongestIsoformAGAT.out.join(data_ch.prot_fa))
         select_proteins
                .collect{ flat:false }
                .map{ it.transpose() }
                .set{ data_ch }

        emit:
         data_ch

}

//workflow filter_ncbi{
//        take:
//
//        main:
//
//}

//workflow filter_flybase{
//        take:
//
//        main:
//
//}

workflow orthofinder {

        take:
         prot_fasta_ch
        
        main:

         // orthology inference
         orthofinder(prot_fasta_ch)
}