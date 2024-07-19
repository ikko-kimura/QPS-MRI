#! /bin/bash

# run tractography for dMRI data
# Ikko Kimura, RIKEN-BDR, Apr-2024

################################################
# Parse argument for subjectdir
################################################

#StudyFolder="$1"
#Subject=$(basename $2)

StudyFolder=/mnt/temp_data1/kimura_i/data
Subject=$1

T1wFolder=${StudyFolder}/${Subject}/T1w
DiffusionFolder=${StudyFolder}/${Subject}/T1w/Diffusion
DiffusionList="qps5_Diffusion1 qps5_Diffusion2 qps50_Diffusion1 qps50_Diffusion2"
#SurfaceROIFolder=/mnt/temp_data2/user/kimura_i/A23_new/surf_rois
#AtlasSpaceFolder=${StudyFolder}/${Subject}/MNINonLinear
ConfigFolder=/mnt/temp_data1/kimura_i/NHPHCPPipeline.dev/global/config/
nthr=12 # number of threads
num_tck=100M
num_reduce=10M
#HiResVol=0.32
#MNIHiResRef=${AtlasSpaceFolder}/T1w_restore.${HiResVol}.nii.gz

echo ${Subject}

RunTractography () {
for fname in ${DiffusionList}; do
	DiffusionFolderTmp=${StudyFolder}/${Subject}/T1w/${fname}
	mrconvert ${DiffusionFolderTmp}/data.nii.gz ${DiffusionFolderTmp}/data.mif -fslgrad ${DiffusionFolderTmp}/bvecs ${DiffusionFolderTmp}/bvals -force
done

mkdir ${DiffusionFolder}
mrcat ${T1wFolder}/qps5_Diffusion1/data.mif ${T1wFolder}/qps5_Diffusion2/data.mif ${T1wFolder}/qps50_Diffusion1/data.mif ${T1wFolder}/qps50_Diffusion2/data.mif ${DiffusionFolder}/data.mif

fslmerge -t ${DiffusionFolder}/nodif_brain_mask_all `ls ${T1wFolder}/*/nodif_brain_mask.nii.gz`
fslmaths ${DiffusionFolder}/nodif_brain_mask_all -Tmean -thr 0.99 -bin ${DiffusionFolder}/nodif_brain_mask
mrconvert ${DiffusionFolder}/nodif_brain_mask.nii.gz ${DiffusionFolder}/mask.mif

dwi2response dhollander ${DiffusionFolder}/data.mif ${DiffusionFolder}/wm.txt ${DiffusionFolder}/gm.txt ${DiffusionFolder}/csf.txt -voxels ${DiffusionFolder}/voxels.mif
dwi2fod msmt_csd ${DiffusionFolder}/data.mif ${DiffusionFolder}/wm.txt ${DiffusionFolder}/wmfod.mif ${DiffusionFolder}/gm.txt ${DiffusionFolder}/gmfod.mif ${DiffusionFolder}/csf.txt ${DiffusionFolder}/csffod.mif  -mask ${DiffusionFolder}/mask.mif
mtnormalise ${DiffusionFolder}/wmfod.mif ${DiffusionFolder}/wmfod_norm.mif ${DiffusionFolder}/csffod.mif ${DiffusionFolder}/csffod_norm.mif -mask ${DiffusionFolder}/mask.mif
#mrconvert ${T1wFolder}/T1w_acpc_dc_restore.nii.gz ${DiffusionFolder}/T1w.mif
#5ttgen freesurfer ${DiffusionFolder}/T1w.mif ${DiffusionFolder}/5tt.mif
## create 5tt.mif file from freesurfer outputs
echo "Creating 5tt.mif files..."
# import masks
wb_command -volume-label-import ${T1wFolder}/wmparc.nii.gz ${ConfigFolder}/FreeSurferWMRegLut+CEREBELLUM.txt ${T1wFolder}/wmparc_wm.nii.gz -discard-others -drop-unused-labels
wb_command -volume-label-import ${T1wFolder}/wmparc.nii.gz ${ConfigFolder}/FreeSurferCSFRegLut+OTHERS.txt ${T1wFolder}/wmparc_csf.nii.gz -discard-others -drop-unused-labels
wb_command -volume-label-import ${T1wFolder}/ribbon.nii.gz ${ConfigFolder}/FreeSurferCorticalLabelTableLut.txt ${T1wFolder}/wmparc_cortical.nii.gz -discard-others -drop-unused-labels
wb_command -volume-label-import ${T1wFolder}/wmparc.nii.gz ${ConfigFolder}/FreeSurferSubcorticalLabelTableLut+claustrum.txt ${T1wFolder}/wmparc_subcortical.nii.gz -discard-others -drop-unused-labels
# binarize
for fname in wm csf cortical subcortical; do
fslmaths ${T1wFolder}/wmparc_${fname} -bin ${T1wFolder}/wmparc_${fname}_bin
done
fslmaths ${T1wFolder}/brainmask_fs -mul 0 ${T1wFolder}/wmparc_path
# create 5tt
fslmerge -t ${T1wFolder}/5tt ${T1wFolder}/wmparc_cortical_bin ${T1wFolder}/wmparc_subcortical_bin ${T1wFolder}/wmparc_wm_bin ${T1wFolder}/wmparc_csf_bin ${T1wFolder}/wmparc_path
mrconvert ${T1wFolder}/5tt.nii.gz ${DiffusionFolder}/5tt.mif -force

echo "Removing temporary files..."
for fname in wm csf cortical subcortical; do
rm ${T1wFolder}/wmparc_${fname}.nii.gz
rm ${T1wFolder}/wmparc_${fname}_bin.nii.gz
done
rm ${T1wFolder}/wmparc_path.nii.gz
rm ${T1wFolder}/5tt.nii.gz
###

5tt2gmwmi ${DiffusionFolder}/5tt.mif ${DiffusionFolder}/gmwmSeed.mif -force
tckgen -act ${DiffusionFolder}/5tt.mif -backtrack -seed_gmwmi ${DiffusionFolder}/gmwmSeed.mif -force -crop_at_gmwmi -nthreads ${nthr} -maxlength 300 -cutoff 0.06 -select ${num_tck} ${DiffusionFolder}/wmfod_norm.mif ${DiffusionFolder}/tracks${num_tck}.tck
tcksift2 -act ${DiffusionFolder}/5tt.mif -nthreads ${nthr} ${DiffusionFolder}/tracks${num_tck}.tck ${DiffusionFolder}/wmfod_norm.mif ${DiffusionFolder}/sift2_tracks_${num_tck}.txt -force
#tcksift ${DiffusionFolder}/tracks${num_tck}.tck ${DiffusionFolder}/wmfod_norm.mif ${DiffusionFolder}/tracks${num_tck}_sift${num_reduce}.tck -act ${DiffusionFolder}/5tt.mif -term_number ${num_reduce} -nthreads ${nthr} -force
}

