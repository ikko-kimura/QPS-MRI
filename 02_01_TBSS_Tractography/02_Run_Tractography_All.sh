#! /bin/bash

for subj in `cat $1`; do
./Run_Tractography.sh ${subj}
done
