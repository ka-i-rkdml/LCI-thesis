run_variant_calling <- function(bam, vcf) {
  system(paste("gatk HaplotypeCaller -I", bam, "-O", vcf))
}
