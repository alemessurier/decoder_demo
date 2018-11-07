function [ filtTrace ] = slidingAvg_rawF( rawTrace,ptsToAvg,type )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

filtTrace=zeros(1,length(rawTrace));

for t=(1+ptsToAvg):(length(filtTrace)-ptsToAvg)
    switch type
        case 'median'
            filtTrace(t)=median(rawTrace((t-ptsToAvg):(t+ptsToAvg)));
        case 'mean'
            filtTrace(t)=mean(rawTrace((t-ptsToAvg):(t+ptsToAvg)));
    end
end
end

