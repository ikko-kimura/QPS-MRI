#! /bin/bash

# Merge palm results with dscalar format
# Ikko Kimura, 2022/9/23, Osaka University
# Ikko Kimura, Apr-2024, RIKEN-BDR modified the code for -corrcon and -corrmod

##TODO

base=/mnt/temp_data1/kimura_i/data/PALM

###1. for functional changes
fname=FC
for mode in m1 m2 m3; do
	for cont in c1 c2; do
		wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_L_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_R_tfce_tstat_mcfwep_${mode}_${cont}.gii
		echo "${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
	done
done
# Sensitivity Analaysis (mean FD removed)
fname=FC_FD
for mode in m1 m2 m3; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_L_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_R_tfce_tstat_mcfwep_${mode}_${cont}.gii
        	echo "${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
	done
done
# Sensitivity Analysis (mean FD and SSS removed)
fname=FC_FD_SSS
for mode in m1 m2 m3; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_L_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_R_tfce_tstat_mcfwep_${mode}_${cont}.gii
        	echo "${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
	done
done

###2. for microstructural changes
fname=DTI
for mode in m1 m2 m3 m4 m5 m6; do
        for cont in c1 c2; do
		wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_L_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_R_tfce_tstat_mcfwep_${mode}_${cont}.gii
		echo "${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
	done	
done
# Sensitivity Analysis (abs mov and rel mov removed)
fname=DTI_mov
for mode in m1 m2 m3 m4 m5 m6; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_L_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_R_tfce_tstat_mcfwep_${mode}_${cont}.gii
        	echo "${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
	done
done

###3. for regression analysis
echo "regression..."
fname=DTI
for mode in m1 m2; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_L_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_R_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii
        	wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_L_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_R_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii
		echo "${base}/${fname}_palm_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
		echo "${base}/${fname}_palm_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
		wb_command -cifti-stats ${base}/${fname}_palm_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
	done
done

for mode in m1 m2; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_FD_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_FD_qps5_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_FD_L_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_FD_R_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_FD_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_FD_qps50_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_FD_L_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_FD_R_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii
                echo "${base}/${fname}_palm_reg_FD_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
                wb_command -cifti-stats ${base}/${fname}_palm_reg_FD_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
                echo "${base}/${fname}_palm_reg_FD_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
                wb_command -cifti-stats ${base}/${fname}_palm_reg_FD_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
        done
done

for mode in m1 m2; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_FD_SSS_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_FD_SSS_qps5_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_FD_SSS_L_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_FD_SSS_R_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_FD_SSS_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_FD_SSS_qps50_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_FD_SSS_L_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_FD_SSS_R_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii
                echo "${base}/${fname}_palm_reg_FD_SSS_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
                wb_command -cifti-stats ${base}/${fname}_palm_reg_FD_SSS_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
                echo "${base}/${fname}_palm_reg_FD_SSS_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
                wb_command -cifti-stats ${base}/${fname}_palm_reg_FD_SSS_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
        done
done

fname=DTI_mov
for mode in m1 m2; do
        for cont in c1 c2; do
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_L_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_R_qps5_tfce_tstat_mcfwep_${mode}_${cont}.gii
                wb_command -cifti-create-dense-from-template ${base}/qps5/lhM1_rho_diff_all.dscalar.nii ${base}/${fname}_palm_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -volume-all ${base}/${fname}_palm_sub_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.nii \
-metric CORTEX_LEFT ${base}/${fname}_palm_reg_L_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii -metric CORTEX_RIGHT ${base}/${fname}_palm_reg_R_qps50_tfce_tstat_mcfwep_${mode}_${cont}.gii
                echo "${base}/${fname}_palm_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
                wb_command -cifti-stats ${base}/${fname}_palm_reg_qps5_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
                echo "${base}/${fname}_palm_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii"
                wb_command -cifti-stats ${base}/${fname}_palm_reg_qps50_tfce_tstat_mcfwep_${mode}_${cont}.dscalar.nii -reduce MAX
        done
done
