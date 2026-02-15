# The files for each sample are paired with a _R1.fastq.gz and _R2.fastq.gz formatting
# Adapter Trimming and QC with Trimgalore and FastQC

# Removes adapters and low quality bases and runs QC afterward to confirm removal

conda activate trim

trim_galore \
--paired \
--fastqc \
--quality 20 \
--length 30 \
--cores 25 \
-o directory \
sample.R1.fastq.gz \
sample.R2.fastq.gz

conda deactivate

# Alignment with bowtie2

# Prior reference genome building step with hg38
# bowtie2-build hg38_GrCh38.p14_genomic.fna hg38
# Ecoli genome was found on the link provided on Epicypher’s website-
# then run to get the build genome files
# tar -xvzf filename.tar.gz
# generates a log file with sequencing depth

#FOR HUMAN
bowtie2 --very-sensitive-local -p 25 -x hg38 \
-1 path-to-trimmed-R1.fastq \
-2 path-to-trimmed-R2.fastq \
-S sample-human.sam \
-t \
--met-file sample-metrics.txt \
2> bowtie_log.txt

#FOR VIRUS
#Use MCV2 for NCCR in the middle of sequence
bowtie2 --very-sensitive -p 25 -x MCV \
-1 path-to-trimmed-R1.fastq \
-2 path-to-trimmed-R2.fastq \
-S sample-MCV.sam \
-t \
--met-file sample-metrics.txt \
2> bowtie_log.txt

#FOR ECOLI
bowtie2 --very-sensitive -p 25 -x ecoli \
-1 path-to-trimmed-R1.fastq \
-2 path-to-trimmed-R2.fastq \
-S sample-ecoli.sam \
-t \
--met-file sample-metrics.txt \
2> bowtie_log.txt

# SAM file to BAM file

samtools view -@ 25 -b sample.sam \
| samtools sort -@ 25 -o sample-sorted.bam
samtools index sample-sorted.bam
samtools idxstats sample-sorted.bam

# Normalization of data from Ecoli spike in DNA- MOST RECENT DATA IS EVEN


# Peak Calling with MACS2

conda activate ChIPseq

#FOR VIRUS
macs2 callpeak \
-t sample-sorted.bam \
-f BAMPE \
-n sample \
-g 6000 \
--nomodel \
--keep-dup all \
-q 0.01 \
--call-summits

#FOR HUMAN
macs2 callpeak \
-t sample-sorted.bam \
-f BAMPE \
-n sample \
-g 2.7e9 \
--nomodel \
--keep-dup all \
-q 0.01 \
--call-summits

conda deactivate

# Generate BigWig file to overlay on genome viewer

#FOR VIRUS
bamCoverage \
-b sample-sorted.bam \
-o sample.bw \
--binSize 1 \
--normalizeUsing None \
-p 25 \
--verbose \
--centerReads

#FOR HUMAN
bamCoverage \
-b sample-sorted.bam \
-o sample.bw \
--binSize 10 \
--normalizeUsing CPM \
-p 25 \
--verbose \
--centerReads

# Open genome viewer

igv

