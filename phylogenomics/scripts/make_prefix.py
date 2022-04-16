#!/usr/bin/env python3

import os
import re

import argparse


FoldersFromBusco = ["single_copy_busco_sequences"]

parser = argparse.ArgumentParser(
    description='Reorganize BUSCO single-copy genes into MultiFasta for PHYling')

parser.add_argument('-i', '--BUSCO', default='BUSCO',
                    help='BUSCO folder')


parser.add_argument('-p', '--prefixfile', default='prefix_test.tab',
                    help='prefixes')

parser.add_argument('--debug', const=True, default=False, nargs='?',
                    help='Debug steps')
parser.add_argument('--force', const=True, default=False, nargs='?',
                    help='Force writing output DB if already exists')

parser.add_argument('--fragmented', const=True, default=False, nargs='?',
                    help='Include fragemented sequences')
args = parser.parse_args()

if args.fragmented:
    FoldersFromBusco.appedn("fragmented_busco_sequences")


species_seqs = {}
orthologs = {}
sp_folders = []

BUSCOdir = sorted(os.listdir(args.BUSCO))

dirsToRun = BUSCOdir

for spdir in dirsToRun:
    spdirpath = os.path.join(args.BUSCO, spdir)
    sp_folders.append(spdir)
prefixes = {}
prefixes_rev = {}
for sp in sp_folders:
    #       print("spname is {}".format(sp))
    prefix = ""
    longname = sp
    longname = re.sub(r'_$', '', longname)
    spmod = re.sub(r'(cf|sp)\._', '', longname)
    name = spmod.split("_", 2)
    if len(name) == 1:
        prefix = name[0]
    elif len(name) ==2 or len(name[2]) == 0:
        prefix = name[0][0] + name[0][1] + name[1][0:3]
    elif len(name) > 2:
        prefix =  name[0][0] + name[0][1] + name[1][0:3] + name[2]
    else:
        prefix = spmod
    prefix = re.sub(r'-','_',prefix)
    print(prefix,longname)
    prefixes[prefix] = sp
    prefixes_rev[sp] = prefix
    with open(args.prefixfile, "wt") as ofh:
        for p in sorted(prefixes):
            ofh.write("\t".join([p, prefixes[p]]) + "\n")
