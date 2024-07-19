#! /bin/bash

# run palm for all the data
# Ikko Kimura, 2022/8/25, Osaka University
# Ikko Kimura, Apr-2024, RIKEN-BDR added -corrcon and -corrmod option

base=/mnt/temp_data1/kimura_i/data/PALM
cont=Mean_n16
niter=2000
PALM=/mnt/temp_data1/kimura_i/bin/palm-alpha119

###0. PREPARE DATASET FOR PALM
echo "Sperating data..."
for fname in FA MD; do
	for cond in qps5 qps50 qps5_qps50; do
		wb_command -cifti-separate ${base}/${cond}/${fname}_diff_all.dscalar.nii COLUMN -volume-all ${base}/${cond}/${fname}_diff_all_sub.nii -metric CORTEX_LEFT ${base}/${cond}/${fname}_diff_all_L.func.gii -metric CORTEX_RIGHT ${base}/${cond}/${fname}_diff_all_R.func.gii
		wb_command -cifti-separate ${base}/${cond}/${fname}_diff_all_mov.dscalar.nii COLUMN -volume-all ${base}/${cond}/${fname}_mov_diff_all_sub.nii -metric CORTEX_LEFT ${base}/${cond}/${fname}_mov_diff_all_L.func.gii -metric CORTEX_RIGHT ${base}/${cond}/${fname}_mov_diff_all_R.func.gii
		for hemi in L R; do
			wb_command -gifti-convert BASE64_BINARY ${base}/${cond}/${fname}_diff_all_${hemi}.func.gii ${base}/${cond}/${fname}_diff_all_${hemi}.func.gii
			wb_command -gifti-convert BASE64_BINARY ${base}/${cond}/${fname}_mov_diff_all_${hemi}.func.gii ${base}/${cond}/${fname}_mov_diff_all_${hemi}.func.gii
		done
	done
done

for fname in lhM1_rho; do
        for cond in qps5 qps50 qps5_qps50; do
                wb_command -cifti-separate ${base}/${cond}/${fname}_diff_all.dscalar.nii COLUMN -volume-all ${base}/${cond}/${fname}_diff_all_sub.nii -metric CORTEX_LEFT ${base}/${cond}/${fname}_diff_all_L.func.gii -metric CORTEX_RIGHT ${base}/${cond}/${fname}_diff_all_R.func.gii
                wb_command -cifti-separate ${base}/${cond}/${fname}_diff_all_FD.dscalar.nii COLUMN -volume-all ${base}/${cond}/${fname}_FD_diff_all_sub.nii -metric CORTEX_LEFT ${base}/${cond}/${fname}_FD_diff_all_L.func.gii -metric CORTEX_RIGHT ${base}/${cond}/${fname}_FD_diff_all_R.func.gii
                wb_command -cifti-separate ${base}/${cond}/${fname}_diff_all_FD_SSS.dscalar.nii COLUMN -volume-all ${base}/${cond}/${fname}_FD_SSS_diff_all_sub.nii -metric CORTEX_LEFT ${base}/${cond}/${fname}_FD_SSS_diff_all_L.func.gii -metric CORTEX_RIGHT ${base}/${cond}/${fname}_FD_SSS_diff_all_R.func.gii
		for hemi in L R; do
                        wb_command -gifti-convert BASE64_BINARY ${base}/${cond}/${fname}_diff_all_${hemi}.func.gii ${base}/${cond}/${fname}_diff_all_${hemi}.func.gii
			wb_command -gifti-convert BASE64_BINARY ${base}/${cond}/${fname}_FD_diff_all_${hemi}.func.gii ${base}/${cond}/${fname}_FD_diff_all_${hemi}.func.gii
			wb_command -gifti-convert BASE64_BINARY ${base}/${cond}/${fname}_FD_SSS_diff_all_${hemi}.func.gii ${base}/${cond}/${fname}_FD_SSS_diff_all_${hemi}.func.gii
                done
        done
done

