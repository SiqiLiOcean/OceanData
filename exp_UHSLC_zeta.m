%==========================================================================
% OceanData 
%   UHSLC : an example to deal with the UHSLC dataset 
%
%   Link: https://uhslc.soest.hawaii.edu/data/
%
% Siqi Li, SMAST
% 2023-12-20
%
% Updates:
%
%==========================================================================
clc
clear

%------------------------------Settings------------------------------------
outdir = '../data/';
tlims = [datenum(2023,10,1) datenum(2023,12,7)];
xlims = [-180 180];
ylims = [-90 90];
%--------------------------------------------------------------------------

% Get the data information
info = UHSLC_info('xlims', xlims, 'ylims', ylims);
ID = [info.id];

% Download the data
UHSLC_download(ID, outdir);

% Create the file list
fins = arrayfun(@(x) [outdir '/UHSLC_zeta_' convertStringsToChars(x) '.nc'], ID, 'UniformOutput', false);

% Read the data
out = UHSLC_read(fins, 'tlims', tlims, 'Clean');


