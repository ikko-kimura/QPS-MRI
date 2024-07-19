#! /bin/bash

# Ikko Kimura, 2022/9/27, Osaka University added the line to obtain the seed from the peak (line 25)
# line 29 and 31 should be done after setting the peak vertex number by matlab manually

##TODO
# can line 29 and line 31 be done automatically?

odir=Task_n16

fname=${odir}/MOTOR_RIGHT_LEFT_dat_tstat

##1. 
Atlas=HCP_S1200_Atlas/Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii
fname=${odir}/MOTOR_RIGHT_LEFT_palm_merged_dpv_tstat_c1

# refine the data 
wb_command -cifti-math 'x>7' ${fname}_mask_1.dscalar.nii -var x ${fname}.dscalar.nii
wb_command -cifti-math 'x<-7' ${fname}_mask_2.dscalar.nii -var x ${fname}.dscalar.nii

wb_command -cifti-label-to-roi ${Atlas} ${odir}/lhM1.Atlas.32k_fs_LR.dscalar.nii -name L_4_ROI
wb_command -cifti-label-to-roi ${Atlas} ${odir}/rhM1.Atlas.32k_fs_LR.dscalar.nii -name R_4_ROI

wb_command -cifti-create-dense-from-template ${fname}_mask_1.dscalar.nii ${odir}/lhM1.Atlas.32k_fs_LR_corr.dscalar.nii -cifti ${odir}/lhM1.Atlas.32k_fs_LR.dscalar.nii
wb_command -cifti-create-dense-from-template ${fname}_mask_2.dscalar.nii ${odir}/rhM1.Atlas.32k_fs_LR_corr.dscalar.nii -cifti ${odir}/rhM1.Atlas.32k_fs_LR.dscalar.nii

# refine the mask only to precentral gyrus
wb_command -cifti-math 'x*y' MOTOR_mask_lhM1.dscalar.nii -var x ${fname}_mask_1.dscalar.nii -var y ${odir}/lhM1.Atlas.32k_fs_LR_corr.dscalar.nii
wb_command -cifti-math 'x*y' MOTOR_mask_rhM1.dscalar.nii -var x ${fname}_mask_2.dscalar.nii -var y ${odir}/rhM1.Atlas.32k_fs_LR_corr.dscalar.nii


##2. find the peak is another way to create the ROI
# wb_command -cifti-extrema ${odir}/MOTOR_RIGHT_LEFT_palm_merged_dpv_tstat_c1.dscalar.nii 6 0 COLUMN ${odir}/MOTOR_RIGHT_LEFT_dat_tstat_peak.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii -threshold -4 4

wb_command -cifti-dilate ${odir}/MOTOR_LEFT_M1_peak.dscalar.nii COLUMN 5 0 ${odir}/MOTOR_LEFT_M1_ROI.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii 

wb_command -cifti-dilate ${odir}/MOTOR_RIGHT_M1_peak.dscalar.nii COLUMN 5 0 ${odir}/MOTOR_RIGHT_M1_ROI.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii 

wb_command -cifti-dilate ${odir}/MOTOR_LEFT_M1_peak.dscalar.nii COLUMN 2 0 ${odir}/MOTOR_LEFT_M1_ROI_strict.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii 

wb_command -cifti-dilate ${odir}/MOTOR_RIGHT_M1_peak.dscalar.nii COLUMN 2 0 ${odir}/MOTOR_RIGHT_M1_ROI_strict.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii 

wb_command -cifti-dilate ${odir}/MOTOR_LEFT_M1_peak.dscalar.nii COLUMN 8 0 ${odir}/MOTOR_LEFT_M1_ROI_loose.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii 

wb_command -cifti-dilate ${odir}/MOTOR_RIGHT_M1_peak.dscalar.nii COLUMN 8 0 ${odir}/MOTOR_RIGHT_M1_ROI_loose.dscalar.nii -left-surface HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii 
