#! /bin/bash

# Pipeline to preprocess all fmri data obtained in 2021IK04
# this pipeline must be run with cinet-clutser dx, AND after hand classification of FIX 
# Ikko Kimura, Osaka University, 2022/5/24
# Ikko Kimura, Osaka University, 2022/5/30, revised to merge the processing steps of qps5 and qps50 sessions 

subj=$1 #KS000MS

##TODO

StudyDir=/project/proj_shibusawa/kimura/2022IK01/data
HCP_SCRIPTS_DIR=/project/proj_shibusawa/kimura/Utils/HCP_Scripts
Subjlist=$subj #Space delimited list of subject IDs
#fMRINames="qps5_REST1_AP qps5_REST2_AP" # List of fMRI runs
fMRINames="qps5_REST1_AP qps5_REST2_AP qps50_REST1_AP qps50_REST2_AP" # List of fMRI runs
HighPass="2000" #"2000"

export HCPPIPEDIR="/home/ikimura/HCPpipelines"
export FSL_FIXDIR=""

EnvironmentScript="/project/proj_shibusawa/kimura/2021IK01/scripts/HCP_Scripts/SetUpHCPPipeline.sh" # Pipeline environment script
source ${EnvironmentScript}


###1. ReApplyFixPipeline
for Subject in ${Subjlist} ; do
  for fMRIName in ${fMRINames} ; do
${HCPPIPEDIR}/ICAFIX/ReApplyFixPipeline.sh --study-folder=${StudyDir} --subject=${Subject} --fmri-name=${fMRIName} --high-pass=${HighPass}
  done
done

###2. MSMAll
${HCP_SCRIPTS_DIR}/MSMAllPipelineBatch.sh --StudyFolder=${StudyDir} --Subjlist=${Subject} 

###3. Dedrift and resample
${HCP_SCRIPTS_DIR}/DeDriftAndResamplePipelineBatch.sh --StudyFolder=${StudyDir} --Subjlist=${Subject}

###4. TASK FMRI in Day1 (this must be done after MSMAll reg is done, I think...)
# really need dedrift steps in TASK fMRI?
echo "Running 1st/2nd level analysis..."
${HCP_SCRIPTS_DIR}/TaskfMRIAnalysisBatch_Day1_2022IK01.sh --Subjlist=${subj} --StudyFolder=${StudyDir}
