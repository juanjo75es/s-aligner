import sys
import requests 
import shlex, subprocess
import random
from Bio import SeqIO
import editdistance

if len(sys.argv)<3:
    print("Uso: "+sys.argv[0]+" input_fasta output_fasta")
    sys.exit(0)

savefile = sys.argv[2]
content_file = sys.argv[1]

class Sequence:
    id=""
    sequence=""

def are_similar(seq1, seq2):
    l1 = len(seq1.sequence)
    l2 = len(seq2.sequence)
    if abs(l1-l2) < l1/40:
        d = editdistance.eval(seq1.sequence[0:250], seq2.sequence[0:250])
        #d = editdistance.eval(seq1.sequence, seq2.sequence)
        print(seq1.id+" "+seq2.id+" -> "+str(d))
        #if d < l1/20:
        if d < 50:
            return True
    return False

def find_repeats(sequences, seq, repeated):
    b=False
    for seq2 in sequences:
        if(b and not seq2.id in repeated):
            if are_similar(seq, seq2):
                repeated.add(seq2.id)        
        if seq2.id==seq.id:
            b=True

sequences=[]

res=""

for record in SeqIO.parse(content_file, "fasta"):
    seq=Sequence()
    seq.id=record.id
    seq.sequence=record.seq
    sequences.append(seq)

repeated_sequences=set()
for seq in sequences:
    find_repeats(sequences, seq, repeated_sequences)

print(repeated_sequences)

def mySortFunc(e):
    return len(e.sequence)

sequences.sort(key=mySortFunc)

for seq in sequences:
    b= seq.id in repeated_sequences
    if not b:
        res+=">"+seq.id+"\n"
        res+=str(seq.sequence)+"\n"

output_file = open(savefile, "w")

output_file.write(res)

output_file.close()