function [cells,traceByStim,sponTrace,framesEvoked,permTestResults,...
    dists,ROIsInBarrel,ROItoBarrel,ROI_positions,Stimuli,deltaF,sampRate,whiskPref,mag,imfield_mask,barrelmasks ] = load_NPsub_data( pathName )

cd(pathName);

fname_s1=dir('step1NPcorr*');
load(strcat(pathName,fname_s1(end).name));
ROIf=dir('ROI_positions_*');
if isempty(ROIf)
    load([pathName,'ROI_positions.mat'])
else
     load(strcat(pathName,ROIf.name));
end
bname=dir('barrel_data_*');
load(strcat(pathName,bname(end).name));
% load([pathName,'dist_analysis_NPsub.mat']);
dists=nan;
tmp=dir('whiskPref_0*');
if isempty(tmp)
    whiskPref=[];
else
    load([pathName,tmp.name]);
end
cd(pathName);
name=dir('analysisTemplate*');
filecont=fileread(strcat(pathName,name.name));
expr = '[^\n]*mag=[^\n]*';
dp_string = regexp(filecont,expr,'match');
eval(dp_string{:});
cells=[];
end

