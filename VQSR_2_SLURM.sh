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