###1. RUN PALM
##1-1. For Subcortical areas
echo "For subcortical areas..."
#1-1-1. for DTI (microsctural changes)
${PALM}/palm -i ${base}/qps5/FA_diff_all_sub.nii -i ${base}/qps5/MD_diff_all_sub.nii -i ${base}/qps50/FA_diff_all_sub.nii -i ${base}/qps50/MD_diff_all_sub.nii -i ${base}/qps5_qps50/FA_diff_all_sub.nii -i ${base}/qps5_qps50/MD_diff_all_sub.nii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -transposedata -logp -o ${base}/DTI_palm_sub -T -ise -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub.txt
#1-1-2. for DTI (removing the effect of movement)
${PALM}/palm -i ${base}/qps5/FA_mov_diff_all_sub.nii -i ${base}/qps5/MD_mov_diff_all_sub.nii -i ${base}/qps50/FA_mov_diff_all_sub.nii -i ${base}/qps50/MD_mov_diff_all_sub.nii -i ${base}/qps5_qps50/FA_mov_diff_all_sub.nii -i ${base}/qps5_qps50/MD_mov_diff_all_sub.nii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -transposedata -logp -o ${base}/DTI_mov_palm_sub -T -ise -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_mov_palm_sub.txt

#1-1-3. for FC (functional changes)
${PALM}/palm -i ${base}/qps5/lhM1_rho_diff_all_sub.nii -i ${base}/qps50/lhM1_rho_diff_all_sub.nii -i ${base}/qps5_qps50/lhM1_rho_diff_all_sub.nii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -transposedata -logp -o ${base}/FC_palm_sub -T -ise -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/FC_palm_sub.txt
#1-1-4. for FC (sensitivity analysis)
${PALM}/palm -i ${base}/qps5/lhM1_rho_FD_diff_all_sub.nii -i ${base}/qps50/lhM1_rho_FD_diff_all_sub.nii -i ${base}/qps5_qps50/lhM1_rho_FD_diff_all_sub.nii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -transposedata -logp -o ${base}/FC_FD_palm_sub -T -ise -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/FC_FD_palm_sub.txt
${PALM}/palm -i ${base}/qps5/lhM1_rho_FD_SSS_diff_all_sub.nii -i ${base}/qps50/lhM1_rho_FD_SSS_diff_all_sub.nii -i ${base}/qps5_qps50/lhM1_rho_FD_SSS_diff_all_sub.nii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -transposedata -logp -o ${base}/FC_FD_SSS_palm_sub -T -ise -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/FC_FD_SSS_palm_sub.txt

#1-1-5. regression analysis
${PALM}/palm -i ${base}/qps5/FA_diff_all_sub.nii -i ${base}/qps5/MD_diff_all_sub.nii -d ${base}/flag/FC_qps5_n16.mat -t ${base}/flag/FC_qps5_n16.con -transposedata -logp -o ${base}/DTI_palm_sub_reg_qps5 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub_reg_qps5.txt
${PALM}/palm -i ${base}/qps50/FA_diff_all_sub.nii -i ${base}/qps50/MD_diff_all_sub.nii -d ${base}/flag/FC_qps50_n16.mat -t ${base}/flag/FC_qps50_n16.con -transposedata -logp -o ${base}/DTI_palm_sub_reg_qps50 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub_reg_qps50.txt

${PALM}/palm -i ${base}/qps5/FA_diff_all_sub.nii -i ${base}/qps5/MD_diff_all_sub.nii -d ${base}/flag/FC_qps5_FD_n16.mat -t ${base}/flag/FC_qps5_FD_n16.con -transposedata -logp -o ${base}/DTI_palm_sub_reg_FD_qps5 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub_reg_FD_qps5.txt
${PALM}/palm -i ${base}/qps50/FA_diff_all_sub.nii -i ${base}/qps50/MD_diff_all_sub.nii -d ${base}/flag/FC_qps50_FD_n16.mat -t ${base}/flag/FC_qps50_FD_n16.con -transposedata -logp -o ${base}/DTI_palm_sub_reg_FD_qps50 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub_reg_FD_qps50.txt

