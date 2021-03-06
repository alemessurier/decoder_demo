function [cvN_new,PC_ensemble,PC_ensemble_shuff,popDists_ensemble,popDists_centroid,settings]=decode_detect_demo(pathName,ensemble_size)

% Predict whether a whisker was deflected or not on each trial
% Decoder works as a one vs all decoder trained with logistic regression
% using kfold cross validation

%% Prepare data from this imaging field for model fitting

% load reduced data from this imaging field
[~,traceByStim,sponTrace,framesEvoked,permTestResults,~,...
    ROIsInBarrel,ROItoBarrel]= load_nonNPsub_data( pathName );
load([pathName,'ROI_pos_barrel.mat'],'ROI_pos_barrel');

sigROIs=find_sigROIs(permTestResults,traceByStim); % only include cells that were significantly whisker responsive
whisk=fieldnames(traceByStim.(sigROIs{1})); % the set of whiskers deflected in this experiment

% limit ensemble sizes by number of responsive ROIs
ensemble_size=ensemble_size(ensemble_size<length(sigROIs));
stims=[whisk;'blank']; % include blank trials in stimulus set

% for each cell, store mean dF/F on each trial for each whisker
for K=1:length(sigROIs)
    for j=1:length(whisk)
        rVec_tmp=mean(traceByStim.(sigROIs{K}).(whisk{j})(:,framesEvoked),2);
        rVec_byStim.(sigROIs{K}).(whisk{j})=rVec_tmp;
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
    
end


%Initialize important variables for fitting decoder
folds = 5; %Number of folds for kfold cross-validation
reps = 500; %Number of repetitions for fitting model


%save fitting variables, etc. to structure
settings.stims=stims;
settings.folds=folds;
settings.reps=reps;
settings.ROIs=sigROIs;
settings.ensembles=ensemble_size;


%% Train decoders for individual ROIs
%parfor N=1:10 %repeat 10 times to increase repetitions of fitting without reducing amount of data for each fold
%     [cvN(N),probN(N),cvNshuff(N),probNshuff(N)] = train_decoders_detect(stims,folds,sigROIs,rVec_byStim);
%end

% concatenate predictions across repetitions
% for i=1:length(sigROIs)
%     probN_new.(sigROIs{i})=cat(1,probN(:).(sigROIs{i}));
%     probNshuff_new.(sigROIs{i})=cat(1,probNshuff(:).(sigROIs{i}));
%     cvN_new.(sigROIs{i})=cat(1,cvN(:).(sigROIs{i}));
%     cvNshuff_new.(sigROIs{i})=cat(1,cvNshuff(:).(sigROIs{i}));
% end

[cvN_new,probN_new,cvNshuff_new,probNshuff_new] = train_decoders_detect(stims,folds,sigROIs,rVec_byStim);

%% Decode from randomly selected populations of varying size

[PC_ensemble, PC_ensemble_shuff,popDists_ensemble,popDists_centroid]=...
    popDecode_detect_20180718(ensemble_size,reps,50,sigROIs,cvN_new,probN_new,cvNshuff_new,probNshuff_new,stims,whisk,ROI_pos_barrel);

end

