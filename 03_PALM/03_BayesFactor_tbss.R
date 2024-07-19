# calculate Bayes Factor for TBSS data
# Ikko Kimura, RIKEN-BDR, May-2024

library(RNifti)
library(BayesFactor)

bf_tbss = function(nii_fname,mask,ofname,r=sqrt(2)/2) {
  print(paste("working on ", nii_fname," ...",sep="")) 
  data <- readNifti(nii_fname)
  nii_new=mask*0
  ddim=dim(mask)
  for (i in 1:ddim[1]) {
    for (j in 1:ddim[2]) {
      for (k in 1:ddim[3]) {
        if (mask[i,j,k]==1) {
          bf=ttestBF(x=data[i,j,k,],rscale=r)
          nii_new[i,j,k]=bf@bayesFactor[["bf"]]/log(3, base=exp(1))
        }
      }
    }          
  }
  writeNifti(nii_new, ofname)
}

mask <- readNifti(paste("DTI_tbss_n16/FA/stats/mean_FA_skeleton_mask.nii", sep=""))

#
mode_list=c("FA","MD")
comp_list=c("qps5","qps50","qps5_qps50")
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_tbss(paste("DTI_tbss_n16/FA/stats/all_",mode,"_",comp,"_diff_skeletonised.nii", sep=""),mask,paste("DTI_tbss_n16/",mode,"_",comp,"_diff_skeletonised_bf.nii", sep=""))
  }          
}
# with narrow prior
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_tbss(paste("DTI_tbss_n16/FA/stats/all_",mode,"_",comp,"_diff_skeletonised.nii", sep=""),mask,paste("DTI_tbss_n16/",mode,"_",comp,"_diff_skeletonised_bf_scale05.nii", sep=""),0.5)
  }          
}
# with wide prior
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_tbss(paste("DTI_tbss_n16/FA/stats/all_",mode,"_",comp,"_diff_skeletonised.nii", sep=""),mask,paste("DTI_tbss_n16/",mode,"_",comp,"_diff_skeletonised_bf_scale10.nii", sep=""),1.0)
  }          
}
# movement removed
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_tbss(paste("DTI_tbss_n16/FA/stats/all_",mode,"_",comp,"_diff_mov_skeletonised.nii", sep=""),mask,paste("DTI_tbss_n16/",mode,"_",comp,"_diff_mov_skeletonised_bf.nii", sep=""))
  }          
}

