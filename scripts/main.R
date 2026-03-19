source("config.R")
source("modules/alignment.R")
source("modules/variant_calling.R")

run_alignment("sample.fastq", "sample.bam", ref_genome)

run_variant_calling("sample.bam", "sample.vcf")
