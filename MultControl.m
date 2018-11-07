function significance = MultControl(pVals,alpha,varargin)
%Control for multiple comparisons
%User has the option to control for familywise error rate (FWR) or false
%discovery rate (FDR). 
%pValues is the array of p-values that correspond to the various hypotheses
%being tested
%alpha is the significance value (usually .05)
%User has an option to indicate whether he/she whishes to control for 'FWR'
%or 'FDR'
%'FDR' is less rigorous than 'FWR' but it is widely used by many
%statisticians. Check Benjamini-Hochberg False Discovery Rate procedure
%%
%p-values are not in a row vector
if(~isrow(pVals))
    pVals = pVals';
    rw = false; 
else
    rw = true;
end
%check optional inputs
if(nargin==2)
    err2cnt = 'FWR'; %The function's default behavior is to control for the FWR in the strong sense
elseif(nargin==3)
    err2cnt = varargin{1};
else
    error('Too many input arguments')
end
if(strcmp(err2cnt,'FDR')) %User wants to control false discovery rate
    %Benjamini-Hochberg's FDR control
    %Initial calculations
    n = length(pVals); %Number of hypotheses being tested
    [pVals,indx] = sort(pVals,'descend'); %Sorted pvalues in descending order
    nwI = zeros(1,length(pVals)); nwI(indx) = 1:length(pVals); %Used to resort back into original order
    %Do procedure
    adjH = (n:-1:1)./n; adjH = alpha.*adjH; %Adjusted significance values to control for false discovery rate
    sig = pVals-adjH;
    lm = find(sig<=0,1); %Find first index where the significance criterion is met
    if(isempty(lm)) %No significant deviations were met
        significance = false(size(pVals)); 
    elseif(lm==1) %All hypotheses were rejected
        significance = true(size(pVals)); 
    else %Only a subset of hypotheses were rejected
        significance = [false(1,(lm-1)),true(1,(n-lm+1))];
        significance = significance(nwI);
    end
else %User wants to control for FWR
    %Holm's method 1979
    %Initial calculations
    n = length(pVals); %Number of hypotheses being tested
    [pVals,indx] = sort(pVals); %Sorted pvalues in ascending order
    nwI = zeros(1,length(pVals)); nwI(indx) = 1:length(pVals); %Used to resort back into original order
    %Do procedure
    adjH = fliplr(1./(1:n)); adjH = adjH.*alpha; %Adjusted significant values
    sig = pVals-adjH;
    lm = find(sig<=0); %Significance criterion is met 
    if(isempty(lm) || min(lm~=1))%No significant deviations
        significance = false(size(pVals));
    elseif(length(lm)==length(pVals))%All null hypotheses were rejected
        significance = true(size(pVals)); 
    else %Only a subset of hypotheses were rejected
        cnt = diff(lm); dcnt = find(cnt>1,1); %Find the first index were the significance criterion was not reached
        significance = [true(1,dcnt),false(1,(n-dcnt))];
        significance = significance(nwI); %Resort
    end
end
%%%%%%%%
if(~rw)
    significance = significance';
end
%%%%%%%%%

end

