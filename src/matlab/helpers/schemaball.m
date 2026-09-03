function gcf=schemaball(strNames, corrMatrix, fontsize,lim,clrstr,clrMatrix)
%% SCHEMABALL(strNames, corrMatrix, fontsize, positive_color_hs, negative_color_hs, theta)
%	inspired by http://mkweb.bcgsc.ca/schemaball
%	discussion at http://stackoverflow.com/questions/17038377
%
%	Draws a circular represenation of a correlation matrix.
%	Use no input arguments for a demo.
%
%INPUT ARGUMENTS
%	strNames	The names of variables of the correlation matrix
%				Format: Mx1 cell array of strings
%	corrMatrix	Correlation matrix (MxM)
%OPTIONAL:
%	fontsize	Font size of the labels along the edge
%				Default: 30/exp(M/30)
%	positive_color_hs:
%				The hue and saturation of the connection lines for
%				variables with a positive correlation.
%	negative_color_hs:
%				The hue and saturation of the connection lines for
%				variables with a negative correlation.
%	theta		Mx1 vector of angles at which the labels and connector
%				lines must be placed. If not supplied, they are evenly
%				distributed along the whole edge of the circle.
%

if nargin==0 % DEMO
    strNames = {'Lorem','ipsum','dolor','sit','amet','consectetur', ...
        'adipisicing','elit','sed','do','eiusmod','tempor','incididunt',...
        'ut','labore','et','dolore','magna','aliqua'};
    
    % generate random symmetric matrix:
    a=rand(numel(strNames));
    corrMatrix=triu(a) + triu(a,1)';
    corrMatrix = 2*corrMatrix-max(corrMatrix(:));
    corrMatrix = corrMatrix.^5;
else
    narginchk(2,6);
end
%% Check input arguments
M = numel(strNames);
if ndims(corrMatrix)~=2 || size(corrMatrix,1)~=size(corrMatrix,2) || length(corrMatrix)~=M
    error('SchemaBall:InvalidInputArguments','Invalid size of ''corrMatrix''');
end
if nargin<3
    fontsize = 30/exp(M/30);
end
% 	if nargin<4
% 		theta = linspace(0,2*pi,M+1);
% 		theta(end)=[];
% 	elseif ~all(size(theta)==size(strNames))
% 		error('SchemaBall:InvalidInputArguments','Invalid size of ''theta''');
%     end
if nargin<4 | isempty(lim)
    lim(1)=min(abs(corrMatrix(abs(corrMatrix)>0)));
    lim(2)=max(abs(corrMatrix(:)));
end
if nargin<5
    clrstr=repmat([.5 .5 .5],M,1);
end
if size(clrstr,1)==1
    clrstr=repmat(clrstr,M,1);
end

if nargin<6
    vals=linspace(lim(1),lim(2),100);
    
    %     if min(corrMatrix(abs(corrMatrix)>0))<0
    %         [cmap]=flipud(cbrewer('div','RdBu',201));
    %         cbarpos=cmap(102:201,:);
    %         cbarneg=flipud(cmap(1:100,:));
    %     else
    %         [cmap]=cbrewer('seq','RdPu',100);
    %         cbarpos=cmap;
    %     end
    %     cbarpos=autumn(100);
    %     cbarneg=winter(100);
    jetbar=jet(200);
    cbarpos=jetbar(101:200,:);
    cbarneg=jetbar([1:100],:);
    
    %    theta=[fliplr(linspace(-pi/2+.1,pi/2-.1,M/2)) fliplr(-pi/2-linspace(.1,pi-.1,M/2))];
    theta=[linspace(0,2*pi,M+1)];theta=theta(1:end-1);
    
    
    
    %% Configuration
    R = 1;
    Nbezier = 100;
    bezierR = 0.1;
    markerR = 0.025;
    labelR = 1.05;
    
    %% Create figure with invisible axes, just black background
    %     figure;
    %('Renderer','zbuffer');
    hold on
    set(gca,'color','white','XTick',[],'YTick',[]);
    %set(gca,'position',[0 0 1 1],'xlim',2*[-1 1]*R,'ylim',2*[-1 1]*R);
    set(gca,'xlim',[-1.3 1.3]*R,'ylim',[-1.3 1.3]*R,'box','off');
    axis equal
    
    %% draw diagonals
    % if you draw the brightest lines first and then the darker lines, the
    % latter will cut through the former and make it look like they have
    % holes. Therefore, sort and draw them in order (darkest first).
    idx = nonzeros(triu(reshape(1:M^2,M,M),1));
    [~,sort_idx]=sort(abs(corrMatrix(idx)));
    idx = idx(sort_idx);
    
    [Px,Py] = pol2cart(theta,R);
    P = [Px ;Py];
    
    %     for ii=idx'
    %         [jj,kk]=ind2sub([M M],ii);
    %         [P1x,P1y] = pol2cart((theta(jj)+theta(kk))/2,bezierR);
    %         Bt = getQuadBezier(P(:,jj),[P1x;P1y],P(:,kk), Nbezier);
    %         if corrMatrix(jj,kk)>0
    %             clr = cbarpos(find(vals>=corrMatrix(jj,kk),1),:);
    %             if isempty(clr)
    %                 clr = cbarpos(end,:);
    %             end
    %         elseif corrMatrix(jj,kk)<0
    %             clr = cbarneg(find(vals>=corrMatrix(jj,kk),1),:);
    %             if isempty(clr)
    %                 clr = cbarneg(end,:);
    %             end
    %         else
    %             clr = [.8 .8 .8];
    %         end
    %         plot(Bt(:,1),Bt(:,2),'color',clr,'Linewidth',2);%,'LineSmoothing','on');
    %     end
    
    for ii=idx'
        [jj,kk]=ind2sub([M M],ii);
        [P1x,P1y] = pol2cart((theta(jj)+theta(kk))/2,bezierR);
        Bt = getQuadBezier(P(:,jj),[P1x;P1y],P(:,kk), Nbezier);
        jj
        kk
        if corrMatrix(jj,kk)>0
            clr = cbarpos(find(vals>=corrMatrix(jj,kk),1),:);
            if isempty(clr)
                clr = cbarpos(end,:);
            end
            plot(Bt(:,1),Bt(:,2),'color',clr,'Linewidth',2);%,'LineSmoothing','on');
        elseif corrMatrix(jj,kk)<0
            clr = cbarneg(find(vals>=-corrMatrix(jj,kk),1),:);
            if isempty(clr)
                clr = cbarneg(end,:);
            end
            plot(Bt(:,1),Bt(:,2),'color',clr,'Linewidth',2);%,'LineSmoothing','on');
        else
            clr = [.8 .8 .8];
        end
        
    end
    
    %% draw edge markers
    [Px,Py] = pol2cart(theta,R+markerR);
    % base the color of the node on the 'degree of correlation' with other
    % variables:
    corrMatrix(logical(eye(M)))=0;
    V = mean(abs(corrMatrix),2);
    V=V./max(V);
    
    clr = hsv2rgb([ones(M,1)*[0.585 0.5765] V(:)]);
    diftheta=unique(quant(diff(linspace(-pi/2+.1,pi/2-.1,M/2)),0.001));
    %scatter(Px,Py,20,clr);%,'filled'); % non-filled looks better imho
    for ii=1:M
        
        dthe=linspace(theta(ii)-.25*diftheta,theta(ii)+.4*diftheta,100);
        [Px,Py] = pol2cart(dthe,R+markerR);
        
        plot(Px,Py,'color',clrstr(ii,:),'linewidth',10);
        % 		rectangle('Curvature',[1 1],'edgeColor',clr(ii,:),...
        % 			'Position',[Px(ii)-markerR Py(ii)-markerR 2*markerR*[1 1]]);
    end
