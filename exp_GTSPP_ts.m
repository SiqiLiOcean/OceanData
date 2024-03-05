%==========================================================================
% OceanData 
%   GTSPP : an example to deal with the GTSPP dataset 
%
%   Link: https://www.ncei.noaa.gov/data/oceans/gtspp/bestcopy/meds_ascii/
%
% Siqi Li, SMAST
% 2023-12-29
%
% Updates:
%
%==========================================================================
clc
clear

%------------------------------Settings------------------------------------
outdir = './';
ocean = ["atlantic" "indian"];
tlims = [datenum(2023,10,1) datenum(2023,10,7)];
xlims = [-180 180];
ylims = [-90 90];
%--------------------------------------------------------------------------

% Download the data
GTSPP_download(ocean, outdir, tlims);

% Read the data
sta = GTSPP_read(outdir, 'tlims', tlims, 'xlims', xlims, 'ylims', ylims);
