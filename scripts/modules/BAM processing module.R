run_bam_processing <- function(bam_in, bam_out) {
  system(paste("gatk MarkDuplicates -I", bam_in, "-O", bam_out))
}
