#! /bin/bash

# Pipeline to preprocess the data obtained in the day 1 of 2022IK01
# Ikko Kimura, 2022/5/12, Osaka University
# this script should be run by cinet-cluster dx

##TODO

subj=$1

StudyDir=/project/proj_shibusawa/kimura/2022IK01/data
DicomDir=/project/proj_shibusawa/kimura/2022IK01/DICOM/anat
BCIL_DIR=/project/proj_shibusawa/kimura/Utils/BCILDCMCONVERT
HCP_SCRIPTS_DIR=/project/proj_shibusawa/kimura/Utils/HCP_Scripts

#subj=IK100TT

### STRUCTURAL MRI
echo "Converting nifti files for... ${subj}"
${BCIL_DIR}/bcil_dcm_convert.py ${StudyDir} ${DicomDir}/${subj}

echo "Starting the HCP pipeline for T1w/T2w data..."
${HCP_SCRIPTS_DIR}/PreFreeSurferPipelineBatch.sh --Subject=${subj} --StudyFolder=${StudyDir}
${HCP_SCRIPTS_DIR}/FreeSurferPipelineBatch.sh --Subject=${subj} --StudyFolder=${StudyDir}
${HCP_SCRIPTS_DIR}/PostFreeSurferPipelineBatch.sh --Subject=${subj} --StudyFolder=${StudyDir}

### TASK-FMRI
#1. preprocessing steps...
echo "Starting the HCP pipeline for task-fMRI data..."
${HCP_SCRIPTS_DIR}/GenericfMRIVolumeProcessingPipelineBatch_Day1_2022IK01.sh --Subject=${subj} --StudyFolder=${StudyDir}
${HCP_SCRIPTS_DIR}/GenericfMRISurfaceProcessingPipelineBatch_Day1_2022IK01.sh --Subject=${subj} --StudyFolder=${StudyDir}
#2. create files for 1st/2nd level analysis
echo "Preparing for 1st/2nd level analysis..."
TaskNameList="MOTOR"
DirectionList="1_AP 2_AP"
for task in ${TaskNameList}; do
	for direction in ${DirectionList}; do
		# Prepare for 1st level
		${HCP_SCRIPTS_DIR}/generate_level1_fsf_Day1_2022IK01.sh --studyfolder=${StudyDir} --subject=${subj} --taskname=${task}${direction} --templatedir=${HCP_SCRIPTS_DIR}/fsf_template --outdir=		${StudyDir}/${subj}/MNINonLinear/Results/${task}${direction}
		# Copy Flag
		evs_dir=/project/proj_shibusawa/kimura/Utils/HCP_Scripts/fsf_template/tmp/${task}${direction}
		dest_dir=${StudyDir}/${subj}/MNINonLinear/Results
		# copy files
		cp -rv ${evs_dir} ${dest_dir}
	done
	# Prepare for 2nd level
	mkdir -p ${StudyDir}/${subj}/MNINonLinear/Results/${task}
	cp -v ${HCP_SCRIPTS_DIR}/fsf_template/${task}_hp160_s4_level2.fsf ${StudyDir}/${subj}/MNINonLinear/Results/${task}
done

#3. run 1st/2nd level analysis
#echo "Running 1st/2nd level analysis..."
#${HCP_SCRIPTS_DIR}/TaskfMRIAnalysisBatch_Day1_2022IK01.sh --Subjlist=${subj} --StudyFolder=${StudyDir}
