function [PC_ensemble, PC_ensemble_shuff,popDists_ensemble,popDists_centroid]=...
    popDecode_detect_20180718(ensemble_size,reps,folds,sigROIs,cvN,probN,cvNshuff,probNshuff,stims,whisk,ROI_pos_barrel)


popDists_ensemble=cell(1,length(ensemble_size)); %for each ensemble size, array of mean distances of ROIs to each barrel for each repetition
popDists_centroid=popDists_ensemble;
PC_ensemble=popDists_ensemble;
PC_ensemble_shuff=PC_ensemble;
% RFs=zeros(9,length(sigROIs));
% rVec_all=cell(1,length(sigROIs));

% for r=1:length(sigROIs)
%     rvec=cellfun(@(x)mean(rVec_byStim.(sigROIs{r}).(x)),whisk,'un',1);
%     tmp=cellfun(@(x)rVec_byStim.(sigROIs{r}).(x),whisk,'un',0);
%     tmp=cat(1,tmp{:});
%     tmpMean=mean(tmp);
%     tmpStd=std(tmp);
%     tmp=(tmp-tmpMean)/tmpStd;
%     
%     rVec_all{r}=tmp;
%     RFs(:,r)=rvec;
% end


for E=1:length(ensemble_size)
    rep=nchoosek(length(sigROIs),ensemble_size(E));
    if rep<reps
        ROIsRep=cell(1,rep);
        ROIinds=combnk(1:length(sigROIs),ensemble_size(E));
        for i=1:rep;
            ROIsRep{i}=sigROIs(ROIinds(i,:));
        end
    else
        rep=reps;
        ROIsRep=cell(1,rep);
        for i=1:rep
            ROIsRep{i}=datasample(sigROIs,ensemble_size(E));
        end
        
        
    end
    
    
    enBarrDists=zeros(length(whisk),rep); % mean distances of ROIs to each barrel for each repetition
    sumDistCen=zeros(rep,1);
    
    PCbyW_rep=zeros(length(whisk),rep);
    PCbyW_shuff_rep=PCbyW_rep;
    
    
    
    parfor i = 1:rep %Loop over repeats of model fitting
        %Do the population decoding by fold
        ROIs=ROIsRep{i};
        
        
        tmpBarrDists=zeros(length(whisk),ensemble_size(E)); %distances of each ROI in ensemble to each barrel
               cenDists=zeros(ensemble_size(E),1);

          % find sum of distacnes of ROIs in ensembles to centroid of all
        % positions
        ROIpos=cellfun(@(x)ROI_pos_barrel.d2.(x),ROIs,'un',0);
        ROIpos=cat(1,ROIpos{:});
        ensemble_centroid=mean(ROIpos,1);
        
        for e=1:length(ROIs)
            dists=cellfun(@(x)centroidDist(ROI_pos_barrel.(x).(ROIs{e}),[0 0]),whisk,'Uni',1);
            tmpBarrDists(:,e)=dists;
            cenDists(e)=centroidDist(ROIpos(e,:),ensemble_centroid);
        end
        
        
        
        enBarrDists(:,i)=mean(tmpBarrDists,2);
        popData = cell(1,folds); %Each entry will have the probabilities for each stimulus by cell and fold
        %         popConfN = popData; %Population decoder confusion matrices
        %         PCC = zeros(1,folds); %Storage of percent correct per fold
        
        popDataShuff = cell(1,folds); %Each entry will have the probabilities for each stimulus by cell and fold
        %         popConfNshuff = popData; %Population decoder confusion matrices
        %         PCC_shuff = zeros(1,folds); %Storage of percent correct per fold
        
        PCbyW=cell(1,folds);
        PCbyW_shuff=PCbyW;
        TrueS=cell(1,folds);
        for k = 1:folds %Loop over folds
            %%
            %Extract data from individual units
            %             stimReps = cellfun(@(x) histc(x(2,:),1:length(stims)),cvN.(sigROIs{1}){k},'un',0); stimReps = vertcat(stimReps{:}); %repetitions of each stimulus for each fold
            %             reps2use = min(stimReps); %minimum number of repetitions used
            trueS=cell(1,length(whisk));
            for st=1:length(whisk)
                trueS{st}=cvN.(ROIs{e}){k,st}(2,:);
            end
            TrueS{k}=cat(1,trueS{:});
            
            %             popData{k} = zeros(length(stims),sum(reps2use),length(ROIs)); %each paCFge is the probabilities of a separate cell, columns are different trials and rows are different sequences
            %             popDataShuff{k}=popData{k};
            
            for e = 1:length(ROIs) %Loop over units
                
                
                tempStore = cell(1,length(whisk)); %Temporary storage of probabilities
                shuffStore=tempStore;
                for st = 1:length(whisk) %Loop over stimuli
                    %                     dat2use=find(=cvN.(ROIs{e}){k,st}(2,:)==st); % *******Note: important that these indices are the same across ROIs, shuffled v. non shuff. Add in safety check********
                    %                     dat2use=dat2use(1:reps2use(st));
                    
                    tempStore{st} = probN.(ROIs{e}){k,st}; %Get probabilities
                    shuffStore{st} = probNshuff.(ROIs{e}){k,st}; %Get probabilities
                end
                popData{k}(:,:,e) = cat(1,tempStore{:}); %Store data
                popDataShuff{k}(:,:,e) = cat(1,shuffStore{:}); %Store data
                
            end
            %%
            %Evaluate the performance of the population decoder
            dat2an = popData{k}; %Extract the data
            dat2an = mean(dat2an,3); %average probabilities across units
            
            pred=repmat((1:length(whisk))',1,size(dat2an,2));
            
            inds_st=dat2an>0.5;
            pred=pred.*inds_st;
            pred(~inds_st)=10;
            
            corr=pred==TrueS{k};
            
            
            %Calculate percent correct
            PCbyW{k} = mean(corr,2);
            
            
            %%%%%%%%%%%
            % repeat for shuffled decoder
            %Evaluate the performance of the population decoder
            dat2an = popDataShuff{k}; %Extract the data
            dat2an = mean(dat2an,3); %average probabilities across units
            
            pred=repmat((1:length(whisk))',1,size(dat2an,2));
            
            inds_st=dat2an>0.5;
            pred=pred.*inds_st;
            pred(~inds_st)=10;
            
            corr=pred==TrueS{k};
            
            
            %Calculate percent correct
            PCbyW_shuff{k} = mean(corr,2);
            
        end
        PCbyW=cat(2,PCbyW{:});
        PCbyW_rep(:,i)=mean(PCbyW,2);
        
        PCbyW_shuff=cat(2,PCbyW_shuff{:});
        PCbyW_shuff_rep(:,i)=mean(PCbyW_shuff,2);
    end
    PC_ensemble{E}=PCbyW_rep;
    PC_ensemble_shuff{E}=PCbyW_shuff_rep;
    popDists_ensemble{E}=enBarrDists;
     popDists_centroid{E}=sumDistCen;
end
end



