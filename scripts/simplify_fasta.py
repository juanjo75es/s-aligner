#! /usr/bin/env python3
# -*- coding: utf-8 -*-
from Bio import SeqIO
import argparse
import sys
from argparse import RawTextHelpFormatter


def simplfy_fasta(fasta, out):
    x = open(out, "a")
    i = 1
    for record in SeqIO.parse(fasta, "fasta"):
        recordid = (">%s" % i)
        i = i + 1
        recordseq = record.seq
        x.write(recordid)
        x.write("\n")
        x.write(str(recordseq))
        x.write("\n")
    x.close()


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
        simplfy_fasta(args.inputFASTA, args.inputOUT)