${PALM}/palm -i ${base}/qps5/FA_diff_all_sub.nii -i ${base}/qps5/MD_diff_all_sub.nii -d ${base}/flag/FC_qps5_FD_SSS_n16.mat -t ${base}/flag/FC_qps5_FD_SSS_n16.con -transposedata -logp -o ${base}/DTI_palm_sub_reg_FD_SSS_qps5 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub_reg_FD_SSS_qps5.txt
${PALM}/palm -i ${base}/qps50/FA_diff_all_sub.nii -i ${base}/qps50/MD_diff_all_sub.nii -d ${base}/flag/FC_qps50_FD_SSS_n16.mat -t ${base}/flag/FC_qps50_FD_SSS_n16.con -transposedata -logp -o ${base}/DTI_palm_sub_reg_FD_SSS_qps50 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_palm_sub_reg_FD_SSS_qps50.txt

${PALM}/palm -i ${base}/qps5/FA_mov_diff_all_sub.nii -i ${base}/qps5/MD_mov_diff_all_sub.nii -d ${base}/flag/FC_qps5_n16.mat -t ${base}/flag/FC_qps5_n16.con -transposedata -logp -o ${base}/DTI_mov_palm_sub_reg_qps5 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_mov_palm_sub_reg_qps5.txt
${PALM}/palm -i ${base}/qps50/FA_mov_diff_all_sub.nii -i ${base}/qps50/MD_mov_diff_all_sub.nii -d ${base}/flag/FC_qps50_n16.mat -t ${base}/flag/FC_qps50_n16.con -transposedata -logp -o ${base}/DTI_mov_palm_sub_reg_qps50 -T -n ${niter} -corrcon -corrmod -accel tail -nouncorrected >> ${base}/DTI_mov_palm_sub_reg_qps50.txt

##1-2. For Surface area
echo "For surface areas..."
#1-2-1. for DTI (microstructural changes)
for hemi in L R; do
	echo ${hemi}
	${PALM}/palm -i ${base}/qps5/FA_diff_all_${hemi}.func.gii -i ${base}/qps5/MD_diff_all_${hemi}.func.gii -i ${base}/qps50/FA_diff_all_${hemi}.func.gii -i ${base}/qps50/MD_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/FA_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -logp -o ${base}/DTI_palm_${hemi} -T -tfce2D -ise -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_${hemi}.txt
done
#1-2-2. for DTI (removing the effect of movement)
for hemi in L R; do
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/FA_mov_diff_all_${hemi}.func.gii -i ${base}/qps5/MD_mov_diff_all_${hemi}.func.gii -i ${base}/qps50/FA_mov_diff_all_${hemi}.func.gii -i ${base}/qps50/MD_mov_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/FA_mov_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/MD_mov_diff_all_${hemi}.func.gii \
-d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -logp -o ${base}/DTI_mov_palm_${hemi} -T -tfce2D -ise -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_mov_palm_${hemi}.txt
done

#1-2-3. for FC (functional changes)
for hemi in L R; do 
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/lhM1_rho_diff_all_${hemi}.func.gii -i ${base}/qps50/lhM1_rho_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/lhM1_rho_diff_all_${hemi}.func.gii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -logp -o ${base}/FC_palm_${hemi} -T -tfce2D -ise -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/FC_palm_${hemi}.txt 
done
#1-2-4. for FC (sensitivity analysis)
for hemi in L R; do
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/lhM1_rho_FD_diff_all_${hemi}.func.gii -i ${base}/qps50/lhM1_rho_FD_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/lhM1_rho_FD_diff_all_${hemi}.func.gii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -logp -o ${base}/FC_FD_palm_${hemi} -T -tfce2D -ise -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/FC_FD_palm_${hemi}.txt
done
#
for hemi in L R; do
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/lhM1_rho_FD_SSS_diff_all_${hemi}.func.gii -i ${base}/qps50/lhM1_rho_FD_SSS_diff_all_${hemi}.func.gii -i ${base}/qps5_qps50/lhM1_rho_FD_SSS_diff_all_${hemi}.func.gii -d ${base}/flag/${cont}.mat -t ${base}/flag/${cont}.con -logp -o ${base}/FC_FD_SSS_palm_${hemi} -T -tfce2D -ise -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/FC_FD_SSS_palm_${hemi}.txt
done

