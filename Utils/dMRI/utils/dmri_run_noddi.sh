#! /bin/bash

# fit NODDI model
# Ikko Kimura, Osaka University, 2022/01/04

## TODO

base=$1 #/project/amano-g/kimura/QPS_MRI/qps5/KS000MS/T1w/Diffusion1
noddi_toolbox=/project/proj_shibusawa/kimura/Toolbox/noddi_matlab

# little preparation
mkdir ${base}/noddi
fslmaths ${base}/data ${base}/noddi/data
fslmaths ${base}/nodif_brain_mask ${base}/noddi/nodif_brain_mask
gunzip ${base}/noddi/data.nii.gz
gunzip ${base}/noddi/nodif_brain_mask.nii.gz

matlab -nosplash -nodesktop -r "addpath(genpath('"${noddi_toolbox}"')); dmri_NODDI('"${base}/noddi/data.nii"','"${base}/bvals"','"${base}/bvecs"','"${base}/noddi/nodif_brain_mask.nii"','"${base}/noddi"',40); exit"
# white matter
fslmaths ${base}/noddi/noddi_ficvf ${base}/noddi_ficvf
fslmaths ${base}/noddi/noddi_odi ${base}/noddi_odi
fslmaths ${base}/noddi/noddi_fiso ${base}/noddi_fiso
# grey matter
fslmaths ${base}/noddi/noddi_gm_ficvf ${base}/noddi_gm_ficvf
fslmaths ${base}/noddi/noddi_gm_odi ${base}/noddi_gm_odi
fslmaths ${base}/noddi/noddi_gm_fiso ${base}/noddi_gm_fiso

