## QPS-MRI
Ikko Kimura, 19th July 2024, RIKEN-BDR (Osaka University)
ikimura-osk＠umin.ac.jp

These are the codes used in the QPS-MRI project conducted at CiNet, Advanced ICT Research Institute, NICT. These results were published in [biorxiv](https://doi.org/10.1101/2023.04.20.537631) as a preprint. I hope the codes are self-explanatory; If you have any questions, please contact me via email.

### PREPROCESSING

01. PREPROCESS

  Preprocessing steps for task fMRI, rsfMRI and dMRI data

### IMAGING ANALYSIS

02-01. TBSS Tractography

  Run [Tract-based Spatial Statistics](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/TBSS) and Tractography for dMRI data

02-02. Calculate FC

  Define the seed and ROI regions; and run seed-based correlation and ROI-to-ROI analysis for rsfMRI data.

### STATISTICS

03. PALM

Run GLM analysis with [Permutation Analysis of Linear Models](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM) and calculate Bayes Factor.
