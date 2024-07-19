#! /bin/bash

# run PALM for tbss data
niter=2000
PALM=/mnt/temp_data1/kimura_i/bin/palm-alpha119

for fname in FA MD; do
	fslmaths all_${fname}_qps5_diff_skeletonised.nii -sub all_${fname}_qps50_diff_skeletonised.nii all_${fname}_qps5_qps50_diff_skeletonised.nii
	fslmaths all_${fname}_qps5_diff_mov_skeletonised.nii -sub all_${fname}_qps50_diff_mov_skeletonised.nii all_${fname}_qps5_qps50_diff_mov_skeletonised.nii
done

gunzip -f *.nii.gz
echo "check DTI_palm.txt"
${PALM}/palm -i all_FA_qps5_diff_skeletonised.nii -i all_MD_qps5_diff_skeletonised.nii -i all_FA_qps50_diff_skeletonised.nii -i all_MD_qps50_diff_skeletonised.nii -i all_FA_qps5_qps50_diff_skeletonised.nii -i all_MD_qps5_qps50_diff_skeletonised.nii  -m mean_FA_skeleton_mask.nii -o DTI_palm -d ../flag/Mean_n16.mat -t ../flag/Mean_n16.con -T -tfce2D -ise -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm.txt
echo "check DTI_mov_palm.txt"
${PALM}/palm -i all_FA_qps5_diff_mov_skeletonised.nii -i all_MD_qps5_diff_mov_skeletonised.nii -i all_FA_qps50_diff_mov_skeletonised.nii -i all_MD_qps50_diff_mov_skeletonised.nii -i all_FA_qps5_qps50_diff_mov_skeletonised.nii -i all_MD_qps5_qps50_diff_mov_skeletonised.nii  -m mean_FA_skeleton_mask.nii -o DTI_mov_palm -d ../flag/Mean_n16.mat -t ../flag/Mean_n16.con -T -tfce2D -ise -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_mov_palm.txt
echo "check DTI_palm_reg_qps5.txt"
${PALM}/palm -i all_FA_qps5_diff_skeletonised.nii -i all_MD_qps5_diff_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_palm_reg_qps5 -d ../flag/FC_qps5_n16.mat -t ../flag/FC_qps5_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm_reg_qps5.txt
echo "check DTI_palm_reg_qps50.txt"
${PALM}/palm -i all_FA_qps50_diff_skeletonised.nii -i all_MD_qps50_diff_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_palm_reg_qps50 -d ../flag/FC_qps50_n16.mat -t ../flag/FC_qps50_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm_reg_qps50.txt
echo "check DTI_palm_reg_FD_qps5.txt"
${PALM}/palm -i all_FA_qps5_diff_skeletonised.nii -i all_MD_qps5_diff_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_palm_reg_FD_qps5 -d ../flag/FC_qps5_FD_n16.mat -t ../flag/FC_qps5_FD_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm_reg_FD_qps5.txt
echo "check DTI_palm_reg_FD_qps50.txt"
${PALM}/palm -i all_FA_qps50_diff_skeletonised.nii -i all_MD_qps50_diff_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_palm_reg_FD_qps50 -d ../flag/FC_qps50_FD_n16.mat -t ../flag/FC_qps50_FD_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm_reg_FD_qps50.txt
echo "check DTI_palm_reg_FD_SSS_qps5.txt"
${PALM}/palm -i all_FA_qps5_diff_skeletonised.nii -i all_MD_qps5_diff_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_palm_reg_FD_SSS_qps5 -d ../flag/FC_qps5_FD_SSS_n16.mat -t ../flag/FC_qps5_FD_SSS_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm_reg_FD_SSS_qps5.txt
echo "check DTI_palm_reg_FD_SSS_qps50.txt"
${PALM}/palm -i all_FA_qps50_diff_skeletonised.nii -i all_MD_qps50_diff_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_palm_reg_FD_SSS_qps50 -d ../flag/FC_qps50_FD_SSS_n16.mat -t ../flag/FC_qps50_FD_SSS_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_palm_reg_FD_SSS_qps50.txt
echo "check DTI_mov_palm_reg_qps5.txt"
${PALM}/palm -i all_FA_qps5_diff_mov_skeletonised.nii -i all_MD_qps5_diff_mov_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_mov_palm_reg_qps5 -d ../flag/FC_qps5_n16.mat -t ../flag/FC_qps5_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_mov_palm_reg_qps5.txt
echo "check DTI_mov_palm_reg_qps50.txt"
${PALM}/palm -i all_FA_qps50_diff_mov_skeletonised.nii -i all_MD_qps50_diff_mov_skeletonised.nii -m mean_FA_skeleton_mask.nii -o DTI_mov_palm_reg_qps50 -d ../flag/FC_qps50_n16.mat -t ../flag/FC_qps50_n16.con -T -tfce2D -n ${niter} -accel tail -logp -corrcon -corrmod -nouncorrected >> DTI_mov_palm_reg_qps50.txt
