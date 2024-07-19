#! /bin/bash

# create the surface area file required for PALM
# Ikko Kimura, 2022/9/21

base=data #/IK101SS/MNINonLinear/fsaverage_LR32k

for subj in `cat subj_list/subj_list.txt` ; do
	for hemi in L R; do
		wb_command -surface-vertex-areas ${base}/${subj}/MNINonLinear/fsaverage_LR32k/${subj}.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ${base}/${subj}/MNINonLinear/fsaverage_LR32k/${subj}.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii
	done
done

for hemi in L R; do
	MERGELIST=""
	for subj in `cat subj_list/subj_list.txt` ; do
   		MERGELIST="${MERGELIST} -metric ${base}/${subj}/MNINonLinear/fsaverage_LR32k/${subj}.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii"
	done
	wb_command -metric-merge ${hemi}_midthick_va.func.gii ${MERGELIST}
	wb_command -metric-reduce ${hemi}_midthick_va.func.gii MEAN ${hemi}_midthick_area.func.gii
done
