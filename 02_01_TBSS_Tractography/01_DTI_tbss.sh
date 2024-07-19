#! /bin/bash

# run palm for DTI data
# Ikko Kimura, 2022/11/01, Osaka University

base=DTI_tbss_n16
cont=Mean_n16
niter=10000

mkdir ${base}
mkdir ${base}/FA
mkdir ${base}/MD
mkdir ${base}/RD

for subj in `cat subj_list/subj_list.txt`; do
echo ${subj}
for cond in qps5_Diffusion1 qps5_Diffusion2 qps50_Diffusion1 qps50_Diffusion2; do
#for cond in qps5 qps50; do
#for time in 1 2; do
for fname in FA MD RD; do
fslmaths data/${subj}/T1w/${cond}/data_${fname}.nii.gz ${base}/${fname}/FA_${subj}_${cond}
done
done
done

###2. TBSS STEPS
echo "tbss steps..."
cd ${base}/FA
tbss_1_preproc *.nii.gz
tbss_2_reg -T
tbss_3_postreg -S
tbss_4_prestats 0.2 #stay in default



