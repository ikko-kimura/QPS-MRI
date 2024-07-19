#! /bin/bash

# calculate all needed dMRI-derived metrics and project the result onto the surface
# Ikko Kimura, 2022/01/04, Osaka University 
# Ikko Kimura, 2022/05/31, replaced the line 16 from "MSMSulc" to "MSMAll"

# I just castomised the scripts from https://github.com/RIKEN-BCIL/NoddiSurfaceMapping
 
##TODO

StudyFolder=$1 #/home/ikimura/work/VIDA_2021IK04/qps5
Subject=$2 #KS000MS
dti_folder=$3 #Diffusion1
fname_list=$4 #/project/amano-g/kimura/QPS_MRI/fname_list.txt

# HCP PIPELINE
EnvironmentScript=/project/proj_shibusawa/kimura/2021IK01/scripts/HCP_Scripts/SetUpHCPPipeline.sh
dMRI_utils=/project/proj_shibusawa/kimura/Utils/dMRI/utils
RegName="MSMAll" #"MSMSulc" # added the varible
thr="3100,100,50" #b-value upper and lower threshold, b=0 upper threshold for HCP

# Folder Name
T1wFOLDER="T1w"
### The name is changed accordingly
DWIT1wFOLDER="${dti_folder}"
DWINativeFOLDER="${dti_folder}"
###
AtlasSpaceNativeFOLDER="Native"
AtlasSpaceFOLDER="MNINonLinear"
AtlasSpaceResultsDWIFOLDER="$DWIT1wFOLDER"
#
FreeSurferSubjectFolder=$StudyFolder/$Subject/$T1wFOLDER
FreeSurferSubjectID=$Subject
DWIT1wFolder=$StudyFolder/$Subject/$T1wFOLDER/$DWIT1wFOLDER
DWINativeFolder=$StudyFolder/$Subject/$DWINativeFOLDER
DtiRegDir=$DWINativeFolder/reg
DWIT1wFolder=$StudyFolder/$Subject/$T1wFOLDER/$DWIT1wFOLDER
T1wFolder=$StudyFolder/$Subject/$T1wFOLDER
AtlasSpaceFolder=$StudyFolder/$Subject/$AtlasSpaceFOLDER
AtlasSpaceNativeFolder=$AtlasSpaceFolder/$AtlasSpaceNativeFOLDER
AtlasSpaceResultsDWIFolder=$AtlasSpaceFolder/Results/$AtlasSpaceResultsDWIFOLDER
AtlasSpaceFolder=$StudyFolder/$Subject/$AtlasSpaceFOLDER
# Surface mapping
ribbonLlabel=3
ribbonRlabel=42
ROIFolder=$AtlasSpaceFolder/ROIs

source $EnvironmentScript
source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions

# parameter for Human
export SPECIES=Human
HighResMesh=164
LowResMeshes=32  # Separate with "@" if needed multiple meshes (e.g. 32@10) with the grayordinate mesh at the last
BrainOrdinatesResolutions=2
BrainOrdinatesDIR=${HCPPIPEDIR}/global/templates/standard_mesh_atlases

DiffRes="`fslval $DWIT1wFolder/data.nii.gz pixdim1 | awk '{printf "%0.2f",$1}'`"
NODDIMappingFWHM="`echo "$DiffRes * 2.5" | bc -l`"
NODDIMappingSigma=`echo "$NODDIMappingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
SmoothingFWHM="$DiffRes"
SmoothingSigma=`echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
LowResMeshes=(`echo $LowResMeshes | sed -e 's/@/ /g'`)
BrainOrdinatesResolutions=(`echo $BrainOrdinatesResolutions | sed -e 's/@/ /g'`)


if [ ! -e "$AtlasSpaceFolder" ] ; then
 echo "Error: Cannot find $AtlasSpaceFolder"; #exit 1;
fi

if [ ! -e "$AtlasSpaceFolder/ribbon.nii.gz" ] ; then
 echo "ERROR: cannot find ribbon.nii.gz in $AtlasSpaceFolder"; #exit 1;
fi

if [ "$RegName" = "MSMAll" ] ; then
	Reg="_MSMAll"
else
  Reg=""
fi

######################## THE END OF SETTING UP THE PARAMETERS

##0. little preparation
fslmaths $AtlasSpaceFolder/ribbon.nii.gz -thr $ribbonLlabel -uthr $ribbonLlabel -bin $AtlasSpaceFolder/ribbon_L.nii.gz
fslmaths $AtlasSpaceFolder/ribbon.nii.gz -thr $ribbonRlabel -uthr $ribbonRlabel -bin $AtlasSpaceFolder/ribbon_R.nii.gz
for BrainOrdinatesResolution in ${BrainOrdinatesResolutions[@]} ; do
 if [ ! -e $AtlasSpaceFolder/T1w_restore."$BrainOrdinatesResolution".nii.gz ] ; then
  if [ ! -e "$ROIFolder"/Atlas_ROIs."$BrainOrdinatesResolution".nii.gz ] ; then
   cp ${BrainOrdinatesDIR}/Atlas_ROIs."$BrainOrdinatesResolution".nii.gz "$ROIFolder"/Atlas_ROIs."$BrainOrdinatesResolution".nii.gz
  fi
  flirt -in $AtlasSpaceFolder/T1w_restore.nii.gz -applyisoxfm "$BrainOrdinatesResolution" -ref $AtlasSpaceFolder/ROIs/Atlas_ROIs."$BrainOrdinatesResolution".nii.gz -o $AtlasSpaceFolder/T1w_restore."$BrainOrdinatesResolution".nii.gz -interp sinc # resample
 fi
