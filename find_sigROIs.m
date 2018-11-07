function [ sigROIs,sig_inds_whisk,sig_inds ] = find_sigROIs( permTestResults,traceByStim )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

cellNames=fieldnames(traceByStim);
whisk=fieldnames(permTestResults.(cellNames{1}));
for i=1:length(cellNames)
    pvals=cellfun(@(x)permTestResults.(cellNames{i}).(x),whisk,'Uni',1);
    sig_inds_whisk{i}=MultControl(pvals,0.05,'FDR');
    sig_inds(i)=sum(sig_inds_whisk{i})>0;
    
     nanInds(i)=sum(cellfun(@(x)sum(sum(isnan(traceByStim.(cellNames{i}).(x)))),whisk,'Uni',1));
end
nanInds=nanInds>0;
sigROIs=cellNames(sig_inds & ~nanInds);





end

