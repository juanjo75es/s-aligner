import sys
import requests 
import shlex, subprocess
import random
from Bio import SeqIO


if len(sys.argv)<4:
    print("Uso: "+sys.argv[0]+" input_fasta output_fasta min_length")
    sys.exit(0)

savefile = sys.argv[2]
content_file = sys.argv[1]
min_length=int(sys.argv[3])

res=""
for record in SeqIO.parse(content_file, "fasta"):
    if len(record.seq)>=min_length:
        res+=">"+record.id+"\n"
        res+=str(record.seq)+"\n"

output_file = open(savefile, "w")

output_file.write(res)

output_file.close()