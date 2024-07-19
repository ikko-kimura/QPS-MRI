# calculate metrics other than dti

# Ikko Kimura, Osaka University, 2022/01/03

## ref for fw DTI
# Henriques, R.N., Rokem, A., Garyfallidis, E., St-Jean, S., Peterson E.T., Correia, M.M., 2017. 
# [Re] Optimization of a free water elimination two-compartment model for diffusion tensor imaging. ReScience volume 3, issue 1, article number 2

## ref for DKI
# WMTI seems only useful for well aligned fibres...
# Fieremans E, Jensen JH, Helpern JA (2011). White matter characterization with diffusion kurtosis imaging. NeuroImage 58: 177-188
# Fieremans, E., Benitez, A., Jensen, J.H., Falangola, M.F., Tabesh, A., Deardorff, R.L., Spampinato, M.V., Babb, J.S., Novikov, D.S., Ferris, S.H., Helpern, J.A., 2013. 
# Novel white matter tract integrity metrics sensitive to Alzheimer disease progression. AJNR Am. J. Neuroradiol. 34(11), 2105-2112. doi: 10.3174/ajnr.A3553

import sys, os
import nibabel as nib
import numpy as np
import dipy.reconst.fwdti as fwdti
import dipy.reconst.dki_micro as dki_micro
from dipy.core.gradients import gradient_table
from dipy.data import get_fnames
from dipy.io.gradients import read_bvals_bvecs
from dipy.io.image import load_nifti
import argparse

def main():
    p = argparse.ArgumentParser("calculate_metrics")
    p.add_argument('--data',required=True,type=str,dest='data',
                   metavar='<IMAGE>',help='input DWI data')
    p.add_argument('--bvals',required=True,type=str,dest='bvals',
                   metavar='<FILE>',help='bvals ASCII text file')
    p.add_argument('--bvecs',required=False,type=str,dest='bvecs',
                   metavar='<FILE>',help='bvecs ASCII text file')
    p.add_argument('--mask',required=False,type=str,dest='mask',
                   metavar='<IMAGE>',help='mask data')
    p.add_argument('--out',required=True,type=str,dest='output',
                   metavar='<FILE>',help='output image file')

    args = p.parse_args()
    
    # input data
    data, affine = load_nifti(args.data)
    bvals, bvecs = read_bvals_bvecs(args.bvals, args.bvecs)
    gtab = gradient_table(bvals, bvecs)
    mask, affine = load_nifti(args.mask)
    
    print("reconstructing free water DTI model...")
    fwdtimodel = fwdti.FreeWaterTensorModel(gtab)
    fwdtifit = fwdtimodel.fit(data, mask=mask)
    dti_fa_nii=nib.Nifti1Image(fwdtifit.fa,affine=affine)
    dti_md_nii=nib.Nifti1Image(fwdtifit.md,affine=affine)
    dti_rd_nii=nib.Nifti1Image(fwdtifit.rd,affine=affine)
    dti_ad_nii=nib.Nifti1Image(fwdtifit.ad,affine=affine)
    dti_f_nii=nib.Nifti1Image(fwdtifit.f,affine=affine)
    nib.save(dti_fa_nii,args.output+'_fw_FA.nii.gz')
    nib.save(dti_md_nii,args.output+'_fw_MD.nii.gz')
    nib.save(dti_rd_nii,args.output+'_fw_RD.nii.gz')
    nib.save(dti_ad_nii,args.output+'_fw_AD.nii.gz')
    nib.save(dti_f_nii,args.output+'_fw_F.nii.gz')
    
    print("reconstructing WMTI model...")
    dki_micro_model = dki_micro.KurtosisMicrostructureModel(gtab)
    dki_micro_fit = dki_micro_model.fit(data, mask=mask)
    dki_awf_nii=nib.Nifti1Image(dki_micro_fit.awf,affine=affine)
    dki_tort_nii=nib.Nifti1Image(dki_micro_fit.tortuosity,affine=affine)
    nib.save(dki_awf_nii,args.output+'_awf.nii.gz')
    nib.save(dki_tort_nii,args.output+'_tort.nii.gz')
       
if __name__ == '__main__':
    main()
