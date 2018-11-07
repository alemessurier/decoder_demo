function [PC_ensemble,PC_ensemble_shuff,popDists_ensemble,popDists_centroid,settings]=decode_shuffVnorm_detect_20180718(pathName,ensemble_size)

%Decode sequence that was played from spike counts of each cell
%W2an is center whisker for sequences to be analyzed
%Decoder works as a one vs all decoder trained with logistic regression
%using kfold cross validation

%%
% amy variables
% make structure of mean responses of each ROI to each stimulus, in order
% presented, and stim identity
%  [ traceByStimAll,stimOrderAll ] = make_traceByStimAll(Stimuli,sampRate,deltaF,bl_length,timePostStim );
% stimOrderAll=stimOrderAll+1;
% make structure of mean responses of each ROI to each stimulus iteration
% find whisker responsive cells
[~,traceByStim,sponTrace,framesEvoked,permTestResults,~,...
    ROIsInBarrel,ROItoBarrel]= load_nonNPsub_data( pathName );
load([pathName,'ROI_pos_barrel.mat'],'ROI_pos_barrel');

sigROIs=find_sigROIs(permTestResults,traceByStim);
% sigROIs=fieldnames(traceByStim);
whisk=fieldnames(traceByStim.(sigROIs{1}));

% limit ensemble sizes by number of responsive ROIs
ensemble_size=ensemble_size(ensemble_size<length(sigROIs));
stims=[whisk;'blank'];
for K=1:length(sigROIs)
    for j=1:length(whisk)
        rVec_tmp=mean(traceByStim.(sigROIs{K}).(whisk{j})(:,framesEvoked),2);
        rVec_byStim.(sigROIs{K}).(whisk{j})=rVec_tmp;
        % postDist.(cellNames{K}).(whisk{j})=normpdf(rVec_tmp,mean(rVec_tmp),std(rVec_tmp));
    end
    rVec_tmp=mean(sponTrace.(sigROIs{K})(:,framesEvoked),2);
    rVec_byStim.(sigROIs{K}).blank=rVec_tmp;
    
    %zscore across stims
    rVecAll=cellfun(@(x)rVec_byStim.(sigROIs{K}).(x),stims,'Uni',0);
    rVecAll=cat(1,rVecAll{:});
    rMean=mean(rVecAll);
    rStd=std(rVecAll);
    
    for s=1:length(stims)
        rVec_byStim.(sigROIs{K}).(stims{s})=(rVec_byStim.(sigROIs{K}).(stims{s})-rMean)/rStd;
    end
    
    %     rVec_all.(sigROIs{K})=mean(traceByStimAll.(sigROIs{K})(:,framesEvoked),2);
end

% stims=fieldnames(rVec_byStim.(sigROIs{1}));

%Initialize important variables for fitting decoder
folds = 5; %Number of folds for kfold cross-validation
reps = 500; %Number of repetitions for fitting model


%save fitting variables, etc. to structure
settings.stims=stims;
settings.folds=folds;
settings.reps=reps;
settings.ROIs=sigROIs;
settings.ensembles=ensemble_size;

% ROI_pos_plot=cell(length(whisk),1);
% for i=1:length(sigROIs)
%     for K=1:length(whisk)
%         %=cellfun(@(x)ROI_pos_barrel.(x).(ROIs{i}),whisk,'un',0);
%         ROI_pos_plot{K}(i,:)=ROI_pos_barrel.(whisk{K}).(sigROIs{i});
%     end
% end

% Train decoders for individual ROIs
parfor N=1:10
[cvN(N),probN(N),cvNshuff(N),probNshuff(N)] = train_decoders_detect(stims,folds,sigROIs,rVec_byStim);
end

for i=1:length(sigROIs)
    probN_new.(sigROIs{i})=cat(1,probN(:).(sigROIs{i}));
    probNshuff_new.(sigROIs{i})=cat(1,probNshuff(:).(sigROIs{i}));
    cvN_new.(sigROIs{i})=cat(1,cvN(:).(sigROIs{i}));
    cvNshuff_new.(sigROIs{i})=cat(1,cvNshuff(:).(sigROIs{i}));
end


[PC_ensemble, PC_ensemble_shuff,popDists_ensemble,popDists_centroid]=...
    popDecode_detect_20180718(ensemble_size,reps,50,sigROIs,cvN_new,probN_new,cvNshuff_new,probNshuff_new,stims,whisk,ROI_pos_barrel);

end

