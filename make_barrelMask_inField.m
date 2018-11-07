function [ barrels_inField ] = make_barrelMask_inField( imfield_mask,barrelmasks )
% Make mask of barrels within imaging field from overall barrelmasks

tmp=regionprops(imfield_mask,'centroid');
centroid=round(tmp.Centroid);
barrel_imfield_mask=zeros(size(imfield_mask));
ufc=centroid-256;
barrel_imfield_mask((ufc(2):ufc(2)+511),(ufc(1):ufc(1)+511))=1;
barrel_imfield_mask=logical(barrel_imfield_mask);

barrels=fieldnames(barrelmasks);

for k=1:length(barrels)
    newmask=(barrelmasks.(barrels{k})(barrel_imfield_mask));
    if sum(newmask)>0
        newmask=reshape(newmask,512,512);
        barrels_inField.(barrels{k})=newmask;
    end
end

end

