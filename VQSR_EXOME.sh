#!/bin/bash -l
#SBATCH --job-name=GGTYPE_EXOME_TASK
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1
#SBATCH --depend=afterok:51058
module load java/8u66
module load R/3.4.1
gatk="GenomeAnalysisTK.jar"
java --Djava.io.tmpdir=/local/scratch -jar \$gatk -T VariantRecalibrator -R ucsc.hg19.fasta \
-input COMBINED_EXOME_INTERVAL_FEB28_2018.vcf \
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 hapmap_3.3.hg19.sites.vcf \
-resource:omni,known=false,training=true,truth=true,prior=12.0 1000G_omni2.5.hg19.sites.vcf \
-resource:1000G,known=false,training=true,truth=false,prior=10.0 1000G_phase1.snps.high_confidence.hg19.sites.vcf \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 dbsnp_138.hg19.vcf \
-an QD -an FS -an SOR -an MQ -an MQRankSum -an ReadPosRankSum -an InbreedingCoeff -mode SNP -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 -recalFile recalibrate_SNP.recal -tranchesFile recalibrate_SNP.tranches -rscriptFile recalibrate_SNP_plots.R
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T ApplyRecalibration \
-R ucsc.hg19.fasta -input COMBINED_EXOME_INTERVAL_FEB28_2018.vcf -mode SNP --ts_filter_level 99.0 -recalFile recalibrate_SNP.recal -tranchesFile recalibrate_SNP.tranches -o recalibrated_snps_raw_indels.vcf
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T VariantRecalibrator -R ucsc.hg19.fasta -input recalibrated_snps_raw_indels.vcf -resource:mills,known=false,training=true,truth=true,prior=12.0 Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 dbsnp_138.hg19.vcf -an QD -an FS -an SOR -an MQRankSum -an ReadPosRankSum -an InbreedingCoeff -mode INDEL -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --maxGaussians 4 -recalFile recalibrate_INDEL.recal -tranchesFile recalibrate_INDEL.tranches -rscriptFile recalibrate_INDEL_plots.R
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T ApplyRecalibration -R ucsc.hg19.fasta -input recalibrated_snps_raw_indels.vcf -mode INDEL --ts_filter_level 99.0 -recalFile recalibrate_INDEL.recal -tranchesFile recalibrate_INDEL.tranches -o RECALIBRATED_VARIANTS_SNPS_INDELS_FEB28_2018.vcf
