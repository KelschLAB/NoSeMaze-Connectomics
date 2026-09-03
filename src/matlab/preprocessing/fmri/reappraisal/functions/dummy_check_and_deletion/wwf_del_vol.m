function res=wwf_del_vol(Pall,ndel)  %%% definition of the function: our case --> Pdo is Pall, ndel number to delete is 4
if nargin < 1 %%% nargin = number of input arguments of the function
    Pall=spm_select(inf,'image','Select only first Image of Time Series');
end
if nargin < 2 %%% if ndel unspecified, ndel=4
    ndel=4;
end
nsub=size(Pall,1);
for n=1:nsub
    Pcur=deblank(Pall(n,:));
    [fpath fname ext]=fileparts(Pcur);
    outname=[fpath filesep 'del' num2str(ndel) '_' fname '.nii'];  %%% how to save the result
    P=spm_select('ExtFPList',fpath,['^' fname '.nii'],[1:3000]); 
    nimg=size(P,1); %% definition of number of images
    fprintf(1,'%s; %d images\n',fname,nimg);  %%%% write data to text file and print it on the screen: %s --> fname; %d --> nimg \n --> new line; 
    Vi=spm_vol(P); %%% spm_vol get header information for images loaded into matlab
    count=1;
    for ix=ndel+1:length(Vi);     %%% for all images from ndel+1 (5) to 360 
        Vo(count)=Vi(ix);   %%%% i.e. Vo(1)=Vi(5) Vo --> output Vi --> input
        Vo(count).fname=outname;  %%%%outputname is changed (del4_ prefix) --> see above
        Vo(count).n(1)=count; %%%% output count is changed
        spm_write_vol(Vo(count),spm_read_vols(Vi(ix))); %%Write an image volume to disk, setting scales and offsets as appropriate
 %FORMAT V = spm_write_vol(V,Y)
 %V (input)  - a structure containing image volume information (see spm_vol)
 %Y          - a one, two or three dimensional matrix containing the image voxels
 %V (output) - data structure after modification for writing
 
 % spm_read_vols – for reading entire volumes (see also: spm_vol)
         count=count+1;
    end
end
   
res=outname;