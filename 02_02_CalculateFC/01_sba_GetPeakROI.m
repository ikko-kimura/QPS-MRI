clear
%odir = 'REST_Loose'; %'REST_Loose';
%mkdir(odir)
%mkdir(strcat(odir,'/subj'))

% get the id manually
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 0. obtain roi
%%%%%%%%%%%%%%%%%%%%%%%%%
cifti = cifti_read('Task_n16/MOTOR_RIGHT_LEFT_palm_merged_dpv_tstat_c1.dscalar.nii');
roi=cifti.cdata;

cifti.cdata = zeros(length(cifti.cdata),1);
cifti.cdata(6294)=1;
cifti_write(cifti, 'Task_n16/MOTOR_LEFT_M1_peak.dscalar.nii');
cifti.cdata = zeros(length(cifti.cdata),1);
cifti.cdata(33669)=1;
cifti_write(cifti, 'Task_n16/MOTOR_RIGHT_M1_peak.dscalar.nii');


