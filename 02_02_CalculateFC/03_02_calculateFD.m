% Just calculate FD for all rsfMRI data
% Ikko Kimura, Osaka University, 2022/9/7

subj_list={'IK101SS','IK104MY','IK106TI','IK108KT','IK110MN','IK111SS','IK112EK','IK113MM','IK114TS','IK115KT','IK116HJ','IK117SN','IK121YI','IK122IM','IK123SM','IK124SM'};
fname={'qps5_REST1_AP','qps5_REST2_AP','qps50_REST1_AP','qps50_REST2_AP'};


for ii=1:length(subj_list)
subj=subj_list(ii);
disp(subj)
for i=1:length(fname)
disp(fname(i))
%d=diff(load(cell2mat(strcat('data/',subj,'/',fname(i),'/MotionCorrection/',fname(i),'_mc.par'))));
d=load(cell2mat(strcat('data/',subj,'/',fname(i),'/Movement_Regressors.txt')));
dd=sum(abs(d(:,7:9)),2)+sum((50*pi/180)*abs(d(:,10:12)),2);

if mean(dd)>0.2
    disp('mean fd was higher than 0.2mm')
end
if max(dd)>5
    disp('max fd was higher than 5mm')
end
if length(find(dd>0.5))/length(dd)>0.2
    disp('prevalence rate was higher than 0.2')
end

FD(ii,i)=mean(dd);

end
end
