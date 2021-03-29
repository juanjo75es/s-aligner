#!/bin/bash

SUB_ID=71
SILENCE='-v'
REVERSE=true
COMPLETE=false
N_READS=100000

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -subid)
            SUB_ID=$2
            shift # past argument
            shift # past value
            ;;
        -n)
            N_READS=$2
            shift # past argument
            shift # past value
            ;;
        -noreverse)
            REVERSE=false
            shift # past value
            ;;
        -complete)
            COMPLETE=true
            shift # past value
            ;;
        -s|-silence)
            SILENCE=''
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -n "$SUB_ID" ] && [ "$SUB_ID" -eq "$SUB_ID" ] 2>/dev/null; then
    if [ $SUB_ID -lt 2 ] || [ $SUB_ID -gt 99 ] 2>/dev/null; then
        echo "illegal sub_id parameter: should be a number between 2 and 99"
        exit
    fi
else
    echo "illegal sub_id parameter: should be a number between 2 and 99"
    exit
fi




if [ $# -ne 2 ]; then 
    STR=$'id fasta_file\n\nOPTIONAL PARAMETERS:\n\n-s|-silence: does not display progress in stderr.\n-subid [STRING]: sets a subid (default 71) for the selected set of reads.\n-n [NUMBER]: number of reads to be selected (default 100.000).\n-noreverse: does not add the reverse-complement of each read.\n-complete: uses all reads in the file instead of using a subset (not recommended).\n'
    echo "illegal number of parameters: $0 $STR"
    exit
fi

ID=$1
FILE=$2
if ! test -f "$FILE"; then
    echo "File does not exist: $FILE"
    exit
fi

ORIGINAL_FILE=$FILE

if [ ${FILE: -3} == ".gz" ];
then
    NEWFILE="${FILE:0:-3}"
    #echo "$NEWFILE"
    gzip -dfqc $FILE > $NEWFILE
    FILE=$NEWFILE
fi

if [ ${FILE: -3} == ".fq" ] || [ ${FILE: -6} == ".fastq" ];
then
    echo "Warning: Converting $FILE to FASTA. You can use your preferred method instead."
    if [ ${FILE: -3} == ".fq" ]; then
        NEWFILE="${FILE:0:-3}.fa"
    else
        NEWFILE="${FILE:0:-6}.fa"
    fi
    ./scripts/fq2fa.sh $FILE $NEWFILE
    if [ $FILE == $ORIGINAL_FILE ];
    then :
    else 
        rm $FILE # delete temporal .fq
    fi
    FILE=$NEWFILE
fi


if [ ${FILE: -3} == ".fa" ] || [ ${FILE: -6} == ".fasta" ];
then :
    #is_fasta=$(python3 scripts/is_fasta.py $FILE)

    #VAR2="false"
    #if [ "$is_fasta" = "$VAR2" ]; then
    #    echo "Not a fasta file: $FILE."
    #    exit
    #fi
else 
    echo "Not a fasta file: $FILE."
    exit
fi


if [ ! -d "./sequences/$1" ]; then
    mkdir ./sequences/$1
fi
if [ ! -d "./bpp/$1" ]; then    
    mkdir ./bpp/$1
fi

if [ "$COMPLETE" = true ]; then
    cp -R $FILE ./sequences/$1/_$SUB_ID.fa
    python3 scripts/simplify_fasta.py -i ./sequences/$1/_$SUB_ID.fa -o ./sequences/$1/$SUB_ID.fa
    rm ./sequences/$1/_$SUB_ID.fa
    if [ "$REVERSE" = true ]; then
        revseq ./sequences/$1/$SUB_ID.fa ./sequences/$1/$SUB_IDr.fa > /dev/null 2>&1
        cat ./sequences/$1/$SUB_ID.fa ./sequences/$1/$SUB_IDr.fa > ./sequences/$1/sra_data.part-$SUB_ID.fa
        rm ./sequences/$1/$SUB_IDr.fa
        rm ./sequences/$1/$SUB_ID.fa
    fi
    LD_LIBRARY_PATH=. ./saligner -name $1 -name2 $SUB_ID -multisequence -index $SILENCE
else
    if test -f "./sequences/$1/sra_data.part-01.fa"; then
        rm ./sequences/$1/sra_data.part-01.fa
    fi
    python3 scripts/simplify_fasta.py -i $FILE -o ./sequences/$1/sra_data.part-01.fa
    #./scripts/fasta-subsample.pl ./sequences/$1/sra_data.part-01.fa $N_READS > ./sequences/$1/70.fa 
    awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END{printf("\n");}' < ./sequences/$ID/sra_data.part-01.fa | awk 'NR>1{ printf("%s",$0); n++;if(n%2==0) { printf("\n");} else { printf("\t");} }' |awk -v k=$N_READS 'BEGIN{srand(systime() + PROCINFO["pid"]);}{s=x++<k?x1:int(rand()*x);if(s<k)R[s]=$0}END{for(i in R)print R[i]}' |awk -F"\t" "{print \$1\"\\n\"\$2 > \"./sequences/$ID/70.fa\"}"
    FILESIZE=$(stat -c%s "./sequences/$ID/70.fa")
    if [ "$FILESIZE" -lt "100000" ]; then        
        cp -f ./sequences/$1/sra_data.part-01.fa ./sequences/$1/70.fa
    fi
    if [ "$REVERSE" = true ]; then
        revseq ./sequences/$1/70.fa ./sequences/$1/70r.fa > /dev/null 2>&1
        cat ./sequences/$1/70.fa ./sequences/$1/70r.fa > ./sequences/$1/sra_data.part-$SUB_ID.fa
        rm ./sequences/$1/70r.fa
        rm ./sequences/$1/70.fa
    else
        mv ./sequences/$1/70.fa ./sequences/$1/sra_data.part-$SUB_ID.fa
    fi
    LD_LIBRARY_PATH=. ./saligner -name $1 -name2 $SUB_ID -multisequence -index $SILENCE
fi

if test -f "./sequences/$1/sra_data.part-01.fa"; then
    rm ./sequences/$1/sra_data.part-01.fa
fi
if [ $FILE == $ORIGINAL_FILE ] 
then :
else
    rm $FILE # delete temporal .fa
fi 