#1-2-5. regression analysis
for hemi in L R; do
        echo ${hemi}
	${PALM}/palm -i ${base}/qps5/FA_diff_all_${hemi}.func.gii -i ${base}/qps5/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps5_n16.mat -t ${base}/flag/FC_qps5_n16.con -logp -o ${base}/DTI_palm_reg_${hemi}_qps5 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_reg_${hemi}_qps5.txt
	${PALM}/palm -i ${base}/qps50/FA_diff_all_${hemi}.func.gii -i ${base}/qps50/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps50_n16.mat -t ${base}/flag/FC_qps50_n16.con -logp -o ${base}/DTI_palm_reg_${hemi}_qps50 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_reg_${hemi}_qps50.txt
done

for hemi in L R; do
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/FA_diff_all_${hemi}.func.gii -i ${base}/qps5/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps5_FD_n16.mat -t ${base}/flag/FC_qps5_FD_n16.con -logp -o ${base}/DTI_palm_reg_FD_${hemi}_qps5 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_reg_FD_${hemi}_qps5.txt
        ${PALM}/palm -i ${base}/qps50/FA_diff_all_${hemi}.func.gii -i ${base}/qps50/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps50_FD_n16.mat -t ${base}/flag/FC_qps50_FD_n16.con -logp -o ${base}/DTI_palm_reg_FD_${hemi}_qps50 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_reg_FD_${hemi}_qps50.txt
done

for hemi in L R; do
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/FA_diff_all_${hemi}.func.gii -i ${base}/qps5/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps5_FD_SSS_n16.mat -t ${base}/flag/FC_qps5_FD_SSS_n16.con -logp -o ${base}/DTI_palm_reg_FD_SSS_${hemi}_qps5 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_reg_FD_SSS_${hemi}_qps5.txt
        ${PALM}/palm -i ${base}/qps50/FA_diff_all_${hemi}.func.gii -i ${base}/qps50/MD_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps50_FD_SSS_n16.mat -t ${base}/flag/FC_qps50_FD_SSS_n16.con -logp -o ${base}/DTI_palm_reg_FD_SSS_${hemi}_qps50 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_palm_reg_FD_SSS_${hemi}_qps50.txt
done

for hemi in L R; do
        echo ${hemi}
        ${PALM}/palm -i ${base}/qps5/FA_mov_diff_all_${hemi}.func.gii -i ${base}/qps5/MD_mov_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps5_n16.mat -t ${base}/flag/FC_qps5_n16.con -logp -o ${base}/DTI_mov_palm_reg_${hemi}_qps5 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_mov_palm_reg_${hemi}_qps5.txt
        ${PALM}/palm -i ${base}/qps50/FA_mov_diff_all_${hemi}.func.gii -i ${base}/qps50/MD_mov_diff_all_${hemi}.func.gii \
-d ${base}/flag/FC_qps50_n16.mat -t ${base}/flag/FC_qps50_n16.con -logp -o ${base}/DTI_mov_palm_reg_${hemi}_qps50 -T -tfce2D -n ${niter} -accel tail -nouncorrected \
-s ../Avg/Avg.${hemi}.midthickness_MSMAll.32k_fs_LR.surf.gii ../Avg/Avg.${hemi}.midthickness_MSMAll_va.32k_fs_LR.shape.gii -corrcon -corrmod >> ${base}/DTI_mov_palm_reg_${hemi}_qps50.txt
done
