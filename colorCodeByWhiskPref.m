function colorCodeByWhiskPref( pathName )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[~,traceByStim,sponTrace,framesEvoked,permTestResults,...
    ~,~,~,ROI_positions,~,~,~,~,~,imfield_mask,barrelmasks ] = load_NPsub_data( pathName);

% load in values from template
name=dir('analysisTemplate*');
filecont=fileread(strcat(pathName,name.name));
expr = '[^\n]*dir_processed=[^\n]*';
dp_string = regexp(filecont,expr,'match');
eval(dp_string{:});


barrels=fieldnames(barrelmasks);
cmap=ametrine(length(barrels));
% cmap=brewermap(9,'Set2');
figure; hold on
% for r=1:3
    r=1;
    sigROIs=find_sigROIs(permTestResults(r),traceByStim(r));
    
    BWs=zeros(1,length(sigROIs));
    
    
    for i=1:length(sigROIs)
        responses=cellfun(@(x)median(mean(traceByStim(r).(sigROIs{i}).(x)(:,framesEvoked),2)),barrels,'Uni',1);
        [~,BWs(i)]=max(responses);
    end
    
    
    
    
%     subplot(1,3,r)
    [~,hbar]=colorCodeROIs(ROI_positions,sigROIs,dir_processed,'scale_var',...
        BWs,'numBins',9,'cmap',cmap,'cmapBounds',[1 9],'barrelmasks',...
        barrelmasks,'imfield_mask',imfield_mask )
    hbar.Ticks=0.05:0.11:0.93;
    hbar.TickLabels=barrels;
% end
end

