run_annotation <- function(vcf, annotated_vcf) {
  system(paste("snpEff ann GRCh38", vcf, ">", annotated_vcf))
}
