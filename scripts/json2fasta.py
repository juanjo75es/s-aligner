import sys
import json
import requests 
import shlex, subprocess
import json


def quitar_gaps(s):
    return s.replace('-','')

def get_fasta(jsonData):
    #jsonData=str(jsonData)
    #jsonData=jsonData.replace('\\n','\n')
    #jsonData=jsonData.replace('\\r','\r')
    #jsonData=jsonData.replace('\\t','\t')
    #print(jsonData)
    js=json.loads(jsonData)
    species=js['local_alignment_search']['species']
    #cr=js['local_alignment_search']['results'][0]['chromosome']
    cr=js['local_alignment_search']['results'][0]['species']
    s=''
    for r in js['local_alignment_search']['results']:
        for al in r['alignments']:
            pos=al['local_alignment']['position']
            if 'score' in al['local_alignment']:
                score=al['local_alignment']['score']
                if score>10:
                    id=species+'_'+str(cr)+'_'+str(pos)
                    seq_found=al['local_alignment']['sequence_found']
                    seq_found=quitar_gaps(seq_found)
                    s+='>'+id+'\n'
                    s+=seq_found+'\n'
    return s

if len(sys.argv)<3:
    print("Uso: "+sys.argv[0]+" json_results_file output_fasta_file")
    sys.exit(0)


savefile = sys.argv[2]
seq = sys.argv[1]

with open(seq, 'r') as content_file:
    searched_fasta = content_file.read()

output_file = open(savefile, "w")

jsontxt=searched_fasta
fasta=get_fasta(jsontxt)
output_file.write(fasta)

output_file.close()