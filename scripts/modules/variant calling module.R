run_variant_calling <- function(bam, vcf) {
  system(paste("gatk HaplotypeCaller -I", bam, "-O", vcf))
}

#filtering+annotation module
run_annotation <- function(vcf, annotated_vcf) {
  system(paste("snpEff ann GRCh38", vcf, ">", annotated_vcf))
}
