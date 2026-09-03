function ppt_resave( inputFile, outputFile )
% Unzips or Resaves the image file
% 
% FORMAT ppt_resave( inputFile, outputFile )
% inputFile  - input file string
% outputFile - output file string
% _______________________________________________________________________
% Copyright (C) 2008-2009 Lei Zheng.  All rights reserved.
% http://physics.medma.uni-heidelberg.de/cms/

% Lei Zheng
% $Id: ppt_resave.m 198 2009-10-11 17:20:47Z Lei_Win $


%% Start

disp( [mfilename ' ... start'] )
disp( datestr( now ) )


%% Control

disp( inputFile )
disp( outputFile )


%% Read and write

if exist( inputFile, 'file' )

    inputV = spm_vol( inputFile );
    
    for iV = 1:length( inputV )
        inputY = spm_read_vols( inputV(iV) );

        inputMin = min( inputY(:) );

        outputV = inputV(iV);
        outputV.fname = outputFile;
        outputY = inputY;

        outputY(isnan( inputY )) = inputMin;

        sub_check_file_path( outputFile )
        spm_write_vol( outputV, outputY );
    end
    
    
%% Unzip

elseif exist( [inputFile '.gz'], 'file' )
    
    gunzip( [inputFile '.gz'] )
    sub_check_file_path( outputFile )
    movefile( inputFile, outputFile )
    
    
%% Else

else
    
    disp( 'inputFile doesn''t exist.' )
end


%% End

disp( datestr( now ) )
disp( [mfilename ' ... end'] )


%% Check directory

function sub_check_file_path( checkFile )

filePath = fileparts( checkFile );
if ~exist( filePath, 'dir' )
    mkdir( filePath )
end
