#!/bin/bash

SILENCE='-v'
MODE='-assemble3'

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -s|--silence)
            SILENCE=''
            shift # past argument
            ;;
        -m|-mode)
            if [ "$2" = "4" ]; then
                MODE="-assemble4"
            fi
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

if [ "$#" -ne 1 ]; then
    STR=$'source\n\nOPTIONAL PARAMETERS\n-silence: do not print progress messages to standard error channel.'
    echo "Illegal number of parameters: $0 $STR"
    exit
fi

source=$1

if ! test -f "$source"; then
    echo "Can't find $source."
    exit
fi

VAR2="false"

if [ ! -d "./sequences/scaffolding" ]; then
    mkdir ./sequences/scaffolding
fi

if [ ! -d "./bpp/scaffolding" ]; then
    mkdir ./bpp/scaffolding
fi


is_fasta=$(python3 scripts/is_fasta.py $source)
if [ "$is_fasta" = "$VAR2" ]; then
    echo "Not a fasta file: $source."
    exit
fi

python3 scripts/simplify_fasta.py -i $source -o sequences/scaffolding/sra_data.part-45.fa
LD_LIBRARY_PATH=. ./saligner -name scaffolding -name2 45 -s 0 -p 6 -multisequence -index
LD_LIBRARY_PATH=. ./saligner -name scaffolding -name2 45 -input ./sequences/scaffolding/sra_data.part-45.fa -s 0 -p 6 -n 20255 -multisequence $MODE $SILENCE $THREADS -depth 2000 > $source.scaffolds.$MODE.fa

rm ./sequences/scaffolding/sra_data.part-45.fa
rm -rf ./bpp/scaffolding
