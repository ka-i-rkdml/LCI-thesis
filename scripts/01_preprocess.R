source("../config/paths.R")
source("../utils/helpers.R")

cmd_sort <- build_cmd("samtools sort", c(
  "-@ 4",
  "-m 2G",
  "-o sorted.bam",
  INPUT_BAM
))

cmd_rg <- build_cmd("gatk AddOrReplaceReadGroups", c(
  "-I sorted.bam",
  "-O rg.bam",
  "-RGSM sample"
))

print(cmd_sort)
print(cmd_rg)
