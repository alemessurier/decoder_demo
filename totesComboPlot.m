function [figName,ax] = totesComboPlot( dist_NH,var_NH,sem_NH,num_ROIs_NH,histVar_NH,dist_EN,var_EN,sem_EN,num_ROIs_EN,histVar_EN )
%TOTESCOMBOPLOT Plots NH and EN binned variable by distance, with righthand axis
%for number of ROIs per bin, plus vertical histogram 
%   INPUTs:     dist_NH/dist_EN:    distance from barrel center (or
%                                   pairwise distance)
%           
%               var_NH/var_EN:      variable binned by distances in first
%                                   input
%       
%               sem_NH/sem_EN:      standard error for var_NH/EN
%           
%               num_ROIs_EN/NH:     number of ROIs per bin

%% 
figName=figure;

% make right-handed plot for numROIs/distance bin
ax(1)=axes('XAxisLocation','bottom',...
    'YAxisLocation','right',...
    'Color','none',...
     'Position',[0.15    0.15    0.7    0.7]);
hold on
plot(dist_NH,num_ROIs_NH,'k:');
plot(dist_EN,num_ROIs_EN,'r:');

ylabel('# ROIs')


% make left-handed plot for var/distance

position=ax(1).Position;
ax(2) = axes('Position',position,...
    'Color','none');
ax(2).XLim=ax(1).XLim;
hold on

exc_NH=isnan(dist_NH) | isnan(var_NH) | isnan(sem_NH);
dist_NH=dist_NH(~exc_NH);
var_NH=var_NH(~exc_NH);
sem_NH=sem_NH(~exc_NH);

exc_EN=isnan(dist_EN) | isnan(var_EN) | isnan(sem_EN)
dist_EN=dist_EN(~exc_EN);
var_EN=var_EN(~exc_EN);
sem_EN=sem_EN(~exc_EN);


[hl,hp]=boundedline(dist_NH,var_NH,sem_NH,'ko-',dist_EN,var_EN,sem_EN,'ro-','alpha')

hp_info=get(hp);
hp_ingo(1).Annotation.LegendInformation.IconDisplayStyle='off';
hp_ingo(2).Annotation.LegendInformation.IconDisplayStyle='off';
legend('NH','EN')
ax(1).XTickLabel=[];
 linkaxes(ax,'x')
 
% make rotated histogram of NC as separate plot

% ax(3)=axes('Position',[0.05    0.1191    0.0653    0.8059],...
%     'Units','normalized');
%  binMin=ax(2).YLim(1);
%  binMax=ax(2).YLim(2);
%  binEdges=binMin:(binMax-binMin)/20:binMax;
%  
%  histCW_NH=histc(histVar_NH,binEdges);
%  histCW_NH=histCW_NH/sum(histCW_NH);
%  histCW_EN=histc(histVar_EN,binEdges);
% histCW_EN=histCW_EN/sum(histCW_EN);
%  handlebar_NH=barh(binEdges,histCW_NH);
% handlebar_NH.FaceColor='none';
% handlebar_NH.EdgeColor='k';
% handlebar_NH.LineWidth=1.5;
% hold on
% handlebar_EN=barh(binEdges,histCW_EN);
% handlebar_EN.FaceColor='none';
% handlebar_EN.EdgeColor='r';
% handlebar_EN.LineWidth=1.5;
% ax(3)=gca;
% ax(3).XDir='reverse';
% ax(3).YLim=ax(2).YLim;
% ax(3).YTick=[];
% ax(3).XLim=[0 max([histCW_NH,histCW_EN])];
% ax(3).XTick=[0 max([histCW_NH,histCW_EN])];
% ax(3).XTickLabel=[0 max([histCW_NH,histCW_EN])];
% ax(3).YAxisLocation='right';
% ax(3).Box='off';
end

