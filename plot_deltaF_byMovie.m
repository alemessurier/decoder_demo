function  plot_deltaF_byMovie( cellsToPlot,deltaF,sampRate,Stimuli,stims,spacing,ptsToAvg )


%% plot all traces
fns=fieldnames(Stimuli);
for j=1:length(fns)
    g= figure;
    
    fn=fns{j};
    for i=1:length(cellsToPlot)
        
        cn = cellsToPlot{i};
        
        samp_rate=sampRate(j);
        time = [1:length(deltaF.(fn).(cn))]/samp_rate;
        trace=deltaF.(fn).(cn);
        [ filtTrace ] = slidingAvg_rawF( trace,ptsToAvg,'median' );
        plot(1:length(deltaF.(fn).(cn)), filtTrace+((i-1)*spacing),'k');
        hold on
    end
    ylabel('Fluorescence (AU)'); xlabel('Time (seconds)');
    axis([1 length(deltaF.(fn).(cn)) 0 (length(cellsToPlot)*spacing)]);
    %      scrollplot(200, 1:length(deltaF.(fn).(cn)), deltaF.(fn).(cn));
    
    if ~isempty(Stimuli)
        stimFrames=(Stimuli.(fns{j}).Time*sampRate(5))+1;
        stimFrames=stimFrames(stimFrames>0);
        labels=cat(2,stims(Stimuli.(fns{j}).Label+1));
        labels=labels(1:length(stimFrames));
        
        vline(stimFrames,repmat({'r:'},1,length(stimFrames)),labels);
    end
    set(gca,'YTick',[0:spacing:((length(cellsToPlot)*spacing))])
    set(gca,'YTickLabel',cellsToPlot)
    
end


end