done

mkdir -p $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping

##1. SNR surface mapping
${CARET7DIR}/wb_command -volume-warpfield-resample $DWIT1wFolder/data_snr.nii.gz $AtlasSpaceFolder/xfms/acpc_dc2standard.nii.gz $AtlasSpaceFolder/T1w_restore.nii.gz CUBIC $AtlasSpaceResultsDWIFolder/data_snr.nii.gz -fnirt $T1wFolder/T1w_acpc_dc_restore.nii.gz
for Hemisphere in L R ; do
   ${CARET7DIR}/wb_command -volume-to-surface-mapping $AtlasSpaceResultsDWIFolder/data_snr.nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii  $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".data_snr.native.func.gii -myelin-style $AtlasSpaceFolder/ribbon_"$Hemisphere".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".thickness.native.shape.gii "$NODDIMappingSigma"
   ${CARET7DIR}/wb_command -metric-mask $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".data_snr.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".data_snr.native.func.gii
   ${CARET7DIR}/wb_command -metric-math 'x>10' $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".goodvertex.native.func.gii -var x  $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".data_snr.native.func.gii
done

##2. Volume-to-surface-mapping
for vol in `cat ${fname_list}`; do
 echo "processing for ${vol}..."
 if [ `imtest $DWIT1wFolder/${vol}.nii.gz` = 1 ] ; then
# for native space? but why from the volume in standard space?
  ${CARET7DIR}/wb_command -volume-warpfield-resample $DWIT1wFolder/${vol}.nii.gz $AtlasSpaceFolder/xfms/acpc_dc2standard.nii.gz $AtlasSpaceFolder/T1w_restore.nii.gz CUBIC $AtlasSpaceResultsDWIFolder/${vol}.nii.gz -fnirt $T1wFolder/T1w_acpc_dc_restore.nii.gz &>/dev/null
  
  for Hemisphere in L R ; do
   ${CARET7DIR}/wb_command -volume-to-surface-mapping $AtlasSpaceResultsDWIFolder/${vol}.nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii  $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii -myelin-style $AtlasSpaceFolder/ribbon_"$Hemisphere".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".thickness.native.shape.gii "$NODDIMappingSigma"
   ${CARET7DIR}/wb_command -metric-mask $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".goodvertex.native.func.gii $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii
   ${CARET7DIR}/wb_command -metric-dilate $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii 20 $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii -nearest
   ${CARET7DIR}/wb_command -metric-mask $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii
   ${CARET7DIR}/wb_command -set-map-name $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii 1 "$Subject"_"$Hemisphere"_"$vol"
   ${CARET7DIR}/wb_command -metric-palette $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii MODE_AUTO_SCALE_PERCENTAGE -pos-percent 4 96 -interpolate true -palette-name videen_style -disp-pos true -disp-neg false -disp-zero false
  done
 fi
done

