#! /usr/bin/env python3
# -*- coding: utf-8 -*-
from Bio import SeqIO
import argparse
import sys
from argparse import RawTextHelpFormatter
import numpy as np
from collections import namedtuple


MySNP = namedtuple("MySNP", "pos prev new")

snps=[]

def print_vnc(reference, snps, out):
    f = open(out+".vcf", "w")
    f.write("##fileformat=VCFv4.1\n")
    f.write("##source=s-aligner\n")
    f.write("#CHROM POS ID  REF ALT QUAL    FILTER\n")
    for snp in snps:
        f.write("xxx")
        f.write("\t")
        f.write(str(snp.pos))
        f.write("\t.\t")
        f.write(str(snp.prev))
        f.write("\t")
        f.write(str(snp.new))
        f.write("\t.\tPASS")
        f.write("\n")
    f.close()

def consensus(fasta, reference, out):

    for record in SeqIO.parse(reference, "fasta"):    
        referenceseq = record.seq

    print(len(referenceseq))

    c_columns = np.array([0]*len(referenceseq)*2)
    g_columns = np.array([0]*len(referenceseq)*2)
    t_columns = np.array([0]*len(referenceseq)*2)
    a_columns = np.array([0]*len(referenceseq)*2)
    gap_columns = np.array([0]*len(referenceseq)*2)
    prevseq=''
    lastseq=''
    maxlen=0
    for record in SeqIO.parse(fasta, "fasta"):    
        recordseq = record.seq
        if(len(prevseq)>0):
            found_first_char=False
            pos=0
            for c in prevseq:
                if( c!='-'):
                    if(not found_first_char):
                        found_first_char = True
                    if(c=='A'):
                        a_columns[pos] +=1
                    elif(c=='C'):
                        c_columns[pos] +=1
                    elif(c=='G'):
                        g_columns[pos] +=1
                    elif(c=='T'):
                        t_columns[pos] +=1
                elif (found_first_char):
                    gap_columns[pos] += 1
                pos += 1        
        if(len(recordseq) > maxlen):
            maxlen=len(recordseq)
        lastseq=recordseq
        prevseq=recordseq        
    consensus= ""
    posreal=1
    for i in range(maxlen):
        x = max(a_columns[i],c_columns[i],g_columns[i],t_columns[i],gap_columns[i])
        c='ñ'
        if(a_columns[i] == x):
            c='A'
        elif(c_columns[i] == x):
            c='C'
        elif(g_columns[i] == x):
            c='G'
        elif(t_columns[i] == x):
            c='T'
        elif(gap_columns[i] == x):
            c='-'
        if(x==0):
            c='N'
        if(c!=lastseq[i] and c!='ñ'):
            snp=MySNP(posreal,lastseq[i],c)
            snps.append(snp)
            #print(str(posreal)+":: "+str(lastseq[i])+" -> "+str(c))        
        if(c!='-'):
            consensus = "".join((consensus, c))
            posreal+=1
        #print("consensus:"+consensus)
    f = open(out, "w")
    f.write(">consensus")
    f.write("\n")
    f.write(consensus)
    f.write("\n")
    f.close()
    print_vnc(reference,snps,out)
    #print(snps)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='simplify-fasta', usage='%(prog)s -i inputFasta -o outputFasta', description="""
        *****************************************************************************
        *********************************BinSanity***********************************
        **    The `simplify-fasta` script is built to simplify fasta headers so as **
        **    not to run into errors when running BinSanity. Simplified headers    **
        **    means that every contig id is only made up of a single word. This    **
        **    will rename your fasta ids as `>contig_1`, `>contig_2`, and so on.   **
        *****************************************************************************""", formatter_class=RawTextHelpFormatter)
    parser.add_argument("-i", metavar="", dest="inputFASTA",
                        help="Specify the name of the input file")
    parser.add_argument("-r", metavar="", dest="inputREF",
                        help="Specify the name of the reference file")
    parser.add_argument("-o", metavar="", dest="inputOUT",
                        help="Specify the name for the output file")
    args = parser.parse_args()
    if len(sys.argv) < 2:
        print(parser.print_help())
    if args.inputFASTA is None and args.inputOUT is None:
        print("You haven't specified an input or output silly")
    elif args.inputFASTA is None:
        print("You can't give an output without an input")
    elif args.inputOUT is None:
        print("Provide and output file")
    else:
        consensus(args.inputFASTA, args.inputREF, args.inputOUT)