#! /bin/bash

# Pipeline to generate QC summary for rsfMRI data obtained in 2022IK01
# this pipeline must be run from cinet-clutser dx (probably possible with other cluters)
# Ikko Kimura, Osaka University, 2022/9/7

StudyFolder=/project/proj_shibusawa/kimura/2022IK01/data

### HCP500 Subjects With Complete Structural, fMRI, and Diffusion###
Subject="IK101SS"
fMRINames="qps5_REST1_AP qps5_REST2_AP qps50_REST1_AP qps50_REST2_AP"
OrigHighPass="2000" #Specified in Sigma
Caret7_Command="wb_command"
GitRepo="/home/ikimura/HCPpipelines"

#RegName="MSMRSNOrig3_d26_DR_DeDrift"
#RegName="MSMAll_2_d41_WRN_DeDrift"
RegName="NONE"

LowResMesh="32"
FinalfMRIResolution="2"
BrainOrdinatesResolution="2"
SmoothingFWHM="2"
OutputProcSTRING="_hp2000_clean"
dlabelFile="NONE"
MatlabRunMode="1"
BCMode="CORRECT" #One of REVERT (revert bias field correction), NONE (don't change biasfield correction), CORRECT (revert original bias field correction and apply new one, requires ??? to be present)
OutSTRING="stats"
OutSTRING="stats_bc"
WM="NONE"
WM="${GitRepo}/global/config/FreeSurferWMRegLut.txt"
CSF="NONE"
CSF="${GitRepo}/global/config/FreeSurferCSFRegLut.txt"

EnvironmentScript="/project/proj_shibusawa/kimura/Utils/HCP_Scripts/SetUpHCPPipeline.sh" #Pipeline environment script

# Set up pipeline environment variables and software
. ${EnvironmentScript}

# Log the originating call
echo "$@"

#Reversed to prevent collisions
for fMRIName in ${fMRINames} ; do
    ${HCPPIPEDIR}/RestingStateStats/RestingStateStats.sh \
      --path=${StudyFolder} \
      --subject=${Subject} \
      --fmri-name=${fMRIName} \
      --high-pass=${OrigHighPass} \
      --reg-name=${RegName} \
      --low-res-mesh=${LowResMesh} \
      --final-fmri-res=${FinalfMRIResolution} \
      --brain-ordinates-res=${BrainOrdinatesResolution} \
      --smoothing-fwhm=${SmoothingFWHM} \
      --output-proc-string=${OutputProcSTRING} \
      --dlabel-file=${dlabelFile} \
      --matlab-run-mode=${MatlabRunMode} \
      --bc-mode=${BCMode} \
      --out-string=${OutSTRING} \
      --wm=${WM} \
      --csf=${CSF}
    
done


