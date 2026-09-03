maindir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/06-FC/01-BASCO/cormat_v2/beta4D';

subfolder = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing');
mySubjects = {subfolder(contains({subfolder.name},'ZI_')).name};
mySelections = {'CD1-familiar','CD1-unknown','129-sv-female','C57Bl6-High','C57Bl6-Low'};

figure; 
for jx=1:length(mySelections)
    myValue{jx}.val=nan(22,700000);
    for ix=1:length(mySubjects)
        V=spm_vol(fullfile(maindir,[mySubjects{ix} '_betaseries_v2_' mySelections{jx} '.nii']));
        img=spm_read_vols(V);
        myValue{jx}.val(ix,1:length(img(~isnan(img))))=img(~isnan(img));
    end
    subplot(3,2,jx);
    boxplot(myValue{jx}.val');
    title(mySelections{jx});
end