CreateROI () {
mkdir ${T1wFolder}/ROIs
wb_command -metric-to-volume-mapping /mnt/temp_data1/kimura_i/data/ROI/MOTOR_LEFT_M1_ROI.func.gii ${T1wFolder}/fsaverage_LR32k/${Subject}.L.midthickness_MSMAll.32k_fs_LR.surf.gii ${T1wFolder}/T1w_acpc_dc_restore.nii.gz -ribbon-constrained ${T1wFolder}/fsaverage_LR32k/${Subject}.L.white_MSMAll.32k_fs_LR.surf.gii ${T1wFolder}/fsaverage_LR32k/${Subject}.L.pial_MSMAll.32k_fs_LR.surf.gii ${T1wFolder}/ROIs/MOTOR.L.nii.gz
wb_command -metric-to-volume-mapping /mnt/temp_data1/kimura_i/data/ROI/MOTOR_RIGHT_M1_ROI.func.gii ${T1wFolder}/fsaverage_LR32k/${Subject}.R.midthickness_MSMAll.32k_fs_LR.surf.gii ${T1wFolder}/T1w_acpc_dc_restore.nii.gz -ribbon-constrained ${T1wFolder}/fsaverage_LR32k/${Subject}.R.white_MSMAll.32k_fs_LR.surf.gii ${T1wFolder}/fsaverage_LR32k/${Subject}.R.pial_MSMAll.32k_fs_LR.surf.gii ${T1wFolder}/ROIs/MOTOR.R.nii.gz

fslmaths ${T1wFolder}/ROIs/MOTOR.L.nii.gz -bin ${T1wFolder}/ROIs/MOTOR.L.nii.gz
fslmaths ${T1wFolder}/ROIs/MOTOR.R.nii.gz -bin ${T1wFolder}/ROIs/MOTOR.R.nii.gz

flirt -in ${T1wFolder}/ROIs/MOTOR.R.nii.gz -ref ${DiffusionFolder}/nodif_brain_mask -applyisoxfm 2.0 -interp nearestneighbour -out ${T1wFolder}/ROIs/MOTOR.R.nii.gz
flirt -in ${T1wFolder}/ROIs/MOTOR.L.nii.gz -ref ${DiffusionFolder}/nodif_brain_mask -applyisoxfm 2.0 -interp nearestneighbour -out ${T1wFolder}/ROIs/MOTOR.L.nii.gz

#fslmaths ${T1wFolder}/ROIs/MOTOR.L.nii.gz -bin ${T1wFolder}/ROIs/MOTOR.L.nii.gz 
#fslmaths ${T1wFolder}/ROIs/MOTOR.R.nii.gz -bin ${T1wFolder}/ROIs/MOTOR.R.nii.gz
mrconvert -force ${T1wFolder}/ROIs/MOTOR.L.nii.gz ${T1wFolder}/ROIs/MOTOR.L.mif
mrconvert -force ${T1wFolder}/ROIs/MOTOR.R.nii.gz ${T1wFolder}/ROIs/MOTOR.R.mif
}

