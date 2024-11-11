include {getLongestIsoformAgat; filterIncompleteGeneModelsAGAT; getFasta; orthofinder;} from './grc_dnds_tasks.nf'

workflow grc_dnds_flow {
        take:
         fasta_dir
        main:
         orthofinder(fasta_dir)
}
