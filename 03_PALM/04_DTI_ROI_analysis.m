subj=["IK101SS","IK104MY","IK106TI","IK108KT","IK110MN","IK111SS","IK112EK","IK113MM","IK114TS","IK115KT","IK116HJ","IK117SN","IK121YI","IK122IM","IK123SM","IK124SM"];
fname=["FA_CC","FA_MOTOR.L","FA_MOTOR.R","MD_CC","MD_MOTOR.L","MD_MOTOR.R"];

for i=1:length(subj)
    i
    for j=1:length(fname)
        DTI_ROI(i,:,j)=load(strcat( 'DiffusionROI/',fname(j),'_',subj(i)))';
    end
end

for i=1:6
    DTI_ROI_diff(:,:,i)=[DTI_ROI(:,2,i)-DTI_ROI(:,1,i) DTI_ROI(:,4,i)-DTI_ROI(:,3,i) DTI_ROI(:,2,i)-DTI_ROI(:,1,i)-DTI_ROI(:,4,i)+DTI_ROI(:,3,i)];
end

for i=1:6
    disp(fname(i))
   [h,p,ci,stats]=ttest(DTI_ROI_diff(:,:,i)) 
end

disp('QPS5')
for i=1:6
   [r,p]=corr(squeeze(DTI_ROI_diff(:,1,i)),qps5_diff) 
end

disp('QPS50')
for i=1:6
   [r,p]=corr(squeeze(DTI_ROI_diff(:,2,i)),qps50_diff) 
end

ff={'\Delta FA [CC]','\Delta FA [left M1]','\Delta FA [right M1]','\Delta MD [CC]','\Delta MD [left M1]','\Delta MD [right M1]'};

figure()
for ii=1:6
    subplot(2,3,ii)
    for i=1:16
        plot([1 2],[DTI_ROI(i,1,ii),DTI_ROI(i,2,ii)],'-','Color',[0.5 0.5 0.5])
        hold on
        clear i
    end
    plot([1 2],mean([DTI_ROI(:,1,ii),DTI_ROI(:,2,ii)]),'-kx','MarkerSize',10,'LineWidth',1.5)
    set(gca,'Xtick',1:2,'XtickLabel',{'PRE','POST'},'FontSize',16,'TickDir','out')
    box off
    xlim([0.5 2.5])
    ylabel(ff(ii))
end

ll=[0:0.1:1];

for ii=1:length(ll)
    for i=1:6
        for j=1:3
           BF10(ii,i,j)=bf.ttest(DTI_ROI_diff(:,j,i),'scale',ll(ii)); 
        end
    end
end

for i=1:3
   subplot(3,1,i)
   plot(ll,BF10(:,:,i))
   legend(ff); box off
   hold on
    plot([0 1],[1/3 1/3],'--k')
end