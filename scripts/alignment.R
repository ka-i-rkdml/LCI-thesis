run_alignment <- function(fastq1, fastq2, output_prefix, ref_genome, threads = 8) {
  
  cmd <- paste(
    "STAR",
    "--runThreadN", threads,
    "--genomeDir", ref_genome,
    "--readFilesIn", fastq1, fastq2,
    "--outFileNamePrefix", output_prefix
  )
  
  system(cmd)
}
