## QPS-MRI
Ikko Kimura, 19th July 2024, RIKEN-BDR (Osaka University)
ikimura-osk＠umin.ac.jp

These are the codes used in the QPS-MRI project conducted at CiNet, Advanced ICT Research Institute, NICT. These results were published in [biorxiv](https://doi.org/10.1101/2023.04.20.537631) as a preprint. I hope the codes are self-explanatory. If you have any questions, please contact me via email.

#### Preprocessing

  01_PREPROCESS: Preprocessing steps for task fMRI, rsfMRI and dMRI data (including fitting DTI model and [surface mapping](https://github.com/RIKEN-BCIL/NoddiSurfaceMapping))

#### Imaging analysis

  02_01_TBSS_Tractography: Run [Tract-based Spatial Statistics](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/TBSS) and Tractography for dMRI data

  02_02_Calculate_FC: Define the seed and ROI regions; and run seed-based correlation and ROI-to-ROI analysis for rsfMRI data.

#### Statistics

  03_PALM: Run GLM analysis with [Permutation Analysis of Linear Models](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM) and calculate Bayes Factor.
