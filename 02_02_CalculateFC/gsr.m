function [tt_gsr]=gsr(tt) 

% create global signal
gs = mean(tt,2);
gs=gs-mean(gs);


for i=1:size(tt,2)
[~,~,res(:,i)] = regress(tt(:,i),[gs ones(length(gs),1)]);
end
tt_gsr=res;

