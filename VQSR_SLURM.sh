## SCRIPT NAMED VQSR_1_SLURM.sh
#!/bin/bash
touch VQSR_1_STEP.sh
chmod 755 VQSR_1_STEP.sh
cat > VQSR_1_STEP.sh <<-EOF
#!/bin/bash -l
#SBATCH --job-name=VQSR_1_step
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1
module load java/8u66
module load R/3.4.1
gatk="GenomeAnalysisTK.jar"
java -Djava.io.tmpdir=/local/scratch -jar $gatk -T VariantRecalibrator -R ucsc.hg19.fasta \
-input $1.vcf \
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 hapmap_3.3.hg19.sites.vcf \
-resource:omni,known=false,training=true,truth=true,prior=12.0 1000G_omni2.5.hg19.sites.vcf \
-resource:1000G,known=false,training=true,truth=false,prior=10.0 1000G_phase1.snps.high_confidence.hg19.sites.vcf \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 dbsnp_138.hg19.vcf \
-an QD -an FS -an SOR -an MQ -an MQRankSum -an ReadPosRankSum -an InbreedingCoeff -mode SNP -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
-recalFile recalibrate_SNP_$1.recal -tranchesFile recalibrate_SNP_$1.tranches -rscriptFile recalibrate_SNP_plots_$1.R
EOF

./VQSR_1_SLURM.sh $1
JOBID0=$(sbatch --export=VQSR_1_STEP.sh)
if ! echo ${JOBID0} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID0}
   exit 1
else
   job0=$(echo ${JOBID0} | grep -oh "[1-9][0-9]*$")
fi

echo " SNP RECALIBRATION COMPELTED NOW APPLYING RECALIBRATION MAKE SURE TO CHECK THE RSCRIPTS TO GENERATE PLOTS"


#!/bin/bash
touch VQSR_2_STEP.sh
chmod 755 VQSR_2_STEP.sh
cat > VQSR_2_STEP.sh <<-EOF
#!/bin/bash -l
#SBATCH --job-name=VQSR_2_step
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1
#SBATCH --depend=afterok:"$1"
module load java/8u66
module load R/3.4.1
gatk="GenomeAnalysisTK.jar"
java -Djava.io.tmpdir=/local/scratch -jar $gatk -T ApplyRecalibration \
-R ucsc.hg19.fasta -input $2 \
-mode SNP --ts_filter_level 99.0 -recalFile recalibrate_SNP_$2.recal -tranchesFile recalibrate_SNP_$2.tranches -o recalibrated_$2.vcf
EOF

echo "VQSR of SNPS in progress "

./VQSR_2_SLURM.sh $job0 $1
JOBID1=$(sbatch --export=VQSR_2_STEP.sh)
if ! echo ${JOBID1} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID1}
   exit 1
else
   job1=$(echo ${JOBID1} | grep -oh "[1-9][0-9]*$")
fi

#!/bin/bash
touch VQSR_3_STEP.sh
chmod 755 VQSR_3_STEP.sh
cat > VQSR_3_STEP.sh <<-EOF
#!/bin/bash -l
#SBATCH --job-name=VQSR_3_step
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1
#SBATCH --depend=afterok:"$1"
module load java/8u66
module load R/3.4.1
gatk="GenomeAnalysisTK.jar"
java -Djava.io.tmpdir=/local/scratch -jar $gatk -T VariantRecalibrator \
-R ucsc.hg19.fasta -input recalibrated_$2.vcf \
-resource:mills,known=false,training=true,truth=true,prior=12.0 Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 dbsnp_138.hg19.vcf \
-an QD -an FS -an SOR -an MQRankSum -an ReadPosRankSum -an InbreedingCoeff -mode INDEL -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --maxGaussians 4 \
-recalFile recalibrate_INDEL_$2.recal -tranchesFile recalibrate_INDEL_$2.tranches -rscriptFile recalibrate_INDEL_plots_$2.R
EOF

echo "VQSR of INDELS in progress "

./VQSR_3_SLURM.sh $job1 $1
JOBID2=$(sbatch --export=VQSR_3_STEP.sh)
if ! echo ${JOBID2} | grep -q "[1-9][0-9]*$"; then 
   echo "Job(s) submission failed."
   echo ${JOBID2}
   exit 1
else
   job2=$(echo ${JOBID2} | grep -oh "[1-9][0-9]*$")
fi

#!/bin/bash
touch VQSR_4_STEP.sh
chmod 755 VQSR_4_STEP.sh
cat > VQSR_4_STEP.sh <<-EOF
#!/bin/bash -l
#SBATCH --job-name=VQSR_4_step
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1
#SBATCH --depend=afterok:"$1"
module load java/8u66
module load R/3.4.1
gatk="GenomeAnalysisTK.jar"
java -Djava.io.tmpdir=/local/scratch -jar $gatk -T ApplyRecalibration \
-R ucsc.hg19.fasta -input recalibrated_$2.vcf -mode INDEL --ts_filter_level 99.0 -recalFile recalibrate_INDEL_$2.recal -tranchesFile recalibrate_INDEL_$2.tranches \
-o RECALIBRATED_SNPS_INDELS_$2.vcf
EOF

echo "VQSR of INDELS finshed "
./VQSR_4_SLURM.sh $job1 $1
