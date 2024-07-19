# calculate Bayes Factor for cifti data
# Ikko Kimura, RIKEN-BDR, May-2024

library(ciftiTools)
library(BayesFactor)
ciftiTools.setOption('wb_path', 'C:/Program Files/workbench/bin_windows64')

bf_cifti = function(cifti_fname,ofname,r=sqrt(2)/2) {
  print(paste("working on ", cifti_fname," ...",sep=""))  
  xii <- read_cifti(
    cifti_fname, brainstructures="all", 
  )
  
  cortexL <- xii$data$cortex_left
  cortexR <- xii$data$cortex_right
  subcort <- xii$data$subcort
  
  print("for left cortex...")
  cortexL_new=data.frame(ncol=1,nrow=nrow(cortexL))
  for (i in 1:nrow(cortexL)) {
    bf=ttestBF(x=cortexL[i,],rscale=r)
    cortexL_new[i,]=bf@bayesFactor[["bf"]]/log(3, base=exp(1))
  }
  print("for right cortex...")
  cortexR_new=data.frame(ncol=1,nrow=nrow(cortexR))
  for (i in 1:nrow(cortexR)) {
    bf=ttestBF(x=cortexR[i,],rscale=r)
    cortexR_new[i,]=bf@bayesFactor[["bf"]]/log(3, base=exp(1))
  }
  print("for subcortical structures...")
  subcort_new=data.frame(ncol=1,nrow=nrow(subcort))
  for (i in 1:nrow(subcort)) {
    bf=ttestBF(x=subcort[i,],rscale=r)
    subcort_new[i,]=bf@bayesFactor[["bf"]]/log(3, base=exp(1))
  }
  
  # Create a `"xifti"` from data 
  xii2 <- as.xifti(
    cortexL=as.matrix(cortexL_new$ncol), cortexL_mwall=xii$meta$cortex$medial_wall_mask$left,
    cortexR=as.matrix(cortexR_new$ncol), cortexR_mwall=xii$meta$cortex$medial_wall_mask$right,
    subcortVol = as.matrix(subcort_new$ncol), subcortLabs=xii$meta$subcort$labels,
    subcortMask=xii$meta$subcort$mask,
    HCP_32k_auto_mwall = FALSE, validate=FALSE,
  )
  xii2$meta$subcort$trans_mat=xii$meta$subcort$trans_mat
  xii2$meta$subcort$trans_units=xii$meta$subcort$trans_units
  
  # Write a CIFTI file 
  write_cifti(xii2, ofname)
}

comp_list=c("qps5","qps50","qps5_qps50")

##1. for functional changes
mode="lhM1_rho"
for (iii in 1:3) {
    comp=comp_list[iii]
    bf_cifti(paste("REST_n16/",comp,"/",mode,"_diff_all.dscalar.nii", sep=""),paste("REST_n16/",mode,"_diff_",comp,"_bf.dscalar.nii", sep=""))
}
# with narrow prior
for (iii in 1:3) {
  comp=comp_list[iii]
  bf_cifti(paste("REST_n16/",comp,"/",mode,"_diff_all.dscalar.nii", sep=""),paste("REST_n16/",mode,"_diff_",comp,"_bf_scale05.dscalar.nii", sep=""),0.5)
}
# with wide prior
for (iii in 1:3) {
  comp=comp_list[iii]
  bf_cifti(paste("REST_n16/",comp,"/",mode,"_diff_all.dscalar.nii", sep=""),paste("REST_n16/",mode,"_diff_",comp,"_bf_scale10.dscalar.nii", sep=""),1.0)
}
# mean FD removed
for (iii in 1:3) {
  comp=comp_list[iii]
  bf_cifti(paste("REST_n16/",mode,"_",comp,"_diff_all_FD.dscalar.nii", sep=""),paste("REST_n16/",mode,"_diff_FD_",comp,"_bf.dscalar.nii", sep=""))
}
# mean FD+SSS removed
for (iii in 1:3) {
  comp=comp_list[iii]
  bf_cifti(paste("REST_n16/",mode,"_",comp,"_diff_all_FD_SSS.dscalar.nii", sep=""),paste("REST_n16/",mode,"_diff_FD_SSS_",comp,"_bf.dscalar.nii", sep=""))
}

##2. for microstructural changes
mode_list=c("FA","MD")
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_cifti(paste("DTI_n16/",comp,"/",mode,"_diff_all.dscalar.nii", sep=""),paste("DTI_n16/",mode,"_diff_all_bf_",comp,".dscalar.nii", sep=""))
  }          
}
# with narrow prior
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_cifti(paste("DTI_n16/",comp,"/",mode,"_diff_all.dscalar.nii", sep=""),paste("DTI_n16/",mode,"_diff_all_bf_",comp,"_scale05.dscalar.nii", sep=""),0.5)
  }          
}
# with wide prior
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_cifti(paste("DTI_n16/",comp,"/",mode,"_diff_all.dscalar.nii", sep=""),paste("DTI_n16/",mode,"_diff_all_bf_",comp,"_scale10.dscalar.nii", sep=""),1.0)
  }          
}
# movement removed
for (iii in 1:3) {
  for (ii in 1:2) {
    comp=comp_list[iii]
    mode=mode_list[ii]
    bf_cifti(paste("DTI_n16/",mode,"_",comp,"_diff_all_mov.dscalar.nii", sep=""),paste("DTI_n16/",mode,"_",comp,"_diff_mov_bf.dscalar.nii", sep=""))
  }          
}

