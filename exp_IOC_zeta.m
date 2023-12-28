%==========================================================================
% OceanData 
%   IOC : an example to deal with the IOC dataset 
%
%   Link: http://www.ioc-sealevelmonitoring.org
%
% Siqi Li, SMAST
% 2023-12-26
%
% Updates:
%
%==========================================================================
clc
clear

%------------------------------Settings------------------------------------
outdir = './';
tlims = [datenum(2023,10,1) datenum(2023,12,7)];
xlims = [0 5];
ylims = [35 40];
%--------------------------------------------------------------------------

% Get the data information
info = IOC_info('xlims', xlims, 'ylims', ylims);
ID = [info.id]';

% Download the data
ID_avail = IOC_download(ID, outdir, tlims);

% Create the file list
fins = arrayfun(@(x) [x.folder '\' x.name], dir([outdir '/*.nc']), 'UniformOutput', false);

% Read the data
sta = IOC_read(fins, 'tlims', tlims, 'Clean');

