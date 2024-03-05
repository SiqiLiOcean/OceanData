%==========================================================================
% OceanData 
%   ARGO : an example to deal with the ARGO dataset 
%
%   Link: https://data-argo.ifremer.fr/geo/
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
ocean = ["pacific" "indian"];
tlims = [datenum(2023,10,1) datenum(2023,10,2)];
xlims = [-80 -60];
ylims = [-40 40];
%--------------------------------------------------------------------------

% Download the data
ARGO_download(ocean, outdir, tlims);

% Read the data
sta = ARGO_read(outdir, 'tlims', tlims, 'xlims', xlims, 'ylims', ylims);

