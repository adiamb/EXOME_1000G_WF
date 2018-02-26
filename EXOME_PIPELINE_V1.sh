#!/bin/bash
echo "################################################################################################################" 
echo "                            EXOME PIPELINE VERSION 1 SCG4  Version date Feb 25 2018 SLURM VERSION" 
echo "                                     SCG4 utilizing parallel computation SLURM VERSION"
echo "                                              Aditya Ambati"
echo "                                           ambati@stanford.edu"
echo "################################################################################################################"

echo " WGET PAIRED FASTQ FILES FROM SERVER "
#$1 - sampleID
#$2 - ReadGroup
#$3 - FASTQ MATE1
#$4 - FASTQ MATE2
./WGET_FASTA.sh $1 $3 $4
JOBID0=$(sbatch --export=ALL PLINK_SPLIT.sh)
if ! echo ${JOBID0} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID0}
   exit 1
else
   job0=$(echo ${JOBID0} | grep -oh "[1-9][0-9]*$")
fi
echo "HOLDING EXOME PIPELINE UNTIL WGET COMPLETES"
./1KG_EXOME_TASK.sh $1 $2 $3 $4 \$job0
