function coolfieldmap=fieldmap_fill_2(Pfmdir)

% fill the voxels without a signal in fieldmap with the value of the nearest
% voxel with signal
%
%input: dir, where fieldmap is
%
%output: filled fieldmap in same dir
%

if nargin < 1
    Pfmdir=spm_select(inf, 'dir', 'Select fieldmap dir');
end

spm2_fm=spm_select( 'ExtFPlist',Pfmdir,'^fpm_.*spm2.img');
V=spm_vol(spm2_fm);
imgmat=spm_read_vols(V);

si=size(imgmat)
%maxid=sub2ind(si, si(1), si(2), si(3))

maxid=si(1)*si(2)*si(3)  %total number of elements for lin indexing


ind1=find(imgmat);              %indices of nonzero elements
maskmat=zeros(size(imgmat),'int8');
maskmat(ind1)=1;                %mask of existing field map


bord=zeros(size(imgmat),'int8');

[j1, j2, j3]=ind2sub(size(imgmat),ind1);

jmat=[j1, j2, j3];          %subscript indices of nonzero elements

%save jmat

%neighborpositions for every voxel not= 0 in original fieldmap

for j=1:length(ind1)
    kmat=zeros(3,3,'int8');
    for d = 1:3    %3 dimensoins                                 
         
        for k = -1:1     %3 voxels per dimension                       
            
            if jmat(j,d)+k == 0         %"left" border in any direction
                kmat(k+2,d)=maskmat(j);
            elseif jmat(j,d)+k > size(imgmat,d)     %"right" border in any direction
                kmat(k+2,d)=maskmat(j);
            else
                indkd=jmat(j,:);
                indkd(d)=indkd(d)+k;
                %save indkd
                ka=k+2;
                kmat(ka,d)=maskmat(indkd(1),indkd(2),indkd(3));
            end
        end
    end 
    
    
     if all(all(kmat)) == 0              % at least one neigbour-voxel is = 0
         
         bord(ind1(j))=1 ;             
      
     else
         bord(ind1(j))=0 ;                 %border-matrix with 1 for voxels on the border of original field map
     end
 
     %display(j/length(ind1))
     
end    


fm_corr=zeros(size(imgmat),'int16');

for j=1:length(ind1)
    
    fm_corr(ind1(j))=imgmat(ind1(j));           %copy value from original fieldmap for non-zero voxels 
end




indb=find(bord);            %vector of border-indices
[bcoor(:,1), bcoor(:,2), bcoor(:,3)]=ind2sub(size(imgmat),indb);

indz=find(maskmat==0);      %vector of indices of zeros
[zcoor(:,1), zcoor(:,2), zcoor(:,3)]=ind2sub(size(imgmat),indz);
dist=zeros(length(indb),length(indz),'int16');


for i=1:length(indb)
    
    bc1=repmat(bcoor(i,:),size(zcoor,1),1);
   
    diff=zcoor-bc1;

    dist(i,:)=sum(diff.^2,2);
    %display(i)
end    

[minval,minind]=min(dist);

for j=1:length(indz)

    fm_corr(indz(j))=imgmat(indb(minind(j)));
end    

%save fm_corr

oldmap=V.fname;
[vpath vname ext]=fileparts(oldmap);
newmap=fullfile(vpath, [vname(1:4), 'full_', vname(5:end), ext]);

Vout=V;
Vout.fname=newmap;

spm_write_vol(Vout,fm_corr)
%nii2ana(newmap)
 
        