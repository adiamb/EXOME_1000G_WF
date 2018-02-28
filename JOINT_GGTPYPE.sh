#!/bin/bash -l
#SBATCH --job-name=GGTYPE_EXOME_TASK
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1 
#SBATCH --ntasks=32
module load java/8u66
gatk="GenomeAnalysisTK.jar"
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T GenotypeGVCFs -L Exome_Agilent_V4.bed -R ucsc.hg19.fasta --variant GVCF_FEB28.txt --dbsnp dbsnp_138.hg19.vcf -nt 32 -o COMBINED_EXOME_INTERVAL_FEB28_2018.vcf