for vol in data_snr `cat ${fname_list}`; do
  for Hemisphere in L R ; do
   #LowResMesh
   for LowResMesh in ${LowResMeshes[@]}; do
    DownsampleFolder=$AtlasSpaceFolder/fsaverage_LR${LowResMesh}k
  ${CARET7DIR}/wb_command -metric-resample $AtlasSpaceResultsDWIFolder/RibbonVolumeToSurfaceMapping/"$Subject"."$Hemisphere".${vol}.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".sphere.${RegName}.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".sphere."$LowResMesh"k_fs_LR.surf.gii ADAP_BARY_AREA $AtlasSpaceResultsDWIFolder/"$Subject"."$Hemisphere".${vol}${Reg}."$LowResMesh"k_fs_LR.func.gii -area-surfs "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii -current-roi "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii
  ${CARET7DIR}/wb_command -metric-mask $AtlasSpaceResultsDWIFolder/"$Subject"."$Hemisphere".${vol}${Reg}."$LowResMesh"k_fs_LR.func.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii $AtlasSpaceResultsDWIFolder/"$Subject"."$Hemisphere".${vol}${Reg}."$LowResMesh"k_fs_LR.func.gii
    ${CARET7DIR}/wb_command -metric-smoothing "$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii $AtlasSpaceResultsDWIFolder/"$Subject"."$Hemisphere".${vol}${Reg}."$LowResMesh"k_fs_LR.func.gii "$SmoothingSigma" $AtlasSpaceResultsDWIFolder/"$Subject"."$Hemisphere".${vol}${Reg}_s"$SmoothingFWHM"."$LowResMesh"k_fs_LR.func.gii -roi "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii
   done
  done

  # Do volume parcel resampling for subcortical gray matter
  for BrainOrdinatesResolution in ${BrainOrdinatesResolutions[@]} ; do
    ${CARET7DIR}/wb_command -volume-warpfield-resample $DWIT1wFolder/${vol}.nii.gz $AtlasSpaceFolder/xfms/acpc_dc2standard.nii.gz $AtlasSpaceFolder/T1w_restore."$BrainOrdinatesResolution".nii.gz CUBIC $AtlasSpaceResultsDWIFolder/${vol}."$BrainOrdinatesResolution".nii.gz -fnirt $T1wFolder/T1w_acpc_dc_restore.nii.gz &> /dev/null
    if [ ! -e "$ROIFolder"/ROIs."$BrainOrdinatesResolution".nii.gz ] ; then
      flirt -in $AtlasSpaceFolder/wmparc.nii.gz -applyisoxfm $BrainOrdinatesResolution -ref $AtlasSpaceFolder/wmparc.nii.gz -o "$ROIFolder"/ROIs.${BrainOrdinatesResolution}.nii.gz -interp nearestneighbour
      ${CARET7DIR}/wb_command -volume-label-import "$ROIFolder"/ROIs.${BrainOrdinatesResolution}.nii.gz $HCPPIPEDIR/global/config/FreeSurferSubcorticalLabelTableLut.txt "$ROIFolder"/ROIs.${BrainOrdinatesResolution}.nii.gz -discard-others -drop-unused-labels
    fi
    ${CARET7DIR}/wb_command -volume-parcel-resampling $AtlasSpaceResultsDWIFolder/${vol}."$BrainOrdinatesResolution".nii.gz "$ROIFolder"/ROIs."$BrainOrdinatesResolution".nii.gz "$ROIFolder"/Atlas_ROIs."$BrainOrdinatesResolution".nii.gz $SmoothingSigma $AtlasSpaceResultsDWIFolder/${vol}_AtlasSubcortical_s"$SmoothingFWHM".nii.gz -fix-zeros
  done

  # Merge surface and subcortical volume to create cifti
  i=0
  for LowResMesh in ${LowResMeshes[@]}; do
   BrainOrdinatesResolution="${BrainOrdinatesResolutions[$i]}"
   DownsampleFolder=$AtlasSpaceFolder/fsaverage_LR${LowResMesh}k
   ${CARET7DIR}/wb_command -cifti-create-dense-scalar $AtlasSpaceResultsDWIFolder/${vol}${Reg}."$LowResMesh"k_fs_LR.dscalar.nii -volume $AtlasSpaceResultsDWIFolder/${vol}_AtlasSubcortical_s"$SmoothingFWHM".nii.gz "$ROIFolder"/Atlas_ROIs."$BrainOrdinatesResolution".nii.gz -left-metric $AtlasSpaceResultsDWIFolder/"$Subject".L.${vol}${Reg}_s"$SmoothingFWHM"."$LowResMesh"k_fs_LR.func.gii -roi-left "$DownsampleFolder"/"$Subject".L.atlasroi."$LowResMesh"k_fs_LR.shape.gii -right-metric $AtlasSpaceResultsDWIFolder/"$Subject".R.${vol}${Reg}_s"$SmoothingFWHM"."$LowResMesh"k_fs_LR.func.gii -roi-right "$DownsampleFolder"/"$Subject".R.atlasroi."$LowResMesh"k_fs_LR.shape.gii
   ${CARET7DIR}/wb_command -set-map-names $AtlasSpaceResultsDWIFolder/${vol}${Reg}."$LowResMesh"k_fs_LR.dscalar.nii -map 1 "${Subject}_${vol}"
   ${CARET7DIR}/wb_command -cifti-palette $AtlasSpaceResultsDWIFolder/${vol}${Reg}."$LowResMesh"k_fs_LR.dscalar.nii MODE_AUTO_SCALE_PERCENTAGE $AtlasSpaceResultsDWIFolder/${vol}${Reg}."$LowResMesh"k.dscalar.nii -pos-percent 4 96 -interpolate true -palette-name videen_style -disp-pos true -disp-neg false -disp-zero false
   i=`expr $i + 1`
  done
done

# Remove files
for vol in data_snr `cat ${fname_list}`; do
 for Hemisphere in R L; do
  for LowResMesh in ${LowResMeshes[@]} ; do
   \rm -rf $AtlasSpaceResultsDWIFolder/"$Subject".${Hemisphere}.${vol}${Reg}."$LowResMesh"k_fs_LR.func.gii
   \rm -rf $AtlasSpaceResultsDWIFolder/"$Subject".${Hemisphere}.${vol}${Reg}_s"$SmoothingFWHM"."$LowResMesh"k_fs_LR.func.gii
  done
 done
 for BrainOrdinatesResolution in ${BrainOrdinatesResolutions[@]} ; do
  \rm -rf $AtlasSpaceResultsDWIFolder/${vol}."$BrainOrdinatesResolution".nii.gz
  \rm -rf $AtlasSpaceResultsDWIFolder/${vol}_AtlasSubcortical."$BrainOrdinatesResolution"_s"$SmoothingFWHM".nii.gz
 done
done
