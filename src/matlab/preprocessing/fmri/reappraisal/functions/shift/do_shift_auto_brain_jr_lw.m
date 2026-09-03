function res=do_shift_auto_brain_jr_lw(P3d,Pfunc,Ptemp)

% shift image by world space difference to template
% get difference from brain extracted template and 3D (for data with high
% variation in FOV)

if nargin < 1
    P3d=spm_select(1, 'image', '3D-Data (non brain extracted)');
    Pfunc=spm_select(1, 'image', 'Functional data (1stimage)');
    Ptemp=spm_select(1, 'image', 'Template (brain extracted)');
end





[fdir fname1 ext]=fileparts(Pfunc);
Pf_simp=spm_select('FPlist',fdir,['^' fname1 '.nii']);
[fdir fname2 ext]=fileparts(Pf_simp);
Pfuncshift=[fdir filesep 'st_' fname2 '.nii'];

ppt_resave(Pf_simp,Pfuncshift);
[fdir fname3 ext]=fileparts(Pfuncshift);
Pfuncall=spm_select('ExtFPlist',fdir,['^' fname3],[1:2500]);

[fdir fname6 ext]=fileparts(P3d);
P3d_simp=[fdir filesep fname6 '.nii'];
P3dshift=[fdir filesep 'st_' fname6 '.nii'];
ppt_resave(P3d_simp,P3dshift);

P3dbx=[fdir filesep fname6 '_brain.nii'];
P3dbxshift=[fdir filesep 'st_' fname6 '_brain.nii'];
ppt_resave(P3dbx,P3dbxshift);

V3dbx=spm_vol(P3dbx);
mat3d=spm_read_vols(V3dbx);
[xv yv zv]=ind2sub(V3dbx.dim,find(mat3d));

%transform to mm space
xyzw=V3dbx.mat*[xv yv zv ones(length(xv),1)]';

% center of 3D in wrld space
xC2=mean([min(xyzw(1,:)),max(xyzw(1,:))]); % get midline position
yC2=min(xyzw(2,:)); % get posterior end
zC2=max(xyzw(3,:)); % get dorsal end

C2=[xC2 yC2 zC2 1]';


V=spm_vol(Ptemp);

mattmp=spm_read_vols(V);
[xv yv zv]=ind2sub(V.dim,find(mattmp));

%transform to mm space
xyzw=V.mat*[xv yv zv ones(length(xv),1)]';

% center of tmp in wrld space
xC1=mean([min(xyzw(1,:)),max(xyzw(1,:))]); % get midline position
yC1=min(xyzw(2,:)); % get posterior end
zC1=max(xyzw(3,:)); % get dorsal end

C1=[xC1 yC1 zC1 1]';

% translation vector
t=C1-C2;

M=spm_get_space(P3dshift);
spm_get_space(P3dshift,spm_matrix(t')*M);
M=spm_get_space(P3dbxshift);
spm_get_space(P3dbxshift,spm_matrix(t')*M);
for ix=1:size(Pfuncall,1)
    M=spm_get_space(Pfuncall(ix,:));
    spm_get_space(Pfuncall(ix,:),spm_matrix(t')*M);
end
