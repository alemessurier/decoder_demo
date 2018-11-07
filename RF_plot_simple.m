function RF_plot_simple( cellsToPlot,traceByStim,sponTrace,sampRate,framesEvoked )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% shapes={'.','*','o','+','^','s','x','d','p'};

whisk=fieldnames(traceByStim.(cellsToPlot{1}));
for i=1:length(cellsToPlot)
    % make figure
    f=figure; hold on
    f.Position=[8 678 1440 420];
   
     cn=cellsToPlot{i};
   f.Name=cn;
    
    % find BW
    responseVec=cellfun(@(x)median(mean(traceByStim.(cn).(x)(:,framesEvoked),2)),whisk);
    [~,BWind]=max(responseVec);
    BW=whisk{BWind};
    
    
     subplot(1,3,1)
    minBW=min(min(traceByStim.(cn).(BW)));
    minBlank=min(min(sponTrace.(cn)));
    maxBW=max(max(traceByStim.(cn).(BW)));
    maxBlank=max(max(sponTrace.(cn)));
    gsLim(1)=min([minBW minBlank]);
    gsLim(2)=max([maxBW maxBlank]);
    imagesc(traceByStim.(cn).(BW),gsLim);
colormap gray

sampEnd=size(sponTrace.(cn),2);
time=(1:sampEnd)/sampRate-0.5;

% vline([size(traceByStim.(cn).(whisk{1}),2) 2*size(traceByStim.(cn).(whisk{1}),2) ],{'w','w'})
% hline([minSize 2*minSize],{'w','w'})
% xtick=floor(size(allRows,2))/6;
% ytick=floor(size(allRows,1))/6;
set(gca,'XTick',1:round(sampEnd/5):sampEnd)
set(gca,'XTickLabel',0:0.5:2.5,'FontWeight','bold')
xlabel('time from stimulus onset')
% set(gca,'YTick','none')
% set(gca,'YTickLabel',{'C','D','E'},'FontWeight','bold')
ylabel('trials')
axis square
    title('stim of Best Whisker')
 hbar=colorbar;
 hbar.Label.String='dF/F';    
 
    subplot(1,3,2)

imagesc(sponTrace.(cn),gsLim)
colormap gray
% set(gca,'XTick',[1:3]);
%         set(gca,'XTickLabel',{'1' '2' '3'},'FontWeight','bold');
%         set(gca,'YTick',[1:3]);
%         set(gca,'YTickLabel',{'C' 'D' 'E'},'FontWeight','bold');
%         set(gca,'LineWidth',2);
set(gca,'XTick',1:round(sampEnd/5):sampEnd)
set(gca,'XTickLabel',0:0.5:2.5,'FontWeight','bold')
xlabel('time from stimulus onset')
% set(gca,'YTick','none')
% set(gca,'YTickLabel',{'C','D','E'},'FontWeight','bold')
ylabel('trials')
axis square

title('baseline')
 hbar2=colorbar;
 hbar2.Label.String='dF/F';
meanTraceBW=median(traceByStim.(cn).(BW),1);
maxY=max(max(meanTraceBW));
minY=min(min(meanTraceBW));
meanBlank=median(sponTrace.(cn),1);

subplot(1,3,3)
freezeColors
% cmap=morgenstemning(size(meanTraceBW',2)+2);
% set(gca,'ColorOrder',cmap);
hold all
xlabel('time since stim onset(sec)')
ylabel('mean dF/F')
set(gca,'XLim',[time(1) time(end)])

% h=cellfun(@(x)plot(time,x,'LineWidth',1.5),meanTraces,'Uni',0);
h=plot(time,meanTraceBW,'r','LineWidth',1.5);
hold on
h2=plot(time,meanBlank,'k','LineWidth',1.5);

% for i=1:length(h)
%     set(h{i},'Marker','.')%shapes{i})
% end

p(1)=patch([0 0 0.05 0.05],[minY maxY maxY minY],'c');
p(5)=patch([0.1 0.1 0.15 0.15],[minY maxY maxY minY],'c');
p(2)=patch([0.2 0.2 0.25 0.25],[minY maxY maxY minY],'c');
p(3)=patch([0.3 0.3 0.35 0.35],[minY maxY maxY minY],'c');
p(4)=patch([0.4 0.4 0.45 0.45],[minY maxY maxY minY],'c');

% p.FaceColor='c';
for i=1:5
    p(i).EdgeColor='none';
    p(i).FaceAlpha=0.3;
end
L=legend('best whisker response','baseline');
L.FontSize=12;
axis square
end

