function [ P ] = permutationTest(stimLocked,spont,numReps )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

T=abs(nanmean(stimLocked)-nanmean(spont));
dim1=find(size(stimLocked)>1);
pooled=cat(dim1,stimLocked,spont);

for t=1:numReps
    indsA=randsample(1:length(pooled),length(stimLocked));
    A=pooled(indsA);
    indsB=ones(length(pooled),1);
    indsB(indsA)=0;
    indsB=logical(indsB);
    B=pooled(indsB);
%     A=randsample(pooled,length(stimLocked));
%     inds=ismember(pooled,A);
%     B=pooled(~inds);
    PT(t)=abs(nanmean(A)-nanmean(B));
end
PT(t+1)=T;
P=sum(PT>=T)/length(PT);



end

