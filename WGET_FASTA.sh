#!/bin/bash
#$1 -sampleID 
#$2 -mate1
#$3 - mate2
touch "$1"_WGET_TASK.sh
chmod 777 "$1"_WGET_TASK.sh
cat > "$1"_WGET_TASK.sh <<- EOF
#!/bin/bash -l
#SBATCH --job-name=$1_EXOME_TASK
#SBATCH --mem-per-cpu=16000
#SBATCH --time=120:00:00
#SBATCH --account=mignot
#SBATCH --nodes=1 
#wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/$1/sequence_read/$3
#wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/$1/sequence_read/$4
EOF
#sbatch "$1"_WGET_TASK.sh
