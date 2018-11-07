function [im_handle,hbar]=colorCodeROIs(varargin)
%COLORCODEROIS plots average imaging field with ROI masks colorcoded by a
%scaling variable
%
% INPUTS:
%           ROIsToPlot:     cell array of names of ROIs to plot (required)
%           dir_processed:  (string) name of directory containing processed
%                           movies (required)
%           ROI_positions:  512x512xn logical array of ROI masks (required)
%           scale_var:      1xn array, colorcoding variable (required)
%           numBins:        optional, number of bins
%           cmapName:       optional, colormap from brewermap
%           cmapBounds:     optional, min and max value for colormap
%
% AML 2017
%% decode varargin

tmpInds=cellfun(@iscell,varargin);
ROIsToPlot=varargin{tmpInds};

maskInds=cellfun(@(x)size(x,1)==512,varargin);
ROI_positions=varargin{maskInds};

strsInds=cellfun(@ischar,varargin);
tmp=1:length(varargin);
strsInds=tmp(strsInds);
dir_processed=varargin{strsInds(1)};

scaleInds=cellfun(@(x)strcmp(x,'scale_var'),varargin(strsInds));
if sum(scaleInds)==0
    error('input scaling variable')
else
    scale_var=varargin{strsInds(scaleInds)+1};
end

numBinsInds=cellfun(@(x)strcmp(x,'numBins'),varargin(strsInds));
if sum(numBinsInds)==0
    numBins=20;
else
    numBins=varargin{strsInds(numBinsInds)+1};
end


% cmapInds=cellfun(@(x)strcmp(x,'cmapName'),varargin(strsInds));
% if sum(cmapInds)==0;
%     cmapName='RdPu';
% else
%     cmapName=varargin{strsInds(cmapInds)+1};
% end

cmapInds=cellfun(@(x)strcmp(x,'cmap'),varargin(strsInds));
if sum(cmapInds)==0;
    cmap=brewermap(numBins,'RdPu');
else
    cmap=varargin{strsInds(cmapInds)+1};
end


bInds=cellfun(@(x)strcmp(x,'cmapBounds'),varargin(strsInds));
if sum(bInds)==0;
    cmapBounds(1)=min(scale_var);
    cmapBounds(2)=max(scale_var);
else
    cmapBounds=varargin{strsInds(bInds)+1};
end

imInds=cellfun(@(x)strcmp(x,'imfield_mask'),varargin(strsInds));
if sum(imInds)>0;
    imfield_mask=varargin{strsInds(imInds)+1};
end

barrInds=cellfun(@(x)strcmp(x,'barrelmasks'),varargin(strsInds));
if sum(barrInds)>0;
    barrelmasks=varargin{strsInds(barrInds)+1};
end

%% function body

cd(dir_processed)
imFiles=dir('*.tif');
stackNames=arrayfun(@(x)x.name,imFiles,'Uni',0);

thisStack=stackNames{ceil(length(stackNames)/2)};
[curr_im,~]=LoadTIFF_SI5(strcat(dir_processed,thisStack));
im=mean(curr_im,3);
% colormap gray
im=im/max(max(im));
im=imadjust(im);
% figure;
im_handle=imshow(im);
hold on
freezeColors

for i=1:size(ROI_positions,3)
    ROI=strcat('ROI',num2str(i));
    ROI_coord.(ROI)=ROI_positions(:,:,i);
end
minVal=cmapBounds(1);
maxVal=cmapBounds(2);
edges=minVal:(maxVal-minVal)/numBins:maxVal;
[~,~,binID]=histcounts(scale_var,edges);
% cmap=brewermap(numBins,cmapName);

for i=1:numBins;
    colorMask=cat(3,repmat(cmap(i,1),size(im,1)),repmat(cmap(i,2),size(im,1)),repmat(cmap(i,3),size(im,1)));
    h(i)=imshow(colorMask);
    ROIsThisColor=ROIsToPlot(binID==i);
    roiWhiskMask=cellfun(@(x)ROI_coord.(x),ROIsThisColor,'Uni',0);
    rwm=sum(cat(3,roiWhiskMask{:}),3);
    rwm=rwm>0;
    set(h(i),'AlphaData',rwm*1)
end
hbar=colorbar;
colormap(cmap)
freezeColors
hbar.Ticks=[0 (1:numBins)/numBins];
hbar.TickLabels=edges;
freezeColors

if sum(barrInds)>0 && sum(imInds)>0
    barrels_inField = make_barrelMask_inField( imfield_mask,barrelmasks );
    [ all_outlines ] = make_barrelOutlines( barrels_inField);
    whiteMask=ones(512,512,3);
    w=imshow(whiteMask);
    w.AlphaData=all_outlines;
    
    barrels=fieldnames(barrels_inField);
    for i=1:length(barrels)
        tmpPos=regionprops(barrels_inField.(barrels{i}),'centroid');
        text(tmpPos.Centroid(1),tmpPos.Centroid(2),barrels{i},'FontSize',24,'Color','w')
    end
else
end
end

