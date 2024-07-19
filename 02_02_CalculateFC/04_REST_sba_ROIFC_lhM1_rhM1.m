clear
odir = 'REST_n16'; 

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 0. obtain roi
%%%%%%%%%%%%%%%%%%%%%%%%%
%
cifti = cifti_read('Task_n16/MOTOR_LEFT_M1_ROI.dscalar.nii');
roi1=cifti.cdata;
cifti = cifti_read('Task_n16/MOTOR_RIGHT_M1_ROI.dscalar.nii');
roi2=cifti.cdata;
%
cifti = cifti_read('Task_n16/MOTOR_LEFT_M1_ROI_strict.dscalar.nii');
roi1_strict=cifti.cdata;
cifti = cifti_read('Task_n16/MOTOR_RIGHT_M1_ROI_strict.dscalar.nii');
roi2_strict=cifti.cdata;
%
cifti = cifti_read('Task_n16/MOTOR_LEFT_M1_ROI_loose.dscalar.nii');
roi1_loose=cifti.cdata;
cifti = cifti_read('Task_n16/MOTOR_RIGHT_M1_ROI_loose.dscalar.nii');
roi2_loose=cifti.cdata;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1. calculate FC
%%%%%%%%%%%%%%%%%%%%%%%%%
subj=["IK101SS","IK104MY","IK106TI","IK108KT","IK110MN","IK111SS","IK112EK","IK113MM","IK114TS","IK115KT","IK116HJ","IK117SN","IK121YI","IK122IM","IK123SM","IK124SM"];
cond=["qps5","qps50"];

for iiii=1:length(subj)
    iiii
    for iii=1:length(cond)
        fname=[strcat(cond(iii),"_REST1_AP"),strcat(cond(iii),"_REST2_AP")];
        for ii=1:length(fname)
            ts = cifti_read(strcat( 'data/',subj(iiii),'/MNINonLinear/Results/',fname(ii),'/',fname(ii),'_Atlas_MSMAll_hp2000_clean_gsr.dtseries.nii'));
            tt = ts.cdata';
            rho(iiii,ii,iii)=atanh(corr(mean(tt(:,roi1==1),2),mean(tt(:,roi2==1),2))); 
            rho_strict(iiii,ii,iii)=atanh(corr(mean(tt(:,roi1_strict==1),2),mean(tt(:,roi2_strict==1),2)));
            rho_loose(iiii,ii,iii)=atanh(corr(mean(tt(:,roi1_loose==1),2),mean(tt(:,roi2_loose==1),2)));
        end
    end
end
rho_orig=rho; % [subject]x[pre/post]xcond

qps5_diff=squeeze(rho(:,2,1)-rho(:,1,1));
qps50_diff=squeeze(rho(:,2,2)-rho(:,1,2));
qps5_diff_strict=squeeze(rho_strict(:,2,1)-rho_strict(:,1,1));
qps50_diff_strict=squeeze(rho_strict(:,2,2)-rho_strict(:,1,2));
qps5_diff_loose=squeeze(rho_loose(:,2,1)-rho_loose(:,1,1));
qps50_diff_loose=squeeze(rho_loose(:,2,2)-rho_loose(:,1,2));

figure()
for i=1:16
plot([1 2],[qps5_diff(i),qps50_diff(i)],'-','Color',[0.5 0.5 0.5])
hold on
clear i
end
plot([1 2],mean([qps5_diff,qps50_diff]),'-kx','MarkerSize',10,'LineWidth',1.5)
set(gca,'Xtick',1:2,'XtickLabel',{'QPS5','QPS50'},'FontSize',16,'TickDir','out')
box off
xlim([0.5 2.5])
ylabel('\Delta FC [bilateral M1]')

[h p]=ttest([qps5_diff,qps50_diff,qps5_diff-qps50_diff])

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 3. sensitivity analysis
%%%%%%%%%%%%%%%%%%%%%%%%%
% Change of the ROI size
%plot(squeeze(rho(:,2,1)-rho(:,1,1)),squeeze(rho(:,2,2)-rho(:,1,2)),'ko')
%qps5_diff_dm=qps5_diff-mean(qps5_diff);
%qps50_diff_dm=qps50_diff-mean(qps50_diff);

[r,p]=corr(qps5_diff,qps5_diff_loose)
[r,p]=corr(qps5_diff,qps5_diff_strict)
[r,p]=corr(qps50_diff,qps50_diff_loose)
[r,p]=corr(qps50_diff,qps50_diff_strict)

figure()
subplot(2,2,1)
plot(qps5_diff_strict,qps5_diff,'ko','MarkerSize',7); box off; set(gca,'TickDir','out','FontSize',12)
title('QPS5 (5mm vs. 2mm)'); ylabel('5mm radius'); xlabel('2mm radius')
subplot(2,2,2)
plot(qps5_diff_loose,qps5_diff,'ko','MarkerSize',7); box off; set(gca,'TickDir','out','FontSize',12)
title('QPS5 (5mm vs. 8mm)'); ylabel('5mm radius'); xlabel('8mm radius')
subplot(2,2,3)
plot(qps50_diff_strict,qps50_diff,'ko','MarkerSize',7); box off; set(gca,'TickDir','out','FontSize',12)
title('QPS50 (5mm vs. 2mm)'); ylabel('5mm radius'); xlabel('2mm radius')
subplot(2,2,4)
plot(qps50_diff_loose,qps50_diff,'ko','MarkerSize',7); box off; set(gca,'TickDir','out','FontSize',12)
title('QPS50 (5mm vs. 8mm)'); ylabel('5mm radius'); xlabel('8mm radius')

