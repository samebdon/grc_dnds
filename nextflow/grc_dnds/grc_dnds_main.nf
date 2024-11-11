log.info """\
         G R C   D N / D S   N F   P I P E L I N E    
         ===================================
         Input CDS directory : ${params.input_fasta_dir}
         outdir : ${params.outdir}
         """
         .stripIndent()

include { grc_dnds_flow } from './grc_dnds_flows.nf'

workflow {
        grc_dnds_flow(params.input_fasta_dir)
}

// mamba activate grc_dnds
// mamba install -c conda-forge -c bioconda orthofinder
