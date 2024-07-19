#! /bin/bash

# Pipeline to preprocess all fmri data obtained in 2021IK04
# this pipeline msut be run from cinet-clutser dx
# Ikko Kimura, Osaka University, 2022/5/18
# Ikko Kimura, Osaka University, 2022/5/26 try to do all sessions (i.e. Day1, qps5, qps50) in one directory
# RAWDATA: Day1-->RawData, qps5-->RawData_qps5, qps50-->RawData_qps50
# RESULTS: REST1_AP-->qps5_REST1_AP

type=$1 #qps5
subj=$2 #KS000MS

##TODO

StudyDir=/project/proj_shibusawa/kimura/2022IK01/data
DicomDir=/project/proj_shibusawa/kimura/2022IK01/DICOM/${type}
BCIL_DIR=/project/proj_shibusawa/kimura/Utils/BCILDCMCONVERT
HCP_SCRIPTS_DIR=/project/proj_shibusawa/kimura/Utils/HCP_Scripts
AnatDir=/project/proj_shibusawa/kimura/2022IK01/data/${subj}

# 
case ${type} in
	qps5) 
		${BCIL_DIR}/bcil_dcm_convert_qps5.py -o ${StudyDir} ${DicomDir}/${subj}
		;;
	qps50)
		${BCIL_DIR}/bcil_dcm_convert_qps50.py -o ${StudyDir} ${DicomDir}/${subj}
		;;
esac

###2. PREPROCESSING STEPS FOR RESTING-STATE FMRI DATA
echo "Starting the HCP pipeline for fMRI data..."
${HCP_SCRIPTS_DIR}/GenericfMRIVolumeProcessingPipelineBatch_2022IK01_Day2.sh --Subject=${subj} --StudyFolder=${StudyDir} --type=${type} --session=1
${HCP_SCRIPTS_DIR}/GenericfMRIVolumeProcessingPipelineBatch_2022IK01_Day2.sh --Subject=${subj} --StudyFolder=${StudyDir} --type=${type} --session=2

${HCP_SCRIPTS_DIR}/GenericfMRISurfaceProcessingPipelineBatch_2022IK01_Day2.sh --Subject=${subj} --StudyFolder=${StudyDir} --type=${type}
${HCP_SCRIPTS_DIR}/IcaFixProcessingBatch_2022IK01_Day2.sh --Subject=${subj} --StudyFolder=${StudyDir} --type=${type}
