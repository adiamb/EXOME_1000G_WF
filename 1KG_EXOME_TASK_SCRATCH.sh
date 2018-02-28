#!/bin/bash
#$1 - sample name
#$2 - RG
#$3 -mate1
#$4 - mate2
#$5 - jobid of wget
touch "$1"_EXOME_TASK.sh
chmod 777 "$1"_EXOME_TASK.sh
cat > "$1"_EXOME_TASK.sh <<- EOF
#!/bin/bash -l
#SBATCH --job-name=$1_EXOME_TASK
#SBATCH --mem-per-cpu=8000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1 
#SBATCH --ntasks=32
module load bwa/0.7.8
module load java/8u66
gatk="GenomeAnalysisTK.jar"
reffasta="ucsc.hg19.fasta"
path_fasta="/ifs/scratch/ambati/"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     BWA ALIGNMENT IN PROGRESS <<<<<<<<<<<<<<<<<<<<<<<<<<"
bwa mem -M -t 32 -R "$2" \$reffasta \$path_fasta"$3" \$path_fasta"$4" > \$path_fasta"$1"_bwamem.sam
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     PICARD SORT SAM IN PROGRESS    <<<<<<<<<<<<<<<<<<<<<<<<<<"
java -Djava.io.tmpdir=/local/scratch -jar picard.jar SortSam I=\$path_fasta"$1"_bwamem.sam O=\$path_fasta"$1"_sorted.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=True
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     PICARD REORDER SAM IN PROGRESS    <<<<<<<<<<<<<<<<<<<<<<<<<<"
java -Djava.io.tmpdir=/local/scratch -jar picard.jar ReorderSam I=\$path_fasta"$1"_sorted.bam O=\$path_fasta"$1"_SORTED_REORD.bam R=\$reffasta VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=True
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     PICARD MARKING DUPLICATES    <<<<<<<<<<<<<<<<<<<<<<<<<<"
java -Djava.io.tmpdir=/local/scratch -jar picard.jar MarkDuplicates I=\$path_fasta"$1"_SORTED_REORD.bam O=\$path_fasta"$1"_SORTED_REORD_DEDUP.bam M=$1_metrics.txt REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=True
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     GATK BASE RECALIBARATION    <<<<<<<<<<<<<<<<<<<<<<<<<<"
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T BaseRecalibrator -R \$reffasta -L Exome_Agilent_V4.bed -I \$path_fasta"$1"_SORTED_REORD_DEDUP.bam -knownSites dbsnp_138.hg19.vcf -knownSites Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -nct 32 -o $1_RECAL.table
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     GATK PRINTING READS POST BQSR    <<<<<<<<<<<<<<<<<<<<<<<<<<"
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T PrintReads -R \$reffasta -I \$path_fasta"$1"_SORTED_REORD_DEDUP.bam -BQSR $1_RECAL.table -nct 32 -o $1_RECAL_READS.bam
echo ">>>>>>>>>>>>>>>>>>>>>>>>>     GATK HALPOTYPE CALLER -G.VCFs    <<<<<<<<<<<<<<<<<<<<<<<<<<"
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T HaplotypeCaller -R \$reffasta -L Exome_Agilent_V4.bed -I $1_RECAL_READS.bam --dbsnp dbsnp_138.hg19.vcf --emitRefConfidence GVCF -nct 32 -o $1.raw.snps.indels.g.vcf
rm \$path_fasta"$1"_bwamem.sam \$path_fasta"$1"_sorted.bam \$path_fasta"$1"_SORTED_REORD.bam \$path_fasta"$1"_SORTED_REORD_DEDUP.bam
EOF
sbatch "$1"_EXOME_TASK.sh
