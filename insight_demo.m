function insight_demo()

%% load data for one example field, plot a few receptive fields

path_demo='/Users/amylemessurier/Desktop/f1/';
[cells,traceByStim,sponTrace,framesEvoked,permTestResults,...
    dists,ROIsInBarrel,ROItoBarrel,ROI_positions,Stimuli,deltaF,sampRate,whiskPref,mag,imfield_mask,barrelmasks ] = load_nonNPsub_data( path_demo );

%% plot some dF/F traces
%  plot dF/F traces for each cell by movie

% cellsToPlot={'ROI56','ROI70','ROI80','ROI85','ROI86','ROI93'};
cellsToPlot={'ROI96','ROI85','ROI55','ROI52','ROI40','ROI36','ROI35','ROI24'};
whisk=fieldnames(traceByStim.(cellsToPlot{1}));
stims=[whisk', 'blank'];
plot_deltaF_byMovie( cellsToPlot,deltaF,sampRate,Stimuli,stims,2,4)

%% Plot receptive fields for each cell
cellsToPlot={'ROI96','ROI85','ROI55','ROI52','ROI40','ROI36','ROI35','ROI24'};
RF_plot_simple( cellsToPlot,traceByStim,sponTrace,sampRate(1),framesEvoked )


%% run basic detection decoder for this example field

ensemble_size=[1:3,5:5:30];
[cvN,PC_ensemble,PC_ensemble_shuff,popDists_ensemble,popDists_centroid,...
    settings]=decode_detect_demo(path_demo,ensemble_size);

%% Make ROI color coded plot indicating individual ROI performance on BW detection

colorCodeByWhiskPref( path_demo )
%% load in ensemble decoder results from all fields
ensemble_size=[1:3,5:5:30];
load('/Users/amylemessurier/Desktop/decoder_reduced/decoder_EN_detect_18-Jul-2018.mat')
load('/Users/amylemessurier/Desktop/decoder_reduced/decoder_NH_detect_18-Jul-2018.mat')


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



%% find mean performance of each ensemble on CWs (based on the min distance column)

mean_PCW_bySize_EN=zeros(1,numel(distsAll_EN));
sem_PCW_bySize_EN=zeros(1,numel(distsAll_EN));
for K=1:numel(distsAll_EN)
    [~,CWidx]=min(distsAll_EN{K},[],1);
    CWs=sub2ind(size(distsAll_EN{K}),CWidx,1:size(distsAll_EN{K},2));
    PCuse=PC_all_EN{K}(CWs);
    mean_PCW_bySize_EN(K)=mean(PCuse);
    sem_PCW_bySize_EN(K)=std(PCuse)/sqrt(length(PCuse));
end

mean_PCW_bySize_NH=zeros(1,numel(distsAll_NH));
sem_PCW_bySize_NH=zeros(1,numel(distsAll_NH));
for K=1:numel(distsAll_NH)
    [~,CWidx]=min(distsAll_NH{K},[],1);
    CWs=sub2ind(size(distsAll_NH{K}),CWidx,1:size(distsAll_NH{K},2));
    PCuse=PC_all_NH{K}(CWs);
    mean_PCW_bySize_NH(K)=mean(PCuse);
    sem_PCW_bySize_NH(K)=std(PCuse)/sqrt(length(PCuse));
end

figure; hold on
errorbar(ensemble_size,mean_PCW_bySize_EN,sem_PCW_bySize_EN,'r.-','LineWidth',1);
errorbar(ensemble_size,mean_PCW_bySize_NH,sem_PCW_bySize_NH,'k.-','LineWidth',1);
xlabel('ensemble size')
ylabel('mean percent correct')
title('mean performance detecting closest whisker')
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
   


