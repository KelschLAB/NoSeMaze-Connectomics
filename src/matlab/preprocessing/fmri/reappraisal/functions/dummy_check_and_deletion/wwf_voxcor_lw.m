function res=wwf_voxcor_lw(Pall,outname,TR)
if nargin < 1
    Pall=spm_select(inf,'image','Select only first Image of Time Series');
end
if nargin < 2
    outname=('cor_hist');
end
if nargin <3
    TR=1.3;
end
nsub=size(Pall,1);
fout=fopen([outname '.csv'],'w+t');
fprintf(fout,'Name, mean, sd\n')
for n=1:nsub
    Pcur=deblank(Pall(n,:));
    [fpath fname ext]=fileparts(Pcur);
    P=spm_select('ExtFPList',fpath,['^' fname '.nii'],[1:2500]);  %LW: 1500
    nimg=size(P,1);
    fprintf(1,'%s; %d images\n',fname,nimg);
    %keyboard;
    immtx=spm_read_vols(spm_vol(P));
    im1=squeeze(immtx(:,:,:,1));
    imtx2=reshape(immtx,[prod(size(im1)),size(immtx,4)]);
    fprintf(1,' Timecourses: %d\n',size(imtx2,1));
    zvec=find(im1>500); 
    imtx3=imtx2(zvec,:);
    fprintf(1,' Timecourses Thresholded: %d\n',size(imtx3,1));
    clear imtx2;
    rv=rand(size(imtx3,1) ,1);
    imtx3=imtx3(rv>0.5,:);
    fprintf(1,' Timecourses random: %d\n',size(imtx3,1));
    cmat=corrcoef(imtx3');
    %figure(5);imagesc(cmat,[-1 1]);colorbar
    cm2=tril(cmat,-1);
    meantime=mean(imtx3);
    clear immtx im1 imtx2 imtx3 zvec
    cm3=cmat(find(cm2));
    clear cmat cm2 
    %figure(9);hist(cm3,300);xlim([-.6,.6]);
    [y x]=hist(cm3,600);
    na= length( x );
    x = reshape( x, na, 1 );
    y = reshape( y, na, 1 );
    dx=diff(x);
    dy = 0.5*(y(1:length(y)-1) + y(2:length(y)));
    summe=sum(dx.*dy);
    y = y ./ summe;
    [c_sigma(n) c_mu(n)]=gaussfit(x,y);
    Y = 1/(sqrt(2*pi)*c_sigma(n))*exp( -(x - c_mu(n)).^2 / (2*c_sigma(n)^2));
    figure(9);plot(x,y,'.');xlim([-.6,.6]);hold on;plot(x,Y,'r', 'LineWidth',2);
    hold off
    maxy=max(y);
    text(0.2,maxy*0.75,['mean=' num2str(c_mu(n))]);
    title(strrep(fname,'_','\_'));
    outsing=[fname '_hist.fig'];
    saveas(9,outsing,'fig');
    outsing=[fname '_hist.jpg'];
    saveas(9,outsing,'jpg');
    figure(10);subplot(3,2,mod(n-1,6)+1);plot(x,y,'.');xlim([-.6,.6]);hold on;plot(x,Y,'r', 'LineWidth',2);
    hold off
    xlabel(['mean=' num2str(c_mu(n))]);
    title(strrep(fname,'_','\_'));
    if (mod(n-1,6)+1)==6
        print(10,'-dpsc2','-append',[outname '.ps']);
        saveas(10, [outname num2str(n) '.fig'],'fig');
    end
    fprintf(fout,'%s, %8.7f, %8.7f \n',fname,c_mu(n),c_sigma(n));
    y=meantime;
    figure(25);
    subplot(2,1,1);plot(y,'o-'); xlabel( strrep(Pcur,'_','\_'));
    timeFreq=1/TR;
    ff = 0:timeFreq / (length( y ) - 1):timeFreq;
    DataFFT = abs( fft( y ) );
    subplot(2,1,2);plot( ff(2:end), DataFFT(2:end), 'k' )      
    axis tight
    xlim([0 0.4]); xlabel(sprintf('Freq [Hz] when TR=%3.2f s',TR));
    print(25,'-dpsc2','-append',[outname '_meantime.ps'],'-bestfit')
end
fclose(fout);
res.mean=c_mu;
res.sigma=c_sigma;
%saveas(10,'hist_all.fig','fig');
saveas(10, [outname num2str(n) '.fig'],'fig');
print(10,'-dpsc2','-append',[outname '.ps'])