% With or Without the confounders
d=csvread('2022IK01_BehavioralData_analyse_matlab.csv',1);
FD=d(:,[25 26 51 52]);
SSS=d(:,[10 11 36 37]);
SSS=double(SSS>4);

RHO=[rho_orig(:,:,1) rho_orig(:,:,2)];
fd_vec=reshape(FD,[],1); fd_vec=fd_vec-mean(fd_vec);
sss_vec=reshape(SSS,[],1); sss_vec=sss_vec-mean(sss_vec);
rho_vec=reshape(RHO,[],1); rho_vec_mean=mean(rho_vec); rho_vec=rho_vec-mean(rho_vec);
[b1,~,res1] = regress(rho_vec,[fd_vec ones(64,1)]);
[b2,~,res2] = regress(rho_vec,[fd_vec sss_vec ones(64,1)]);
RHO_FD=reshape(res1+rho_vec_mean,16,4);
RHO_FD_SSS=reshape(res2+rho_vec_mean,16,4);
RHO_test=reshape(rho_vec,16,4);

qps5_diff_FD=RHO_FD(:,2)-RHO_FD(:,1);
qps50_diff_FD=RHO_FD(:,4)-RHO_FD(:,3);

qps5_diff_FD_SSS=RHO_FD_SSS(:,2)-RHO_FD_SSS(:,1);
qps50_diff_FD_SSS=RHO_FD_SSS(:,4)-RHO_FD_SSS(:,3);

%%% demean the data
qps5_diff_dm=[ones(16,1) qps5_diff-mean(qps5_diff)];
qps50_diff_dm=[ones(16,1) qps50_diff-mean(qps50_diff)];

qps5_diff_FD_dm=[ones(16,1) qps5_diff_FD-mean(qps5_diff_FD)];
qps50_diff_FD_dm=[ones(16,1) qps50_diff_FD-mean(qps50_diff_FD)];

qps5_diff_FD_SSS_dm=[ones(16,1) qps5_diff_FD_SSS-mean(qps5_diff_FD_SSS)];
qps50_diff_FD_SSS_dm=[ones(16,1) qps50_diff_FD_SSS-mean(qps50_diff_FD_SSS)];

figure()
subplot(1,3,1)
for i=1:16
plot([1 2],[qps5_diff(i),qps50_diff(i)],'-','Color',[0.5 0.5 0.5])
hold on
clear i
end
plot([1 2],mean([qps5_diff,qps50_diff]),'-kx','MarkerSize',10,'LineWidth',1.5)
set(gca,'Xtick',1:2,'XtickLabel',{'QPS5','QPS50'},'FontSize',16,'TickDir','out')
box off
xlim([0.5 2.5]); ylim([-0.8 0.6]); ylabel('\Delta FC [bilateral M1]')
subplot(1,3,2)
for i=1:16
plot([1 2],[RHO_FD(i,2)-RHO_FD(i,1),RHO_FD(i,4)-RHO_FD(i,3)],'-','Color',[0.5 0.5 0.5])
hold on
clear i
end
plot([1 2],mean([RHO_FD(:,2)-RHO_FD(:,1),RHO_FD(:,4)-RHO_FD(:,3)]),'-kx','MarkerSize',10,'LineWidth',1.5)
set(gca,'Xtick',1:2,'XtickLabel',{'QPS5','QPS50'},'FontSize',16,'TickDir','out')
box off
xlim([0.5 2.5]); ylim([-0.8 0.6]); ylabel('\Delta FC [bilateral M1] mean FD removed')
subplot(1,3,3)
for i=1:16
plot([1 2],[RHO_FD_SSS(i,2)-RHO_FD_SSS(i,1),RHO_FD_SSS(i,4)-RHO_FD_SSS(i,3)],'-','Color',[0.5 0.5 0.5])
hold on
clear i
end
plot([1 2],mean([RHO_FD_SSS(:,2)-RHO_FD_SSS(:,1),RHO_FD_SSS(:,4)-RHO_FD_SSS(:,3)]),'-kx','MarkerSize',10,'LineWidth',1.5)
set(gca,'Xtick',1:2,'XtickLabel',{'QPS5','QPS50'},'FontSize',16,'TickDir','out')
box off
xlim([0.5 2.5]); ylim([-0.8 0.6]); ylabel('\Delta FC [bilateral M1] mean FD and sleepiness removed')

[h p2 ci stats]=ttest([qps5_diff_FD,qps50_diff_FD,qps5_diff_FD-qps50_diff_FD])
[h p3 ci stats]=ttest([qps5_diff_FD_SSS,qps50_diff_FD_SSS,qps5_diff_FD_SSS-qps50_diff_FD_SSS])
