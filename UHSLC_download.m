%==========================================================================
% OceanData 
%   UHSLC : download elevation data
%
%   Link: https://uhslc.soest.hawaii.edu/data/
%
% input  :
%   ID     --- ID names (integer, char, or string)
%   outdir --- output directory
%
% output :
%
% Siqi Li, SMAST
% 2023-12-20
%
% Updates:
%
%==========================================================================
function UHSLC_download(ID, outdir)

disp('----- UHSLC download -----')
if ischar(ID)
    ID = convertCharsToStrings(ID);
elseif isnumeric(ID)
    ID = cellstr(num2str(ID(:), '%3.3d'));
elseif isstring(ID) || iscell(ID)
    % Nothing to do.
else
    error('Unknown ID format.')
end

url0 = 'https://uhslc.soest.hawaii.edu/data/netcdf/fast/hourly/';

n = length(ID);

for i = 1 : n
    url = [url0 'h' num2str(ID{i}, '%3.3d') '.nc'];
    fout = [outdir pathsep 'UHSLC_zeta_' ID{i} '.nc'];
    [~, status] = urlread(url);
    if status
        disp(url)
        websave(fout, url);
    else
        disp([ID{i} '--- No data.'])
    end
end
