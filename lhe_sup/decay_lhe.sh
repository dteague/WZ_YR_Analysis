#!/bin/bash

decayW=true
decayZ=true

decay_dir=DECAY_DIRECTORY

dirname=$1
if [ -z $dirname ]; then
    echo "Usage requires:"
    echo "./decay_lhe.sh <DECAY DIRECTORY>"
    exit 1
fi
if [ ! -d $dirname ];then
    echo "No directory of the name:"
    echo "     $dirname"
    echo "found. Please submit again"
    exit 1
fi

ls $dirname/*lhe.gz &>/dev/null
if [ $? -ne 0 ]; then
    echo "No files have the ending '.lhe.gz', either change filenames or give a different directory"
    exit 1
fi

echo "DECAYING LHE FILES IN DIRECTORY: $dirname"
for file in $(ls $dirname/*lhe.gz 2>/dev/null); do
    base=$(echo $file | sed -e 's/.lhe.gz//g' -e "s@$dirname/@@g")
    infile=${base}.lhe
    outfile=${base}_decayed.lhe
    echo "$infile ----> $outfile"
    gunzip < $file > TMP_INFILE_DECAY.lhe
    if [[ ! -z $decayW && $decayW == "true" ]]; then
	sed 's/PARTICLE/w+/g' < decay_template.in | $decay_dir/decay
	mv TMP_OUTFILE_DECAY.lhe TMP_INFILE_DECAY.lhe
	sed 's/PARTICLE/w-/g' < decay_template.in | $decay_dir/decay
	mv TMP_OUTFILE_DECAY.lhe TMP_INFILE_DECAY.lhe
    fi
    if [[ ! -z $decayZ && $decayZ == "true" ]]; then
	sed 's/PARTICLE/z/g' < decay_template.in | $decay_dir/decay
	mv TMP_OUTFILE_DECAY.lhe TMP_INFILE_DECAY.lhe
    fi
    gzip < TMP_INFILE_DECAY.lhe > $dirname/$outfile
    rm TMP_INFILE_DECAY.lhe
done