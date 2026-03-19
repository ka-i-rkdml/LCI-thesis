#alignment/prepocessing module
run_alignment <- function(fastq, out_bam, ref) {
  cmd <- paste("star --genomeDir", ref, "--readFilesIn", fastq)
  system(cmd)
}

