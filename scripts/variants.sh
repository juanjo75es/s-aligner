#!/bin/bash

SILENCE='-v'
THREADS='-t 1'

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -s|--silence)
            SILENCE=''
            shift # past argument
            ;;
        -t|-threads)
            THREADS="-t $2"
            shift # past argument
            shift # past value
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$#" -ne 3 ]; then
    STR=$'id source reference\n\nOPTIONAL PARAMETERS\n-silence: do not print progress messages to standard error channel.\n-t|-threads [NUMBER]: set number of threads.'
    echo "Illegal number of parameters: $0 $STR"
    exit
fi

source=$2
reference=$3
id=$1

if ! test -f "$source"; then
    echo "Can't find $source."
    exit
fi

if ! test -f "$reference"; then
    echo "Can't find $reference."
    exit
fi

bwa mem -t 10 $reference $source  > $id.sam
samtools view -b $id.sam > $id.bam
samtools sort -o $id"_sorted.bam" -O bam -T $id $id.bam
samtools index $id"_sorted.bam"
rm $id.sam
rm $id.bam

freebayes -f $reference $id"_sorted.bam" > $id"_freebayes.vcf"

bwa index $reference
samtools mpileup -A -d 20000 -Q 0 -f $reference $id"_sorted.bam" > $id.pileup
rm $id"_sorted.bam"
rm $id"_sorted.bam.bai"
varscan mpileup2cns $id.pileup --min-var-freq 0.02 --p-value 0.99 --variants --output-vcf 1 > $id.vcf
varscan mpileup2cns $id.pileup --min-var-freq 0.8 --p-value 0.05 --variants --output-vcf 1 > $id"_majority.vcf"
rm $id.pileup
