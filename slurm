## Trimmomatic slurm script
```bash
#!/bin/bash
#SBATCH --job-name=trimmomatic_kcs1
#SBATCH --output=/home/yc1201/genome_alignment_kcs1/slurm/%x.o%j
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=yc1201@georgetown.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=04:00:00
#SBATCH --mem=8G
#SBATCH --array=6-8

# Establish base directory paths
$ BASE_DIR="/home/yc1201/genome_alignment_kcs1"
$ RAW_DIR="${BASE_DIR}/data/raw"
$ OUT_DIR="${BASE_DIR}/results/trimmed"

# Create output folder if it doesn't exist
$ mkdir -p ${OUT_DIR}

# Map the SLURM Array ID (6, 7, 8) to your specific sample numbers
$ if [ ${SLURM_ARRAY_TASK_ID} -eq 6 ]; then
    SAMPLE="Kcs1Restore6_S235"
$ elif [ ${SLURM_ARRAY_TASK_ID} -eq 7 ]; then
    SAMPLE="Kcs1Restore7_S236"
$ elif [ ${SLURM_ARRAY_TASK_ID} -eq 8 ]; then
    SAMPLE="Kcs1Restore8_S237"
$ fi

# Load Trimmomatic module ("aliases" needed for GU HPC setup here) 
$ shopt -s expand_aliases 
$ module load trimmomatic

# Run Trimmomatic PE using absolute paths
$ trimmomatic PE -threads 2 \
$ "${RAW_DIR}/${SAMPLE}_R1_001.fastq.gz" \
$ "${RAW_DIR}/${SAMPLE}_R2_001.fastq.gz" \
$ "${OUT_DIR}/${SAMPLE}_R1_paired.fq.gz" "${OUT_DIR}/${SAMPLE}_R1_unpaired.fq.gz" \
$ "${OUT_DIR}/${SAMPLE}_R2_paired.fq.gz" "${OUT_DIR}/${SAMPLE}_R2_unpaired.fq.gz" \
$ LEADING:10 \
$ TRAILING:10 \
$ ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
$ SLIDINGWINDOW:4:15 \
$ MINLEN:75

# Clean up environment
$ module unload trimmomatic
```

## Bowtie slurm script
```bash
#!/bin/bash
#SBATCH --job-name=bowtie_kcs1
#SBATCH --output=/home/yc1201/genome_alignment_kcs1/slurm/%x.o%j
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=erz12@georgetown.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=06:00:00
#SBATCH --mem=8G
#SBATCH --array=6-8

# Establish base directory paths
$ BASE_DIR="/home/yc1201/genome_alignment_kcs1"
$ TRIM_DIR="${BASE_DIR}/results/trimmed"
$ ALIGN_DIR="${BASE_DIR}/results/aligned"

# Ensure alignment output folder exists
$ mkdir -p ${ALIGN_DIR}

# Map the SLURM Array ID to actual KCS1 sample names
$ if [ ${SLURM_ARRAY_TASK_ID} -eq 6 ]; then
    SAMPLE="Kcs1Restore6_S235"
$ elif [ ${SLURM_ARRAY_TASK_ID} -eq 7 ]; then
    SAMPLE="Kcs1Restore7_S236"
$ elif [ ${SLURM_ARRAY_TASK_ID} -eq 8 ]; then
    SAMPLE="Kcs1Restore8_S237"
$ fi

# Define input, reference, and output variables
$ READ1="${TRIM_DIR}/${SAMPLE}_R1_paired.fq.gz"
$ READ2="${TRIM_DIR}/${SAMPLE}_R2_paired.fq.gz"
$ REFERENCE_INDEX="${BASE_DIR}/data/reference/ref"
$ OUTPUT_FILE="${ALIGN_DIR}/${SAMPLE}.sam"

# Run Bowtie2 alignment (using 4 threads to speed it up)
$ module load bowtie2/2.5.3
$ bowtie2 -p 4 -x $REFERENCE_INDEX -1 $READ1 -2 $READ2 -S $OUTPUT_FILE

$ module unload bowtie2
```
