function [cvN,probN,cvNshuff,probNshuff] = train_decoders_detect(stims,folds,ROIs,rVec_byStim)

%% Train decoders for individual ROIs without shuffling (output structures will convserve trial number across all ROIs)

%Some handles to be used
sig = @(x,y) 1./(1+exp(-y(2).*x - y(1)));


%Allocate memory and preprocess spikecount distributions

data2fit = cell(length(stims),folds,length(ROIs)); %Data that will be used for fitting
data2fitShuff=data2fit;
resp2fit = data2fit; %value of the response variable (stimulus identity associated with a given spike count)
datTmp=cellfun(@(x)rVec_byStim.(ROIs{1}).(x),stims,'Uni',0);
datTmp=cellfun(@(x)x',datTmp,'Uni',0);
numT = cellfun(@length,datTmp); %Number of trials per-stimulus
numT=min(numT);
prmIndx=cell(1,length(stims));
for r=1:length(stims)
    prmIndx{r} = randperm(numT); %This will be used to shuffle the data (this randomizes the folding process)
end

confN=cell(length(ROIs),length(stims)); %Confusion matrix for each cell/stim/fold
confNshuff=confN;

for e = 1:length(ROIs) %Loop over units
    probN.(ROIs{e}) = cell(folds,length(stims)); %stimulus probabilities for each test trial
    cvN.(ROIs{e}) = probN.(ROIs{e}); %prediction and real value of stimulus type
    
    probNshuff.(ROIs{e}) = cell(folds,length(stims)); %stimulus probabilities for each test trial
    cvNshuff.(ROIs{e}) = probN.(ROIs{e}); %prediction and real value of stimulus type
    
    
    %Separate data into kfolds (in this step the data is being folded
    %separately for each stimuli, this ensures that the number of
    %data points from each stimulus used in both training and testing
    %is roughly equal)
    
    dat=cellfun(@(x)rVec_byStim.(ROIs{e}).(x),stims,'Uni',0);
    dat=cellfun(@(x)x',dat,'Uni',0);

    %debugging 20180118
%     for st=1:length(stims)
%         dat{st}=ones(1,50)*st;
%     end
    
    for st = 1:length(stims) %Loop over stimuli
        
        %Store spike counts for each stimulus class separated by folds
        prmIdxShuff=randperm(numT); % shuffle order of stims relative to other ROIs
        datShuff{st}=mat2cell(dat{st}(prmIdxShuff),1,[repmat(floor(numT/folds),1,folds-1),numT-floor(numT/folds)*(folds-1)]);%Fold the data
        data2fitShuff(st,:,e) = datShuff{st};%Store
        
        dat{st} = mat2cell(dat{st}(prmIndx{st}),1,[repmat(floor(numT/folds),1,folds-1),numT-floor(numT/folds)*(folds-1)]);%Fold the data
        data2fit(st,:,e) = dat{st};%Store
        %Generate the associated response variable (stimulus type)
        resp = mat2cell((st.*ones(1,numT)),1,[repmat(floor(numT/folds),1,folds-1),numT-floor(numT/folds)*(folds-1)]);%Fold the response variables
        resp2fit(st,:,e)=resp;%store
    end
    
    for k = 1:folds %Loop over folds
        testdat = [data2fit{:,k,e}]; %Extract spike counts for validation or test set
        testresp = [resp2fit{:,k,e}];%'...' stimulus identity
%         cvN.(ROIs{e}){k} = zeros(3,length(testresp)); %first row is model predictions, second is the actual value, third is a binary vector were 1 denotes a correct prediction
%         probN.(ROIs{e}){k} = zeros(length(stims),length(testresp)); %Will contain calculated stimulus probabilities after doing logistic regression for each fold
        cf = zeros(length(stims),2); %weights for each fold
        
        % shuffled trials
        testdatShuff = [data2fitShuff{:,k,e}]; %Extract spike counts for validation or test set
%         cvNshuff.(ROIs{e}){k} = zeros(3,length(testresp)); %first row is model predictions, second is the actual value, third is a binary vector were 1 denotes a correct prediction
%         probNshuff.(ROIs{e}){k} = zeros(length(stims),length(testresp)); %Will contain calculated stimulus probabilities after doing logistic regression for each fold
        cfShuff = zeros(length(stims),2); %weights for each fold
        
        for st = 1:9%length(stims)
            traindat_class = [(data2fit{st,~(1:folds==k),e})]; %training data for current class being trained
            trainresp_class = ones(size(traindat_class)); %resp variables, all 1s
            traindat_other = [data2fit{10,~(1:folds==k)}]; %    blank trials
            trainresp_other = zeros(size(traindat_other)); %resp variables, all 0s
            testresp_st=testresp(testresp==st | testresp==10);
            
            %make the fit
            [cf(st,:),~,stats] = glmfit([traindat_class,traindat_other]',[trainresp_class,trainresp_other]','binomial'); %Logistic regression;
            probN.(ROIs{e}){k,st} = sig(testdat(testresp==st | testresp==10),cf(st,:)); % for each st, probs on all st and blank test trials
            
            %shuffled
            traindatShuff_class = [(data2fitShuff{st,~(1:folds==k),e})]; %training data for current class being trained
            traindatShuff_other = [data2fitShuff{10,~(1:folds==k)}]; %all other stim classes
            
            %make the fit
            [cfShuff(st,:),~,stats] = glmfit([traindatShuff_class,traindatShuff_other]',[trainresp_class,trainresp_other]','binomial'); %Logistic regression;
            probNshuff.(ROIs{e}){k,st} = sig(testdatShuff(testresp==st | testresp==10),cfShuff(st,:));
        
            %store predictions
%             probN.(ROIs{e}){k}{st} = bsxfun(@times,probN.(ROIs{e}){k}{st},1./sum(probN.(ROIs{e}){k}{st})); %Normalize probabilities
            
               
            pred=ones(size(testresp_st));
            inds_st=probN.(ROIs{e}){k,st}>0.5;
%             inds_st=tmp>0.5;
            pred(inds_st)=st;
            pred(~inds_st)=10;
     
        cvN.(ROIs{e}){k,st}(1,:) =pred ; %Store model predictions
        cvN.(ROIs{e}){k,st}(2,:) = testresp_st; %Store actual values
        cvN.(ROIs{e}){k,st}(3,:) = (cvN.(ROIs{e}){k,st}(1,:)-cvN.(ROIs{e}){k,st}(2,:))==0; %whether the prediction is correct
            
        pred=ones(size(testresp_st));
            inds_st=probNshuff.(ROIs{e}){k,st}>0.5;
%             inds_st=tmp>0.5;
            pred(inds_st)=st;
            pred(~inds_st)=10;
     
        cvNshuff.(ROIs{e}){k,st}(1,:) =pred ; %Store model predictions
        cvNshuff.(ROIs{e}){k,st}(2,:) = testresp_st; %Store actual values
        cvNshuff.(ROIs{e}){k,st}(3,:) = (cvNshuff.(ROIs{e}){k,st}(1,:)-cvNshuff.(ROIs{e}){k,st}(2,:))==0; %whether the prediction is correct
        
%         %build confusion matrices
%         tempConf=zeros(2);
%         indxs = sub2ind(size(tempConf),testresp_st,cvN.(ROIs{e}){k,st}(1,:)); %Entries that have a 1 in confusion matrix
%         
%         avEnt = unique(indxs); valEnt = histc(indxs,avEnt); %Intermidiate strp to build confusion matrix
%         normC = histc(sort(testresp_st),unique(testresp_st)); %Normalization constants for each stimulus type (number of times each stimulus was used as a test trial)
%         tempConf(avEnt) = valEnt; %Add entries
%         tempConf = bsxfun(@times,tempConf,(1./normC)'); %Normalize
%         %             tempConf = tempConf(indx2,indx2); %rearrange
%         
%         confN{e,st}(:,:,k) = tempConf;
%         
%         %repeat for shuffled decoder
%         tempConf=zeros(2);
%          indxs = sub2ind(size(tempConf),testresp_st,cvNshuff.(ROIs{e}){k,st}(1,:)); %Entries that have a 1 in confusion matrix
%         
%         avEnt = unique(indxs); valEnt = histc(indxs,avEnt); %Intermidiate strp to build confusion matrix
%         normC = histc(sort(testresp_st),unique(testresp_st)); %Normalization constants for each stimulus type (number of times each stimulus was used as a test trial)
%         tempConf(avEnt) = valEnt; %Add entries
%         tempConf = bsxfun(@times,tempConf,(1./normC)'); %Normalize
%         %             tempConf = tempConf(indx2,indx2); %rearrange
%         
%         confNshuff{e,st}(:,:,k) = tempConf;
        end
        
       
    end
    %              tmp=mean(cat(3,confN{e,:}),3);
    %              figure; imagesc(tmp);
end
end
