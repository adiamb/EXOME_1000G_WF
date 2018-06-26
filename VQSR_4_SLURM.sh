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
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T ApplyRecalibration \
-R ucsc.hg19.fasta -input recalibrated_$2.vcf -mode INDEL --ts_filter_level 99.0 -recalFile recalibrate_INDEL_$2.recal -tranchesFile recalibrate_INDEL_$2.tranches \
-o RECALIBRATED_SNPS_INDELS_$2.vcf
EOF
