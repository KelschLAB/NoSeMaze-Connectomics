% The FieldMap is saved as acq0_reorient.nii file in the FieldMap
% directory.
% This file is just loading the fieldmap into the
% fpm_...acq0_reorient.nii  fpm_..._acq0_reorient_spm2.hdr  fpm_.._acq0_reorient_spm2.img  fpm_..._acq0_reorient_spm2.mat
% ??? WHY SO MANY DIFFERENT FILES ???
% file.

function res=wwf_FieldMap_rat_jr(Pdir)
start=pwd;
if nargin < 1
    Pdir=spm_select(inf, 'dir', 'Field-Map Ordner waehlen');
end

for i=1:size(Pdir,1)
    Pcur=deblank(Pdir(i,:));
    %cd(start)
    %cd(deblank(Pdir(i,:)))
    fieldmap=spm_select('FPlist',Pcur,['^Z.*acq0_reorient.nii$']) %%% acq0_reorient.nii is the FieldMap" 
    %sysprom=['find $(pwd) -name "RS*acq0_reorient.nii" '];
    %[~,fieldmap]=system(sysprom)
    if size(fieldmap,1) > 1; % get rid of old fpm...acq0 images found
        for ix=1:size(fieldmap,1);
            fpcur=deblank(fieldmap(ix,:))
                if isempty(strfind('fpm',fpcur));
                    fieldmap=fpcur;
                    break;
                end
        end
    end
            
    [path, name, ext]=fileparts(fieldmap);
    
    if exist(fullfile(path,['fpm' name ext]));
        delete(fullfile(path,['fpm' name ext]))    
    end 
    newfieldmap=fullfile(path,['fpm_' name ext]);
    oldfieldmap=(fieldmap);
    newfieldmap=(fullfile(path, ['fpm_' name, ext]));
    %cd(path)
    ppt_resave(deblank(oldfieldmap), deblank(newfieldmap));  %%%% JR: Unzips or Resaves the image file:
    %%%  JR: FORMAT zi_resave( inputFile, outputFile )
  
    % newfieldmap=fullfile(path,['fpm_' name ext]);
    
%     sysprom=['find $(pwd) -name "*.brkhdr" '];
%     [~,brkhdr]=system(sysprom);    
%     brkhdr=deblank(brkhdr);(
%     
%     fid=fopen(brkhdr);
%     found=0;
%     sl_str='##$RECO_map_slope';
%      while ~found
%           line=fgetl(fid);
%           if strmatch(sl_str,line), found=1;end
%      end
%     line=fgetl(fid);  
%     fclose(fid);
%     loc=strfind(line, ' ');
%     val=str2double(line(1:loc(1)))
    brkhdr=spm_select('FPlist',Pdir,['^Z.*.brkhdr']); 
    hdr=readBrukerParamFile(brkhdr); %% JR changed readBrukerParamFile to ReadBrukerParamFile: Reads Bruker JCAMP parameter files in --> hdr is a structure file containing the information of the header
    val=hdr.RECO_map_slope(1); %%% JR: defining val as the parameter of the struct-array in hdr --> RECO_map_slope (what is it?) 
    V=spm_vol(newfieldmap); %%% JR: get header information for images --> V is a 1x1 structarray 
   % V.dt=[16 0];
   %V.pinfo(1)=1;
    imtx=spm_read_vols(V); %%% JR: Read in entire image volumes --> imtx is a 64x64x64 double
    spm_write_vol(V,imtx/val); %%% JR:   Write an image volume to disk, setting scales and offsets as appropriate
    %   FORMAT V = spm_write_vol(V,Y) V (input)  - a structure containing
    %   image volume information (see spm_vol) Y - a one, two or three dimensional matrix containing the image voxels
    nii2ana(newfieldmap)
end
cd(start)
