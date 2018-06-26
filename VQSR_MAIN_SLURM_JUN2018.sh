#!/bin/bash
./VQSR_1_SLURM.sh $1
JOBID0=$(sbatch VQSR_1_STEP.sh)
if ! echo ${JOBID0} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID0}
   exit 1
else
   job0=$(echo ${JOBID0} | grep -oh "[1-9][0-9]*$")
fi

echo " SNP RECALIBRATION COMPELTED NOW APPLYING RECALIBRATION MAKE SURE TO CHECK THE RSCRIPTS TO GENERATE PLOTS"


./VQSR_2_SLURM.sh $job0 $1
JOBID1=$(sbatch VQSR_2_STEP.sh)
if ! echo ${JOBID1} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID1}
   exit 1
else
   job1=$(echo ${JOBID1} | grep -oh "[1-9][0-9]*$")
fi
echo "VQSR of SNPS in progress "


./VQSR_3_SLURM.sh $job1 $1
JOBID2=$(sbatch VQSR_3_STEP.sh)
if ! echo ${JOBID2} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID2}
   exit 1
else
   job2=$(echo ${JOBID2} | grep -oh "[1-9][0-9]*$")
fi
echo "VQSR of INDELS in progress "

echo "VQSR of INDELS finshed "
./VQSR_4_SLURM.sh $job2 $1
sbatch VQSR_4_STEP.sh
