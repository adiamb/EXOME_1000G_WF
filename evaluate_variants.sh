#!/bin/bash
touch evaluate_variants_slurm.sh
chmod 755 evaluate_variants_slurm.sh
cat > evaluate_variants_slurm.sh <<-EOF
#!/bin/bash -l
#SBATCH --job-name=GGTYPE_EXOME_TASK
#SBATCH --mem-per-cpu=10000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1
#SBATCH --ntasks=16
module load java/8u66
module load R/3.4.1
gatk="GenomeAnalysisTK.jar"
java -jar \$gatk \
-T VariantEval \
-R ucsc.hg19.fasta \
-L Exome_Agilent_V4.bed \
-eval $1.vcf \
-D dbsnp_138.hg19.vcf \
-noEV -EV CompOverlap -EV IndelSummary -EV TiTvVariantEvaluator -EV CountVariants -EV MultiallelicSummary \
-nt 16 \
-o $1.eval.grp
EOF
sbatch evaluate_variants_slurm.sh
