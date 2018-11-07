function insight_demo()

%% load data for one example field, plot a few receptive fields

path_demo='E:\Data\reduced\DENR9a\20161021\f1\';
[cells,traceByStim,sponTrace,framesEvoked,permTestResults,...
    dists,ROIsInBarrel,ROItoBarrel,ROI_positions,Stimuli,deltaF,sampRate,whiskPref,mag,imfield_mask,barrelmasks ] = load_nonNPsub_data( path_demo );

%% plot some dF/F traces
%  plot dF/F traces for each cell by movie

cellsToPlot={'ROI56','ROI70','ROI80','ROI85','ROI86','ROI93'};
whisk=fieldnames(traceByStim.(cellsToPlot{1}));
stims=[whisk', 'blank'];
plot_deltaF_byMovie( cellsToPlot,deltaF,sampRate,Stimuli,stims,2,4)

%% Plot receptive fields for each cell
% cellsToPlot={'ROI126','ROI125','ROI47','ROI8','ROI122','ROI114'};
RF_plot_2016v2( cellsToPlot,traceByStim,sampRate(1),framesEvoked )

%% Color code by best whisker

colorCodeByWhiskPref( path_demo )

%% run basic detection decoder for this example field

ensemble_size=[1:3,5:5:30];
[PC_ensemble,PC_ensemble_shuff,popDists_ensemble,popDists_centroid,...
    settings]=decode_shuffVnorm_detect_20180718(path_demo,ensemble_size);

%% load in ensemble decoder results from all fields
ensemble_size=[1:3,5:5:30];
load('E:\Data\reduced\decoder_NH_detect_18-Jul-2018.mat')
load('E:\Data\reduced\decoder_EN_detect_18-Jul-2018.mat')


%%
tmpPC=cat(1,PC_ensemble_EN{:});
tmpPCsh=cat(1,PC_ensemble_shuff_EN{:});
tmpDist=cat(1,popDists_ensemble_EN{:});
tmpCenDist=cat(1,popDists_centroid_EN{:})
for E=1:length(ensemble_size)
    PC_all_EN{E}=cat(2,tmpPC{:,E});
    PC_shuff_EN{E}=cat(2,tmpPCsh{:,E});
    distsAll_EN{E}=cat(2,tmpDist{:,E});
    distsCen_EN{E}=cat(1,tmpCenDist{:,E})';
end

fieldSizes=cellfun(@length,PC_ensemble_NH);
for E=1:length(ensemble_size)
    inds_use=fieldSizes>=E;
    tmpPC=cellfun(@(x)x{E},PC_ensemble_NH(inds_use),'un',0);
    tmpPCsh=cellfun(@(x)x{E},PC_ensemble_shuff_NH(inds_use),'un',0);
    tmpDist=cellfun(@(x)x{E},popDists_ensemble_NH(inds_use),'un',0);
    tmpCenDist=cellfun(@(x)x{E},popDists_centroid_NH(inds_use),'un',0);
    PC_all_NH{E}=cat(2,tmpPC{:});
    PC_shuff_NH{E}=cat(2,tmpPCsh{:});
        distsAll_NH{E}=cat(2,tmpDist{:});
    distsCen_NH{E}=cat(1,tmpCenDist{:})';

end


%%
% distribution of BW PC for single ROIs
% dists_single_EN=cellfun(@(x)x{1},popDists_ensemble_EN,'un',0);
% dists_single_EN=cat(2,dists_single_EN{:});
CWinds=distsAll_EN{1}<150;
% PC_single_EN=cellfun(@(x)x{1},PC_ensemble_EN,'un',0);
% PC_single_EN=cat(2,PC_single_EN{:});
PC_CW_single_EN=PC_all_EN{1}(CWinds);
figure; hold on
h_EN=histogram(PC_CW_single_EN,'BinWidth',0.01,'Normalization','probability')
h_EN.FaceColor='r';
h_EN.FaceAlpha=0.4;
h_EN.EdgeColor='r';
ax=gca; hold on

% dists_single_NH=cellfun(@(x)x{1},popDists_ensemble_NH,'un',0);
% dists_single_NH=cat(2,dists_single_NH{:});
CWinds=distsAll_NH{1}<150;
% PC_single_NH=cellfun(@(x)x{1},PC_ensemble_NH,'un',0);
% PC_single_NH=cat(2,PC_single_NH{:});

PC_CW_single_NH=PC_all_NH{1}(CWinds);
h_NH=histogram(PC_CW_single_NH,'BinWidth',0.01,'Normalization','probability')
h_NH.FaceColor='k';
h_NH.FaceAlpha=0.4;
h_NH.EdgeColor='k';
ax=gca; hold on

xlabel('Percent Correct detection of CW')
ylabel('Percent of single-ROI decoders')

p=permutationTest(PC_CW_single_EN,PC_CW_single_NH,10000)
title(['p=',num2str(p)])

meanPC_CW_EN=mean(PC_CW_single_EN)
semPC_CW_EN=std(PC_CW_single_EN)/sqrt(length(PC_CW_single_EN))

meanPC_CW_NH=mean(PC_CW_single_NH)
semPC_CW_NH=std(PC_CW_single_NH)/sqrt(length(PC_CW_single_NH))

%%
%%
PbySizeMean_EN=cellfun(@(x)mean(x(:)),PC_all_EN);
PbySizeSEM_EN=cellfun(@(x)std(x(:))/sqrt(length(x(:))),PC_all_EN);

PbySizeShMean_EN=cellfun(@(x)mean(x(:)),PC_shuff_EN);
PbySizeShSEM_EN=cellfun(@(x)std(x(:))/sqrt(length(x(:))),PC_shuff_EN);

PbySizeMean_NH=cellfun(@(x)mean(x(:)),PC_all_NH);
PbySizeSEM_NH=cellfun(@(x)std(x(:))/sqrt(length(x(:))),PC_all_NH);

PbySizeShMean_NH=cellfun(@(x)mean(x(:)),PC_shuff_NH);
PbySizeShSEM_NH=cellfun(@(x)std(x(:))/sqrt(length(x(:))),PC_shuff_NH);



figure; hold on
errorbar(ensemble_size,PbySizeMean_EN,PbySizeSEM_EN,'r.-','LineWidth',1);
errorbar(ensemble_size,PbySizeMean_NH,PbySizeSEM_NH,'k.-','LineWidth',1);
xlabel('ensemble size')
ylabel('mean percent correct')
title('non-shuffled, mean performance')
legend('EN','NH')

figure; hold on
errorbar(ensemble_size,PbySizeShMean_EN,PbySizeShSEM_EN,'r.-','LineWidth',1);
errorbar(ensemble_size,PbySizeShMean_NH,PbySizeShSEM_NH,'k.-','LineWidth',1);
xlabel('ensemble size')
ylabel('mean percent correct')
title('shuffled, mean performance')
legend('EN','NH')
%% 
for e=1:length(ensemble_size)
    [ dist_NH,mean_NH,sem_NH,num_ROIs_NH,binEdges ] = binVarByDist( distsAll_NH{e}(:), PC_all_NH{e}(:),20 );
    [ dist_EN,mean_EN,sem_EN,num_ROIs_EN,binEdges ] = binVarByDist( distsAll_EN{e}(:), PC_all_EN{e}(:),20 );
    
    totesComboPlot(dist_NH,mean_NH,sem_NH,num_ROIs_NH,[],dist_EN,mean_EN,sem_EN,num_ROIs_EN,[])
    xlabel('distance to column center')
    ylabel('fraction correct')
    title(['Ensembles size ',num2str(ensemble_size(e)),' cells'])
end
   

%% 
for e=1:length(ensemble_size)
    [ dist_NH,mean_NH,sem_NH,num_ROIs_NH,binEdges ] = binVarByDist( distsAll_NH{e}(:), PC_shuff_NH{e}(:),10 );
    [ dist_EN,mean_EN,sem_EN,num_ROIs_EN,binEdges ] = binVarByDist( distsAll_EN{e}(:), PC_shuff_EN{e}(:),10 );
    
    totesComboPlot(dist_NH,mean_NH,sem_NH,num_ROIs_NH,[],dist_EN,mean_EN,sem_EN,num_ROIs_EN,[])
    xlabel('distance to column center')
    ylabel('fraction correct')
    title(['shuffled; Ensembles size ',num2str(ensemble_size(e)),' cells'])
end
   


