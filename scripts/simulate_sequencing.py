import sys
import requests 
import shlex, subprocess
import random


def quitar_gaps(s):
    return s.replace('-','')


if len(sys.argv)<5:
    print("Uso: "+sys.argv[0]+" input_fasta output_fasta chunk_length nchunks")
    sys.exit(0)


savefile = sys.argv[2]
seq = sys.argv[1]
chunk_length=int(sys.argv[3])
nchunks=int(sys.argv[4])

with open(seq, 'r') as content_file:
    searched_fasta = content_file.read()

output_file = open(savefile, "w")

l = len(searched_fasta)

def reverse_complement(seq):
    complement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'}
    reverse_complement = "".join(complement.get(base, base) for base in reversed(seq))
    return reverse_complement

def build_chimera(s1,s2):
    #s2=reverse_complement(s2)
    res=s[int(len(s)/2):] + s2[:int(len(s2)/2)]
    return res

nchimeras=20
res=""
for x in range(1, nchunks):

    r=int(random.randint(1,100))
    #if r<2:
    if nchimeras>=0 and r<2:
        nchimeras-=1
        p=int(random.randint(1,l))
        p2=int(random.randint(1,l))
        s=searched_fasta[p:p+chunk_length-1]
        s2=searched_fasta[p2:p2+chunk_length-1]
        if len(s)>80 and len(s2)>80:
            s=build_chimera(s,s2)
            res+=">"+str(x)+"_chim_________________________\n"
            res+=s+"\n"
    else:
        p=int(random.randint(1,l))
        s=searched_fasta[p:p+chunk_length-1]
        if len(s)>80:
            res+=">"+str(x)+"______________________________\n"
            res+=s+"\n"
#print(res)

output_file.write(res)

output_file.close()