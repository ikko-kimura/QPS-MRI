#! /bin/bash

# Pipeline to preprocess all dmri data obtained in 2021IK04
# This preprocessing steps must be done after the fmri pipeline AND @sg
# Ikko Kimura, Osaka University, 2022/5/18
# Ikko Kimura, Osaka University, 2022/5/31, merged qps5 and qps50 sessions

## TODO

#type=$1 #qps5
subj=$1 #KS000MS

StudyDir=/project/proj_shibusawa/kimura/2022IK01/data
HCP_SCRIPTS_DIR=/project/proj_shibusawa/kimura/Utils/HCP_Scripts
dMRI_script=/project/proj_shibusawa/kimura/Utils/dMRI

for type in qps5 qps50; do
for sess in 1 2;do
###1. PREPROCESSING
echo "Starting the HCP pipeline for dMRI data..."
${HCP_SCRIPTS_DIR}/DiffusionPreprocessingBatch_2022IK01_Day2.sh --Subject=${subj} --StudyFolder=${StudyDir} --type=${type} --session=${sess}
echo "Done!"

###2. CALLCULATE DTI METRICS
echo "Calulating DTI metrics..."
${dMRI_script}/dmri_fit_model_2022IK01_Day2.sh ${StudyDir} ${subj} ${type}_Diffusion${sess}
echo "Done!"

###3. SURFACE MAP THE RESULTS
echo "Surface map..."
${dMRI_script}/dmri_surface_map.sh ${StudyDir} ${subj} ${type}_Diffusion${sess} /project/proj_shibusawa/kimura/2022IK01/scripts/fname_list.txt # fname_list.txt is the list of the file name
echo "Done!"

done
done
