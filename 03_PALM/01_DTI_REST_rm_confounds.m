% remove confounds for sensitivity analysis
% Ikko Kimura, Apr 2024, RIKEN-BDR

clear
nsubj=16;
d=csvread('2022IK01_BehavioralData_analyse_matlab.csv',1);

%%%1. for FC
% here we will remove sleepiness and mean FD
odir = 'REST_n16'; %'REST_Loose';
cond=["qps5","qps50"];
time=["REST1","REST2"];

FD=d(:,[25 26 51 52]);
SSS=d(:,[10 11 36 37]);
SSS=double(SSS>4);

cdata=[];
for i=1:length(cond)
    for j=1:length(time)
        cii = cifti_read(strcat(odir,'/lhM1_rho_',cond(i),'_',time(j),'_all.dscalar.nii'));
        cdata=[cdata,double(cii.cdata)];
    end
end

fd_vec=reshape(FD,[],1); fd_vec=fd_vec-mean(fd_vec);
sss_vec=reshape(SSS,[],1); sss_vec=sss_vec-mean(sss_vec);

cdata_mean=mean(cdata,2);
cdata_dm=cdata-cdata_mean;

for i=1:size(cdata,1)
    [~,~,res1(:,i)] = regress(cdata_dm(i,:)',[fd_vec ones(nsubj*4,1)]);    
    [~,~,res2(:,i)] = regress(cdata_dm(i,:)',[fd_vec sss_vec ones(nsubj*4,1)]);
end

res1=res1'+cdata_mean;
res2=res2'+cdata_mean;
% remove FD
diff_qps5=res1(:,17:32)-res1(:,1:16);
cii.cdata=diff_qps5;
cifti_write(cii,strcat(odir,'/lhM1_rho_qps5_diff_all_FD.dscalar.nii'))
diff_qps50=res1(:,49:64)-res1(:,33:48);
cii.cdata=diff_qps50;
cifti_write(cii,strcat(odir,'/lhM1_rho_qps50_diff_all_FD.dscalar.nii'))
diff_qps5_qps50=diff_qps5-diff_qps50;
cii.cdata=diff_qps5_qps50;
cifti_write(cii,strcat(odir,'/lhM1_rho_qps5_qps50_diff_all_FD.dscalar.nii'))
% remove FD and SSS
diff_qps5=res2(:,17:32)-res2(:,1:16);
cii.cdata=diff_qps5;
cifti_write(cii,strcat(odir,'/lhM1_rho_qps5_diff_all_FD_SSS.dscalar.nii'))
diff_qps50=res2(:,49:64)-res2(:,33:48);
cii.cdata=diff_qps50;
cifti_write(cii,strcat(odir,'/lhM1_rho_qps50_diff_all_FD_SSS.dscalar.nii'))
diff_qps5_qps50=diff_qps5-diff_qps50;
cii.cdata=diff_qps5_qps50;
cifti_write(cii,strcat(odir,'/lhM1_rho_qps5_qps50_diff_all_FD_SSS.dscalar.nii'))

%%%2. for DTI
% here we will remove absolute and relative motion
abs_mot=d(:,[27 29 53 55]);
rel_mot=d(:,[28 30 54 56]);

abs_vec=reshape(abs_mot,[],1); abs_vec=abs_vec-mean(abs_vec);
rel_vec=reshape(rel_mot,[],1); rel_vec=rel_vec-mean(rel_vec);

odir = 'DTI_n16'; %'REST_Loose';
cond=["qps5","qps50"];
time=["Diffusion1","Diffusion2"];

% FA
fname='FA';
cdata=[];
for i=1:length(cond)
    for j=1:length(time)
        cii = cifti_read(strcat(odir,'/',time(j),'/',fname,'_',cond(i),'_',time(j),'_all.dscalar.nii'));
        cdata=[cdata,double(cii.cdata)];
    end
end
cdata_mean=mean(cdata,2);
cdata_dm=cdata-cdata_mean;

for i=1:size(cdata,1)
    [~,~,res(:,i)] = regress(cdata_dm(i,:)',[abs_vec rel_vec ones(nsubj*4,1)]);    
end
res=res'+cdata_mean;
% write data
diff_qps5=res(:,17:32)-res(:,1:16);
cii.cdata=diff_qps5;
cifti_write(cii,strcat(odir,'/',fname,'_qps5_diff_all_mov.dscalar.nii'))
diff_qps50=res(:,49:64)-res(:,33:48);
cii.cdata=diff_qps50;
cifti_write(cii,strcat(odir,'/',fname,'_qps50_diff_all_mov.dscalar.nii'))
diff_qps5_qps50=diff_qps5-diff_qps50;
cii.cdata=diff_qps5_qps50;
cifti_write(cii,strcat(odir,'/',fname,'_qps5_qps50_diff_all_mov.dscalar.nii'))

% MD
fname='MD';
cdata=[];
for i=1:length(cond)
    for j=1:length(time)
        cii = cifti_read(strcat(odir,'/',time(j),'/',fname,'_',cond(i),'_',time(j),'_all.dscalar.nii'));
        cdata=[cdata,double(cii.cdata)];
    end
end
cdata_mean=mean(cdata,2);
cdata_dm=cdata-cdata_mean;
clear res
for i=1:size(cdata,1)
    [~,~,res(:,i)] = regress(cdata_dm(i,:)',[abs_vec rel_vec ones(nsubj*4,1)]);    
end
res=res'+cdata_mean;
% write data
diff_qps5=res(:,17:32)-res(:,1:16);
cii.cdata=diff_qps5;
cifti_write(cii,strcat(odir,'/',fname,'_qps5_diff_all_mov.dscalar.nii'))
diff_qps50=res(:,49:64)-res(:,33:48);
cii.cdata=diff_qps50;
cifti_write(cii,strcat(odir,'/',fname,'_qps50_diff_all_mov.dscalar.nii'))
diff_qps5_qps50=diff_qps5-diff_qps50;
cii.cdata=diff_qps5_qps50;
cifti_write(cii,strcat(odir,'/',fname,'_qps5_qps50_diff_all_mov.dscalar.nii'))