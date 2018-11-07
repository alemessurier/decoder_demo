function RF_plot_2016v2( cellsToPlot,traceByStim,sampRate,framesEvoked )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% shapes={'.','*','o','+','^','s','x','d','p'};
whisk=fieldnames(traceByStim.(cellsToPlot{1}));
for i=1:length(cellsToPlot)
    f=figure; hold on
    f.Position=[8 678 1440 420];
   
     cn=cellsToPlot{i};
   f.Name=cn;
     subplot(1,3,1)
     sizeAll=cellfun(@(x)size(traceByStim.(cn).(x),1),whisk,'Uni',1);
    minSize=min(sizeAll);
cRow=horzcat(traceByStim.(cn).(whisk{9})(1:minSize,:),traceByStim.(cn).(whisk{8})(1:minSize,:),traceByStim.(cn).(whisk{7})(1:minSize,:));
dRow=horzcat(traceByStim.(cn).(whisk{6})(1:minSize,:),traceByStim.(cn).(whisk{5})(1:minSize,:),traceByStim.(cn).(whisk{4})(1:minSize,:));
eRow=horzcat(traceByStim.(cn).(whisk{3})(1:minSize,:),traceByStim.(cn).(whisk{2})(1:minSize,:),traceByStim.(cn).(whisk{1})(1:minSize,:));
allRows=vertcat(cRow,dRow,eRow);

imagesc(allRows);
colormap gray
vline([size(traceByStim.(cn).(whisk{1}),2) 2*size(traceByStim.(cn).(whisk{1}),2) ],{'w','w'})
hline([minSize 2*minSize],{'w','w'})
xtick=floor(size(allRows,2))/6;
ytick=floor(size(allRows,1))/6;
set(gca,'XTick',xtick:2*xtick:5*xtick)
set(gca,'XTickLabel',1:3,'FontWeight','bold')
set(gca,'YTick',ytick:2*ytick:5*ytick)
set(gca,'YTickLabel',{'C','D','E'},'FontWeight','bold')
axis square
    
    subplot(1,3,2)
    
    responseVec=cellfun(@(x)median(mean(traceByStim.(cn).(x)(:,framesEvoked),2)),whisk);
   
%     responseVec=cells.(cn).medianDF;
    responseMap=reshape(responseVec,[3 3])';
responseMap= [fliplr(responseMap(3,:));
    fliplr(responseMap(2,:));
    fliplr(responseMap(1,:));];

imagesc(responseMap)
colormap gray
set(gca,'XTick',[1:3]);
        set(gca,'XTickLabel',{'1' '2' '3'},'FontWeight','bold');
        set(gca,'YTick',[1:3]);
        set(gca,'YTickLabel',{'C' 'D' 'E'},'FontWeight','bold');
        set(gca,'LineWidth',2);
axis square

meanTraces=cellfun(@(x)median(traceByStim.(cn).(x),1),whisk,'Uni',0);
maxY=max(cellfun(@max,meanTraces));
minY=min(cellfun(@min,meanTraces));

subplot(1,3,3)
freezeColors
cmap=morgenstemning(size(meanTraces',2)+2);
set(gca,'ColorOrder',cmap);
hold all
time=(1:length(meanTraces{1}))/sampRate-0.5;
xlabel('time since stim (sec)')
ylabel('dF/F')
set(gca,'XLim',[time(1) time(end)])

h=cellfun(@(x)plot(time,x,'LineWidth',1.5),meanTraces,'Uni',0);
for i=1:length(h)
    set(h{i},'Marker','.')%shapes{i})
end

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
L=legend(whisk);
L.FontSize=10;
axis square
end

