function FD = SNiP_framewise_displacement_original(parameters, varargin)
% function SNiP_framewise_displacement(parameters, radius)
%
% Compute framewise displacement (FD) after Power et al. (2012)
%
% Input
% parameters    movement parameters as given by SPM.
% radius        optional (defaults to 50 mm). Assume head radius to 
%               be of radius mm. Default is usually more than ok.
%
% Output:
% FD:           framewise displacement (||\cdot ||_1 of parameter diffs)
%
% This code is based on Power et al. (2012). For whatever reason the
% displacement is not the euclidean distance but ||\cdot ||_1. 
%
%
% Axel Schäfer (axel.schaefer@zi-mannheim.de)


% Error checking on input arguments

if isempty(parameters) || ~ismatrix(parameters)
    error('parameters is empty or not a matrix');
end

if size(parameters,2) ~= 6
    error('need 6 movement paratameters');
end

df = zeros(size(parameters));
df(2:end,:) = diff(parameters);

% The idea of this calculation is as follows
% with radius = 50 mm, a circle has circumference of 2*pi*50 = c
% c/(2*pi)*rad would then give the displacement on the circle and
% this simplifies to 50*rad.

if nargin > 1
%     df(:,4:6) = df(:,4:6)*varargin{1};
    df(:,4:6) = df(:,4:6).*repmat([1 1 2],size(df,1),1)*varargin{1};
else
    % multiplier (standard)
%         df(:,4:6) = df(:,4:6).*50;
% rp=[? ? ?  rot_around_left-right-axis(x-axis)
% rot_around_anterior-posterior-axis(z-axis) rot_around_ventral-dorsal-axis
% (y-axis)]
%     df(:,4:6) = df(:,4:6).*repmat([87.5 62.5 100],size(df,1),1);
df(:,4:6) = df(:,4:6).*repmat([4.4 3.1 5.0],size(df,1),1);
end


% this is a city block distance (||\cdot ||_1) for some reason that I don't
% understand.

FD = sum(abs(df),2); 