Calculate () {
tckedit ${DiffusionFolder}/tracks${num_tck}.tck -nthreads ${nthr} -include ${T1wFolder}/ROIs/MOTOR.L.mif -include ${T1wFolder}/ROIs/MOTOR.R.mif -force -tck_weights_in ${DiffusionFolder}/sift2_tracks_${num_tck}.txt -tck_weights_out ${DiffusionFolder}/sift2_tracks_${num_tck}_BiM1.txt ${DiffusionFolder}/tracks${num_tck}_BiM1.tck

tckmap -force -tck_weights_in ${DiffusionFolder}/sift2_tracks_${num_tck}_BiM1.txt -nthreads ${nthr} -template ${DiffusionFolder}/data.mif ${DiffusionFolder}/tracks${num_tck}_BiM1.tck ${DiffusionFolder}/tracks${num_tck}_BiM1.mif
mrconvert ${DiffusionFolder}/tracks${num_tck}_BiM1.mif ${DiffusionFolder}/tracks${num_tck}_BiM1.nii.gz -force

#refine to corpus callosum
fslmaths ${T1wFolder}/wmparc.nii.gz -thr 251 -uthr 255 -bin ${T1wFolder}/ROIs/wmparc_CC.nii.gz 
flirt -in ${T1wFolder}/ROIs/wmparc_CC.nii.gz -ref ${DiffusionFolder}/nodif_brain_mask -applyisoxfm 2.0 -interp nearestneighbour -out ${T1wFolder}/ROIs/wmparc_CC.nii.gz
fslmaths ${DiffusionFolder}/tracks${num_tck}_BiM1.nii.gz -mul ${T1wFolder}/ROIs/wmparc_CC.nii.gz ${DiffusionFolder}/tracks${num_tck}_BiM1_CC.nii.gz

#Calculate weighted mean
for fname in FA MD; do
	touch ${DiffusionFolder}/${fname}
	touch ${DiffusionFolder}/${fname}_CC
	for mode in qps5_Diffusion1 qps5_Diffusion2 qps50_Diffusion1 qps50_Diffusion2; do
		wb_command -volume-weighted-stats ${StudyFolder}/${Subject}/T1w/${mode}/data_${fname}.nii.gz -mean -weight-volume ${DiffusionFolder}/tracks${num_tck}_BiM1.nii.gz >> ${DiffusionFolder}/${fname}
		wb_command -volume-weighted-stats ${StudyFolder}/${Subject}/T1w/${mode}/data_${fname}.nii.gz -mean -weight-volume ${DiffusionFolder}/tracks${num_tck}_BiM1_CC.nii.gz >> ${DiffusionFolder}/${fname}_CC
	done
done

for fname in FA MD; do
        touch ${DiffusionFolder}/${fname}_MOTOR.L
        touch ${DiffusionFolder}/${fname}_MOTOR.R
        for mode in qps5_Diffusion1 qps5_Diffusion2 qps50_Diffusion1 qps50_Diffusion2; do
                wb_command -volume-stats ${StudyFolder}/${Subject}/T1w/${mode}/data_${fname}.nii.gz -reduce MEAN -roi ${T1wFolder}/ROIs/MOTOR.L.nii.gz >> ${DiffusionFolder}/${fname}_MOTOR.L
                wb_command -volume-stats ${StudyFolder}/${Subject}/T1w/${mode}/data_${fname}.nii.gz -reduce MEAN -roi ${T1wFolder}/ROIs/MOTOR.R.nii.gz >> ${DiffusionFolder}/${fname}_MOTOR.R
        done
done
}

###
RunTractography
CreateROI
Calculate
