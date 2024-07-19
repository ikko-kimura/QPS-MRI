clear
odir = 'REST_n16'; %'REST_Loose';
mkdir(odir)
mkdir(strcat(odir,'/subj'))

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 0. obtain roi
%%%%%%%%%%%%%%%%%%%%%%%%%
cifti = cifti_read('Task_n16/MOTOR_LEFT_M1_ROI.dscalar.nii');
roi=cifti.cdata;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1. inidividual analysis
%%%%%%%%%%%%%%%%%%%%%%%%%
subj=["IK101SS","IK104MY","IK106TI","IK108KT","IK110MN","IK111SS","IK112EK","IK113MM","IK114TS","IK115KT","IK116HJ","IK117SN","IK121YI","IK122IM","IK123SM","IK124SM"];
cond=["qps5","qps50"];

for iiii=1:length(subj)
    iiii
for iii=1:length(cond)
fname=[strcat(cond(iii),"_REST1_AP"),strcat(cond(iii),"_REST2_AP")];
for ii=1:length(fname)
ts = cifti_read(strcat( 'data/',subj(iiii),'/MNINonLinear/Results/',fname(ii),'/',fname(ii),'_Atlas_MSMAll_hp2000_clean.dtseries.nii'));

%tt = y_IdealFilter(ts.cdata', 1, [0.009 0.08]);
tt = ts.cdata';
tt = gsr(tt);

ts.cdata=tt';
cifti_write(ts, char(strcat( 'data/',subj(iiii),'/MNINonLinear/Results/',fname(ii),'/',fname(ii),'_Atlas_MSMAll_hp2000_clean_gsr.dtseries.nii')));

tt_roi =mean(tt(:,roi==1),2);

for i=1:size(tt,2)
   rho(i)=atanh(corr(tt(:,i),tt_roi)); 
end

cifti.cdata = rho';
cifti_write(cifti, char(strcat(odir,'/subj/lhM1_rho_',subj(iiii),'_',fname(ii),'.dscalar.nii')));
clear ts
end
end
end
