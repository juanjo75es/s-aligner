import sys
import requests 
import shlex, subprocess
import random
from Bio import SeqIO


if len(sys.argv)<5:
    print("Uso: "+sys.argv[0]+" clip_reads input_fasta output_fasta start_position end_position")
    sys.exit(0)


savefile = sys.argv[2]
content_file = sys.argv[1]
start=int(sys.argv[3])
end=int(sys.argv[4])



res=""
for record in SeqIO.parse(content_file, "fasta"):
    res+=">"+record.id+"\n"
    res+=str(record.seq[start:end])+"\n"

output_file = open(savefile, "w")

output_file.write(res)

output_file.close()