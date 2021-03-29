import sys
import requests 
import shlex, subprocess
import random
from Bio import SeqIO


if len(sys.argv)<3:
    print("Uso: "+sys.argv[0]+" input_fasta output_fasta [mode]")
    sys.exit(0)


savefile = sys.argv[2]
content_file = sys.argv[1]
mode = ""
if len(sys.argv)>3:
    mode = sys.argv[3]


class Row:
    id = ""
    seq = ""

def reverse_complement(seq):    
    complement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'}
    reverse_complement = "".join(complement.get(base, base) for base in reversed(seq))    
    return reverse_complement

fasta=[]
for record in SeqIO.parse(content_file, "fasta"):
    r=Row()
    r.id=record.id
    r.seq=record.seq
    fasta.append(r)



res=""
for i in range(len(fasta)):
    if mode!="justreverse":
        res+=">"+fasta[i].id+"\n"
        res+=str(fasta[i].seq)+"\n"
    res+=">R:"+fasta[i].id+"\n"
    res+=str(reverse_complement(fasta[i].seq))+"\n"

output_file = open(savefile, "w")

output_file.write(res)

output_file.close()