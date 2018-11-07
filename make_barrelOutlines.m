function [ all_outlines ] = make_barrelOutlines( barrelMask)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

barrels=fieldnames(barrelMask);

for K=1:length(barrels)
    thisMask=barrelMask.(barrels{K});
    se=strel('disk',4);
    dil_mask=imdilate(thisMask,se);
    boundsMask(:,:,K)=dil_mask-thisMask;
end

tmpmask=ones(512,512);
tmpmask2=ones(508,508);
tmpmask2=padarray(tmpmask2,[2 2]);
imfield_bounds=tmpmask-tmpmask2;
all_outlines=(sum(boundsMask,3)+imfield_bounds)>0;


end

