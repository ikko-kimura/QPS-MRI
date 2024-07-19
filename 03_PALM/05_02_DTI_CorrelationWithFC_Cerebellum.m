clear

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 0. obtain roi
%%%%%%%%%%%%%%%%%%%%%%%%%
cifti = cifti_read('DTI_palm_tfce_tstat_mcfwep_m2_c2_cluster.dscalar.nii');
roi2=cifti.cdata;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1. inidividual analysis
%%%%%%%%%%%%%%%%%%%%%%%%%
%subj=["IK101SS","IK104MY","IK106TI","IK108KT","IK110MN","IK111SS","IK112EK","IK113MM","IK114TS","IK115KT","IK116HJ","IK121YI","IK122IM"];
%
cifti = cifti_read('Task_n16/MOTOR_LEFT_M1_ROI.dscalar.nii');
roi1=cifti.cdata;
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1. inidividual analysis
%%%%%%%%%%%%%%%%%%%%%%%%%
subj=["IK101SS","IK104MY","IK106TI","IK108KT","IK110MN","IK111SS","IK112EK","IK113MM","IK114TS","IK115KT","IK116HJ","IK117SN","IK121YI","IK122IM","IK123SM","IK124SM"];
cond=["qps5"];

for iiii=1:length(subj)
    iiii
    fname=["qps5_REST1_AP","qps5_REST2_AP"];
    for ii=1:length(fname)
        %ts = cifti_read(strcat( 'data/',subj(iiii),'/MNINonLinear/Results/',fname(ii),'/',fname(ii),'_Atlas_MSMAll_hp2000_clean_bp_gsr.dtseries.nii'));
        ts = cifti_read(strcat( 'data/',subj(iiii),'/MNINonLinear/Results/',fname(ii),'/',fname(ii),'_Atlas_MSMAll_hp2000_clean_gsr.dtseries.nii'));
        tt = ts.cdata';
    rho(iiii,ii)=atanh(corr(mean(tt(:,roi1==1),2),mean(tt(:,roi2==1),2))); 
    end
end

%%%%%%%%%%%%%%


ts = cifti_read(strcat('DTI_n16/qps5/MD_diff_all.dscalar.nii'));
DTI=mean(ts.cdata(roi2==1,:),1);

 [rho1,pval1]=corr(DTI',rho(:,2)-rho(:,1)) % rho = -0.23 pval= 0.40