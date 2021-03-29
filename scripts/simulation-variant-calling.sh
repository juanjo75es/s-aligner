#!/bin/bash

THREADS='-t 3'
DEPTH='5000'

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -t|-threads)
            THREADS="-t $2"
            shift # past argument
            shift # past value
            ;;
        -d|-depth)
            DEPTH="$2"
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
    STR=$'id source reference\n\nOPTIONAL PARAMETERS\n-silence: do not print progress messages to standard error channel.\n-t|-threads [NUMBER]: set number of threads.\n-d|-depth [NUMBER]: set number of reads to process.'
    echo "Illegal number of parameters: $0 $STR"
    exit
fi

id=$1
source=$2
reference=$3

if ! test -f "$source"; then
    echo "Can't find $source."
    exit
fi

if ! test -f "$reference"; then
    echo "Can't find $reference."
    exit
fi

is_fasta=$(python3 scripts/is_fasta.py $reference)
if [ "$is_fasta" = "$VAR2" ]; then
    echo "Not a fasta file: $reference."
    exit
fi

~/art_src_MountRainier_Linux/art_illumina -ss MSv1 -sam -i $source -l 150 -f 600 -p -m 200 -s 10 -o /mnt/d/results/$id
rm results/$id.sam
rm results/"$id"1.aln
rm results/"$id"2.aln
#mkdir ~/testing/working_2/samples/$id
#mkdir ~/testing/working_2/samples/$id/1111
#mkdir ~/testing/working_2/samples/$id/1111/raw_data

./scripts/variants.sh $id results/"$id"1.fq $reference
mv $id".vcf" ./results/
mv $id"_majority.vcf" ./results/
mv $id"_freebayes.vcf" ./results/

#cp results/"$id"1.fq ~/testing/working_2/samples/$id/1111/raw_data/"$id"_R1.fastq
#mv results/"$id"2.fq ~/testing/working_2/samples/$id/1111/raw_data/"$id"_R2.fastq
./index.sh $id results/"$id"1.fq
./assemble.sh $id $DEPTH > results/$id-$DEPTH.fa
./analyze.sh $id results/$id-$DEPTH.fa $reference $THREADS
#cd ~/testing/working_2
#rm samples.tsv
#./vpipe --dryrun
#sed -e 's/$/\t150/' -i samples.tsv
#./vpipe -p --cores 2