else
    
    
    %% SORTING AND POSITIONING OF THE EDGES
%    theta=[fliplr(linspace(-pi/2+.1,pi/2-.1,M/2)) fliplr(-pi/2-linspace(.1,pi-.1,M/2))];
    theta=[linspace(0,2*pi,M+1)];theta=theta(1:end-1);
    
    
    %% Configuration
    R = 1;
    Nbezier = 100;
    bezierR = 0.1;
    markerR = 0.025;
    labelR = 1.05;
    
    %% Create figure with invisible axes, just black background
    %     figure;
    %('Renderer','zbuffer');
    hold on
    set(gca,'color','white','XTick',[],'YTick',[]);
    %set(gca,'position',[0 0 1 1],'xlim',2*[-1 1]*R,'ylim',2*[-1 1]*R);
    set(gca,'xlim',[-1.3 1.3]*R,'ylim',[-1.3 1.3]*R,'box','off');
    axis equal
    
    %% draw diagonals
    % if you draw the brightest lines first and then the darker lines, the
    % latter will cut through the former and make it look like they have
    % holes. Therefore, sort and draw them in order (darkest first).
    idx = nonzeros(triu(reshape(1:M^2,M,M),1));
    [~,sort_idx]=sort(abs(corrMatrix(idx)));
    idx = idx(sort_idx);
    
    [Px,Py] = pol2cart(theta,R);
    P = [Px ;Py];
    
    for ii=idx'
        [jj,kk]=ind2sub([M M],ii);
        if corrMatrix(jj,kk)~=0
            [P1x,P1y] = pol2cart((theta(jj)+theta(kk))/2,bezierR);
            Bt = getQuadBezier(P(:,jj),[P1x;P1y],P(:,kk), Nbezier);
            
            clr = squeeze(clrMatrix(jj,kk,:));
            plot(Bt(:,1),Bt(:,2),'color',clr,'Linewidth',2);%,'LineSmoothing','on');
        end
    end
    
end

%% draw edge markers
[Px,Py] = pol2cart(theta,R+markerR);
% base the color of the node on the 'degree of correlation' with other
% variables:
corrMatrix(logical(eye(M)))=0;
V = mean(abs(corrMatrix),2);
V=V./max(V);

clr = hsv2rgb([ones(M,1)*[0.585 0.5765] V(:)]);
diftheta=unique(quant(diff(linspace(-pi/2+.1,pi/2-.1,M/2)),0.001));
for ii=1:M
    
    dthe=linspace(theta(ii)-.25*diftheta,theta(ii)+.4*diftheta,100);
    [Px,Py] = pol2cart(dthe,R+markerR);
    
    plot(Px,Py,'color',clrstr(ii,:),'linewidth',10);
end


%% draw labels
[Px,Py] = pol2cart(theta,labelR);
for ii=1:M
    text(Px(ii),Py(ii),strNames{ii},'Rotation',theta(ii)*180/pi,'color',[0 0 0], ...
        'FontSize',min(15,fontsize),'Fontweight','Bold','VerticalAlignment','middle','HorizontalAlignment','left');
end

set(gca,'Visible','off')

end
function Bt = getQuadBezier(p0,p1,p2,N)
% defining Bezier Geometric Matrix B
B = [p0(:) p1(:) p2(:)]';

% Bezier Basis transformation Matrix M
M =[1	0	0;
    -2	2	0;
    1	-2	1];
% Calculation of Algebraic Coefficient Matrix A
A = M*B;
% defining t axis
t = linspace(0,1,N)';
T = [ones(size(t)) t t.^2];
% calculation of value of function Bt for each value of t
Bt = T*A;
end