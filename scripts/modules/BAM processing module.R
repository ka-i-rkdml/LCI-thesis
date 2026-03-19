run_bam_processing <- function(input_bam, output_bam, threads = 8) {
  
  # Example: sorting
  sort_cmd <- paste(
    "samtools sort",
    "-@", threads,
    "-o", output_bam,
    input_bam
  )
  
  system(sort_cmd)
  
  # indexing
  index_cmd <- paste("samtools index", output_bam)
  system(index_cmd)
}
