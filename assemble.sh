#!/bin/bash
#echo Script name: $0
#echo $# arguments 

SUB_ID=71
SILENCE='-v'
THREADS='-t 12'
SESSION_ID=''
EMC=''
SPEED='-n 20'
OMODE='-omode 2'
OF=''
FQ=''


POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -sid)
            SESSION_ID="-sid $2"            
            shift # past argument
            shift # past value
            ;;
        -seeds)
            EMC="-emc $2"
            shift # past argument
            shift # past value
            ;;
        -seed_id)
            EMC="-emcid $2"
            shift # past argument
            shift # past value
            ;;
        -speed)
            if [ "$2" = "slow" ]; then 
                SPEED='-n 40'
            fi
            if [ "$2" = "normal" ]; then 
                SPEED='-n 20'
            fi
            if [ "$2" = "fast" ]; then 
                SPEED='-n 15'
            fi
            if [ $2 = "fastest" ]; then 
                SPEED='-n 5'
            fi
            shift # past argument
            shift # past value
            ;;
        -t|-threads)
            THREADS="-t $2"
            shift # past argument
            shift # past value
            ;;
        -o|-output)
            if [ "$2" = "contigs" ]; then 
                OMODE='-omode 2'
            fi
            if [ $2 = "alignments" ]; then 
                OMODE='-omode 3'
            fi            
            shift # past argument
            shift # past value
            ;;
        -f|-format)
            if [ "$2" = "fasta" ]; then 
                FQ=''
            fi
            if [ "$2" = "fastq" ]; then 
                FQ='-fq'
            fi
            shift # past argument
            shift # past value
            ;;
        -s|-silence)
            SILENCE=''
            shift # past argument
            ;;
        -autoname)
            OF='-of'
            shift # past argument
            ;;
        -subid)
            SUB_ID=$2
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

if [ -z "$EMC" ]; then
    if [ -z "$SESSION_ID" ]; then
        EMC='-emc 10'
    else
        EMC='-emc 0'
    fi
fi
#>&2 echo "SILENCE: $SILENCE\n"
#>&2 echo "SESSION: $SESSION_ID\n"

if [ $# -ne 2 ]; then 
    STR=$'id depth\n\nOPTIONAL ARGUMENTS:\n\n-s|-silence: do not print progress to standard error channel.\n-sid [STRING]: continue from a saved session.\n-speed [normal (default) | fast | fastest | slow]: speed of the assembly.\n-threads [INT]: number of threads.\n-output [contigs (default) | alignments]: \'contigs\' for generating a fasta file with the obtained contigs, and \'alignments\' for generating also extra files with the reads aligned to generate the contigs.\n-subid [STRING]: sets a subid (default 71) for the selected set of reads.\n-seeds [NUMBER]: sets the number of seeds to be added initially.\n-format [fasta(default)|fastq]: format of the file containing the contigs\n'
    echo "illegal number of parameters: $0 $STR"
    exit
fi

if ! test -f "./sequences/$1/sra_data.part-$SUB_ID.fa"; then
    echo "Not indexed. Use index.sh."
    exit
fi

LD_LIBRARY_PATH=. ./saligner -name $1 -name2 $SUB_ID -s 0 -p 5 -multisequence -assemble $SPEED -em 1 $EMC $SESSION_ID $THREADS -depth $2 $OMODE $SILENCE $OF $FQ