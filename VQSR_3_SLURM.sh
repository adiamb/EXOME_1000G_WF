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
