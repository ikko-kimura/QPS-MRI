#! /bin/bash

# calculate all needed dMRI-derived metrics and project the result onto the surface
# Ikko Kimura, 2022/1/1, Osaka University 
# Ikko Kimura, 2022/1/5, Osaka University, added NODDI (line56)

##TODO
# line 35 BE CAREFUL this is for multi-shell data taken with b=1000 and b=2000


StudyFolder=$1 #/project/amano-g/kimura/QPS_MRI/qps5
Subject=$2 #KS000MS
dti_folder=$3 #Diffusion1

# HCP PIPELINE
EnvironmentScript=/project/proj_shibusawa/kimura/2021IK01/scripts/HCP_Scripts/SetUpHCPPipeline.sh
dMRI_utils=/project/proj_shibusawa/kimura/Utils/dMRI/utils
#RegName="MSMAll" # added the varible
thr="3100,100,50" #b-value upper and lower threshold, b=0 upper threshold for HCP
b0thresh=20
# Folder Name
T1wFOLDER="T1w"
DWIT1wFOLDER="${dti_folder}"
DWIT1wFolder=$StudyFolder/$Subject/$T1wFOLDER/$DWIT1wFOLDER

source $EnvironmentScript
source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions

######################## THE END OF SETTING UP THE PARAMETERS

##1. calculate snr
${dMRI_utils}/dwistats $DWIT1wFolder/data.nii.gz $DWIT1wFolder/bvals $DWIT1wFolder/data $DWIT1wFolder/nodif_brain_mask.nii.gz $b0thresh

##2. calculate dti metrics
echo "calculating dti metrics..."
dtifit -k $DWIT1wFolder/data.nii.gz -b $DWIT1wFolder/bvals -r $DWIT1wFolder/bvecs -m $DWIT1wFolder/nodif_brain_mask.nii.gz -o $DWIT1wFolder/data
fslmaths $DWIT1wFolder/data_L1 $DWIT1wFolder/data_AD
fslmaths $DWIT1wFolder/data_L2 -add $DWIT1wFolder/data_L3 -div 2 $DWIT1wFolder/data_RD
