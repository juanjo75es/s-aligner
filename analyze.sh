#!/bin/bash

THREADS='-t 3'

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


is_fasta=$(python3 scripts/is_fasta.py $source)
if [ "$is_fasta" = "$VAR2" ]; then
    echo "Not a fasta file: $source."
    exit
fi

is_fasta=$(python3 scripts/is_fasta.py $reference)
if [ "$is_fasta" = "$VAR2" ]; then
    echo "Not a fasta file: $reference."
    exit
fi

python3 scripts/reverse_complement.py $source results/$id-toalign.fa
python3 ./scripts/clip_reads.py results/$id-toalign.fa results/$id-toalign.clipped.fa 25 15
rm results/$id-toalign.fa
python3 ./scripts/split_reads.py results/$id-toalign.clipped.fa results/$id-toalign.clipped.split.fa 15000
rm results/$id-toalign.clipped.fa
./map.sh $id results/$id-toalign.clipped.split.fa $reference 2800 $THREADS --nosimplify > results/map-$id-contigs.fa
python3 ./scripts/consensus.py -i results/map-$id-contigs.fa -r $reference -o results/$id-consensus.fa
rm results/$id-toalign.clipped.split.fa