import sys, os
import numpy as np
from fsl.data.image import Image
import argparse



def main():
    p = argparse.ArgumentParser("selectdwivols")
    p.add_argument('--data',required=True,type=str,dest='data',
                   metavar='<IMAGE>',help='input DWI data')
    p.add_argument('--bvals',required=True,type=str,dest='bvals',
                   metavar='<FILE>',help='bvals ASCII text file')
    p.add_argument('--bvecs',required=False,type=str,dest='bvecs',
                   metavar='<FILE>',help='bvecs ASCII text file')
    p.add_argument('--tol',required=False,type=float,default=100,
                   help='tolerance (default=100 ms/um^2)')
    p.add_argument('--shell',required=False,type=float,default=0,
                   help='bval to extract (default = 0)')
    p.add_argument('--out',required=True,type=str,dest='output',
                   metavar='<IMAGE>',help='output image file')
    p.add_argument('--keep_b0s',action='store_true',help='keep the b0s')

    args = p.parse_args()

    data  = Image(args.data)
    bvals = np.loadtxt(args.bvals)
    
    inds = []
    for i,b in enumerate(bvals):
        if np.abs(b-args.shell) < args.tol:
            inds.append(i)
        if args.keep_b0s:
            if np.abs(b) < args.tol:
                inds.append(i)

    outdata = [ data[:,:,:,i] for i in inds ]
    outdata = np.transpose(outdata,[1,2,3,0])
    outdata = Image(outdata,header=data.header)
    outdata.save(args.output)
    

    # Save bvals (and bvecs if provided)
    b = np.array([bvals[i] for i in inds]).T
    np.savetxt(args.output+'.bval',b)
    if args.bvecs:
        bvecs = np.loadtxt(args.bvecs)
        v = np.array([bvecs[:,i] for i in inds]).T
        np.savetxt(args.output+'.bvec',v)
        
     

if __name__ == '__main__':
    main()
