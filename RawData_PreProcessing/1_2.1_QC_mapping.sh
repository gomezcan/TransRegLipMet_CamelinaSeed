#!/bin/bash

### This command line calculated the coverades for genomic regions of 500 bps for all samples mapped and save then in two files: 1) .npz, and 2) .tab
### The second files is used in 1_2.2_QC_mapping.R R script to generate summary plots about the samples

# create a new folder at the same level of "Mapping results"

### Requirements:
# deepTools: https://deeptools.readthedocs.io/en/develop/index.html


mkdir QC
cd QC
ln -s ../Mapping/DeDup.*.bam . # create soft link of deduplicated and  Q30 mapped reads 

multiBamSummary bins -p 50 --binSize 500 --bamfiles *.bam --smartLabels -o Samples.bin500.npz  --outRawCounts Samples.counts.bin500.tab
