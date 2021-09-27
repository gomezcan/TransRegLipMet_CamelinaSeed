#!/bin/bash

### Requirements
# 1. trimmomatic
# 2. fastqc
# 3. Bowtie2
# 4. SAMtools
# 5. SAMtools
# 6. Bowtie2 Genome index: http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer
# 6. Genome source: http://camelinadb.ca


# NOTE: this script should stay on the same directory with raw fastq file 
cd RawData/

# Output directory for unmapped reads at the sample level of RawDaa
mkdir ../UnMapped

# Output directory for unmapped reads at the sample level of RawDaa
mkdir ../Mapping

for i in *fastq.gz; do

	# Create fastqc report for raw data
	fastqc $i;
	
	# Remove illumina adapters, low-quality basepairs, and short reads
	trimmomatic SE -threads 10 $i Clean.$i ILLUMINACLIP:Adapter.fastq:2:40:15 SLIDINGWINDOW:4:20 MINLEN:27;
	
	# Create a second fastqc report from clean data
	fastqc Clean.$i;
	
	# Set mapping output file names
	# out=${i//Clean./};
	out=${i//.fastq.gz/};
	name=${i//.gz/}
	
	# Mapping clean reads 
	echo "Mapping $out to Camelina with default "
	bowtie2 -p 10 --un ../UnMapped/Un.${name} --no-unal -x Index_Camelina_bowtie2 -U Clean.${i} -S ../Mapping/${out}.sam;
	
	# convert sam into bam and sort alignments 
	samtools view -@ 10 -h -bS ../Mapping/${out}.sam | samtools sort -@ 10 - -o ../Mapping/${out}.bam;
	
	# remove low quality alignments
	samtools view -@ 10 -h -b -q 30 ../Mapping/${out}.bam | samtools sort -@ 10 - -o ../Mapping/Q30.${out}.bam
	
	# Label and remove duplicated aligned reads
	picard MarkDuplicates I=../Mapping/Q30.${out}.bam O=../Mapping/DeDup.Q30.${out}.bam M=Metrics.Q30.${out}.txt REMOVE_DUPLICATES=true;
	
	
done;

