source("../config/paths.R")

cmd_bqsr <- paste(
  "gatk BaseRecalibrator",
  "-R", REF,
  "-I", INPUT_BAM
)

cmd_hc <- paste(
  "gatk HaplotypeCaller",
  "-R", REF,
  "-I", INPUT_BAM,
  "-O output.vcf.gz"
)

print(cmd_bqsr)
print(cmd_hc)
