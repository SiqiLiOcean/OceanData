%==========================================================================
% OceanData 
%   UHSLC : an example to deal with the UHSLC dataset 
%
%   Link: https://uhslc.soest.hawaii.edu/data/
%
% input  :
%   [xlims] --- x-coordiante limits
%   [ylims] --- y-coordiante limits
%   [poly]  --- coordinate of boundary lines. Column 1: lon; Column 2: lat 
%               Poly has a higher priority than xlims and ylims.
%
% output :
%   info   --- struct containing data
%              id    --- UHSLC ID
%              descr --- starting time (yyyy-mm-dd)
%              t1    --- date and time (datenum)
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
outdir = './';
tlims = [datenum(2023,10,1) datenum(2023,12,7)];
xlims = [-40 40];
ylims = [-30 30];
%--------------------------------------------------------------------------

% Get the data information
info = UHSLC_info('xlims', xlims, 'ylims', ylims);
ID = [info(1:3).id];

% Download the data
UHSLC_download(ID, outdir);

% Create the file list
fins = arrayfun(@(x) [outdir '/UHSLC_zeta_' convertStringsToChars(x) '.nc'], ID, 'UniformOutput', false);

% Read the data
out = UHSLC_read(fins, 'tlims', tlims);


