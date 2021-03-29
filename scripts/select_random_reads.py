import sys
import requests 
import shlex, subprocess
import random
from Bio import SeqIO


if len(sys.argv)<4:
    print("Uso: "+sys.argv[0]+" input_fasta output_fasta nreads")
    sys.exit(0)


savefile = sys.argv[2]
content_file = sys.argv[1]
nreads=int(sys.argv[3])

class Row:
    id = ""
    seq = ""

fasta=[]
for record in SeqIO.parse(content_file, "fasta"):
    r=Row()
    r.id=record.id
    r.seq=record.seq
    fasta.append(r)


import random
random.shuffle(fasta)

res=""
for i in range(min(nreads,len(fasta))):
    res+=">"+fasta[i].id+"\n"
    res+=str(fasta[i].seq)+"\n"

output_file = open(savefile, "w")

output_file.write(res)

output_file.close()