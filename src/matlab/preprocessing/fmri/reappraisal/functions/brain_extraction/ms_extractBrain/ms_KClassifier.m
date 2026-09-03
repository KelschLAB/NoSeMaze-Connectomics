%% visit https://de.mathworks.com/help/stats/fitcknn.html
% maybe it helps to store the Mtx data in another format; unit8?

P=spm_select(inf, 'any', 'Select anatomical images',{},[],'.*_reorient.nii');

Pmask=spm_select(inf, 'any', 'Select brain masks',{},[],'.*_brainmask.nii');

flag.process ='Mtx=reshape(histeq(Mtx(:)./max(Mtx(:))),size(Mtx)); Mtx=Mtx*3000;';
flag.P=P;
flag.mask=Pmask;
flag.imgsize=[32 32 32]; % 64 64 32 is a bad idea!!
%%
for ix=1:size(P,1)
    V=spm_vol(deblank(P(ix,:)));
    Mtx=spm_read_vols(V);
    eval(flag.process);
    Mtx = imresize3(Mtx, flag.imgsize, 'nearest');
    Vmask=spm_vol(deblank(Pmask(ix,:)));
    mask=spm_read_vols(Vmask);
    mask = imresize3(mask, flag.imgsize, 'nearest');
    %% for the classifier we would like to have location and intensity
    [x,y,z]=ind2sub(size(Mtx),1:length(Mtx(:)));
    pts=[x',y',z',Mtx(:)];
    Y=cell(1,length(Mtx(:)));
    Y(find(mask))={'brain'}; Y(find(~mask))={'background'};
    %% remove some of the background cases to have a better ratio
    di = sum(~mask(:)) - sum(mask(:));
    idx=find(contains(Y,'background')); rem = randperm(length(idx), floor(di*0.8));
    Y(idx(rem))=[]; pts(idx(rem),:)=[];
    fprintf('relation background/brain: %.0f / %.0f\n', sum(contains(Y,'background')), sum(contains(Y,'brain')))
    %% store them temp
    tempY{ix}=Y; temppts{ix}=pts;
end
%% put the data back together
Y=[tempY{:}]; pts=[]; for ix=1:length(temppts); pts=vertcat(pts,temppts{ix}); end; 
pts=single(pts);
%% create the model
% if you want matlab to search for the best model
% Mdl = fitcknn(pts,Y,'OptimizeHyperparameters','auto',...
% 'HyperparameterOptimizationOptions',...
% struct('AcquisitionFunctionName','expected-improvement-plus'),'Standardize',1)
% % variations
Mdl = fitcknn(pts,Y,'OptimizeHyperparameters','auto',...
'HyperparameterOptimizationOptions',...
struct('AcquisitionFunctionName','expected-improvement-per-second-plus'),'Standardize',1)

Mdl.Prior
%%

d=fileparts(which('ms_KClassifier'));
save([d filesep 'Mdl64.mat'], 'Mdl', 'flag')
