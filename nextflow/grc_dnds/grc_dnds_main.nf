log.info """\
         G R C   D N / D S   N F   P I P E L I N E    
         ===================================
         Input TSV : ${params.input_tsv}
         outdir : ${params.outdir}
         """
         .stripIndent()

include { split_tsv, filter_braker, filter_ncbi, filter_flybase, orthofinder } from './grc_dnds_flows.nf'
include { split_data_ch as split_data_ch_braker} from './grc_dnds_flows.nf'
include { split_data_ch as split_data_ch_ncbi} from './grc_dnds_flows.nf'
include { split_data_ch as split_data_ch_flybase} from './grc_dnds_flows.nf'

workflow {
        split_tsv(params.input_tsv)
        split_data_ch_braker(split_tsv.out.braker)
        //split_data_ch_ncbi(split_tsv.out.ncbi)
        //split_data_ch_flybase(split_tsv.out.flybase)
        filter_braker(split_data_ch_braker.out)
        filter_braker.out.view()
        // filter_ncbi(split_data_ch_ncbi.out)
        // filter_flybase(split_data_ch_flybase.out)

        //filter_braker.out
        //                    .concat(filter_ncbi.out, filter_flybase.out)
        //                    .set { prot_fa_ch }
        // orthofinder(prot_fa_ch)
}

// mamba activate grc_dnds
// mamba install -c conda-forge -c bioconda orthofinder ag
