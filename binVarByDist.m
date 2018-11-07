function [ binned_dist,binnedY_mean,binnedY_SEM,num_ROIs,binEdges,binnedY ] = binVarByDist( distance,YVar,binEdges )
% bin elements of input YVar by distance to barrel (distance). binEdges can be a number of bins or a vector of bin edges. For plotting with totesComboPlot.

[distsAll,sortInds]=sort(distance,'ascend');
YVar=YVar(sortInds);
[~,binEdges,binInds]=histcounts(distsAll,binEdges);


for i=1:(length(binEdges)-1)
    binnedY{i}=YVar(binInds==i);
    binnedY_mean(i)=nanmean(YVar(binInds==i));
    binnedY_SEM(i)=nanstd(YVar(binInds==i))/sqrt(sum(binInds==i));
    
    binned_dist(i)=nanmean(distsAll(binInds==i));
    num_ROIs(i)=sum(binInds==i);
end
end




