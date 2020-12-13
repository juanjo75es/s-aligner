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

if [ "$#" -ne 4 ]; then
    STR=$'id source reference n_samples\n\nOPTIONAL PARAMETERS\n-silence: do not print progress messages to standard error channel.\n-t|-threads [NUMBER]: set number of threads.'
    echo "Illegal number of parameters: $0 $STR"
    exit
fi

id=$1
source=$2
reference=$3
n=$4

if ! test -f "$source"; then
    echo "Can't find $source."
    exit
fi

if ! test -f "$reference"; then
    echo "Can't find $reference."
    exit
fi

VAR2="false"

if [ ! -d "./sequences/$1" ]; then
    mkdir ./sequences/$1
fi
if [ ! -d "./bpp/$1" ]; then
    mkdir ./bpp/$1
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

python3 scripts/simplify_fasta.py -i $source -o ./sequences/$1/66.fa
cp $reference sequences/$id/sra_data.part-33.fa
LD_LIBRARY_PATH=. ./saligner -name $id -name2 33 -s 0 -p 6 -multisequence -index
LD_LIBRARY_PATH=. ./saligner -name $id -name2 33 -input ./sequences/$1/66.fa -s 1 -p 6 -multisequence -assemble2 -n 50000 -emc 9999999 -em 3 $SILENCE $THREADS -depth $n -omode 3
rm ./sequences/$1/66.fa
