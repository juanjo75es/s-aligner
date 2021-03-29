import sys
import requests 
import shlex, subprocess
import random
from Bio import SeqIO


if len(sys.argv)<4:
    print("Uso: "+sys.argv[0]+" input_fasta output_fasta chunk_size")
    sys.exit(0)


savefile = sys.argv[2]
content_file = sys.argv[1]
chunk_size=int(sys.argv[3])

class Row:
    id = ""
    seq = ""

fasta=[]
for record in SeqIO.parse(content_file, "fasta"):
    r=Row()
    r.id=record.id
    r.seq=record.seq
    fasta.append(r)

res=""
for s in fasta:
    if(len(s.seq)>chunk_size):
        for i in range(0, int(len(s.seq)/chunk_size)):        
            if len(s.seq[i*chunk_size:(i+1)*chunk_size])>60:
                res+=">"+s.id[0:]+"-"+str(i)+"-A\n"
                res+=str(s.seq[i*chunk_size:(i+1)*chunk_size])+"\n"        
            if len(s.seq[i*chunk_size+int(chunk_size/2):(i+1)*chunk_size+int(chunk_size/2)])>60:
                res+=">"+s.id[0:]+"-"+str(i)+"-B\n"
                res+=str(s.seq[i*chunk_size+int(chunk_size/2):(i+1)*chunk_size+int(chunk_size/2)])+"\n"
            else:
                res+=">"+s.id[0:]+"-"+str(i)+"-B\n"
                res+=str(s.seq[:-chunk_size])+"\n"
        if  int(len(s.seq)-chunk_size)>60:
            res+=">"+s.id[0:]+"-"+str(int(len(s.seq)/chunk_size))+"-A2\n"
            res+=str(s.seq[int(len(s.seq)-chunk_size):])+"\n"
    else:
        res+=">"+s.id+"\n"
        res+=str(s.seq)+"\n"
output_file = open(savefile, "w")

output_file.write(res)

output_file.close()