#!/bin/bash
#$1 - sample name
#$2 - RG
#$3 -mate1
#$4 - mate2
touch "$1"_EXOME_TASK.sh
chmod 777 "$1"_EXOME_TASK.sh
cat > "$1"_EXOME_TASK.sh <<- EOF
#!/bin/bash -l
#SBATCH --job-name=$1_EXOME_TASK
#SBATCH --mem-per-cpu=16000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1 
#SBATCH --ntasks=32
module load bwa/0.7.8
module load java/8u66
gatk="GenomeAnalysisTK.jar"
reffasta="ucsc.hg19.fasta"
#wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/$1/sequence_read/$3
#wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/$1/sequence_read/$4
bwa mem -M -t 32 -R "$2" \$reffasta $3 $4 > $1_bwamem.sam
java -Djava.io.tmpdir=/local/scratch -jar picard.jar SortSam I=$1_bwamem.sam O=$1_sorted.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=True
java -Djava.io.tmpdir=/local/scratch -jar picard.jar ReorderSam I=$1_sorted.bam O=$1_SORTED_REORD.bam R=\$reffasta VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=True
java -Djava.io.tmpdir=/local/scratch -jar picard.jar MarkDuplicates I=$1_SORTED_REORD.bam O=$1_SORTED_REORD_DEDUP.bam M=$1_metrics.txt REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=True
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T BaseRecalibrator -R \$reffasta -L Exome_Agilent_V4.bed -I $1_SORTED_REORD_DEDUP.bam -knownSites dbsnp_138.hg19.vcf -knownSites Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -nct 32 -o $1_RECAL.table
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T PrintReads -R \$reffasta -I $1_SORTED_REORD_DEDUP.bam -BQSR $1_RECAL.table -nct 32 -o $1_RECAL_READS.bam
java -Djava.io.tmpdir=/local/scratch -jar \$gatk -T HaplotypeCaller -R \$reffasta -L Exome_Agilent_V4.bed -I $1_RECAL_READS.bam --dbsnp dbsnp_138.hg19.vcf --emitRefConfidence GVCF -nct 32 -o $1.raw.snps.indels.g.vcf
EOF
sbatch "$1"_EXOME_TASK.sh
