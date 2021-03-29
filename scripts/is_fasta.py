import sys
from Bio import SeqIO

if len(sys.argv)<1:
    print("Use: "+sys.argv[0]+" input_fasta")
    sys.exit(0)

my_file = sys.argv[1]  # Obviously not FASTA

def is_fasta(filename):
    with open(filename, "r") as handle:
        fasta = SeqIO.parse(handle, "fasta")
        return any(fasta)  # False when `fasta` is empty, i.e. wasn't a FASTA file

try:
    if is_fasta(my_file):
        print("true")
    else:
        print("false")
except:
    print("false")        
# False