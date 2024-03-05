%==========================================================================
% OceanData 
%   ARGO : download TS data
%
%   Link: https://data-argo.ifremer.fr/geo/
%
% input  :
%   ocean  --- pacific, inidian, or/and atlantic (char or string)
%   outdir --- output directory
%   tlims  --- time limits
%
% output :
%
% Siqi Li, SMAST
% 2023-12-20
%
% Updates:
%
%==========================================================================
function ARGO_download(ocean, outdir, tlims)

disp('----- ARGO download -----')

%------------Set the ocean input--------------
oceans = ["pacific" "atlantic" "indian"];
if isempty(ocean)
    ocean = oceans;
end

if ischar(ocean)
    ocean = convertCharsToStrings(ocean);
elseif isstring(ocean) || iscell(ocean)
    % Nothing to do.
else
    error('Unknown ocean format.')
end

if any(~ismember(ocean, oceans))
    error('Unknown ocean names.')
end

%------------Set the tlims input--------------
if numel(tlims) == 1
    tlims = [tlims tlims];
end
tlims = [floor(tlims(1)) ceil(tlims(2))];

url0 = 'https://data-argo.ifremer.fr/geo/';

n = length(ocean);

for it = tlims(1) : tlims(2)

    for i = 1 : n
        yyyy = datestr(it, 'yyyy');
        mm = datestr(it, 'mm');
        dd = datestr(it, 'dd');
        url = [url0 ocean{i} '_ocean/' yyyy '/' mm '/' yyyy mm dd '_prof.nc'];
        fout = [outdir '/ARGO_' ocean{i} '_' yyyy mm dd '.nc'];

        [~, status] = urlread(url);
        if status
            disp(url)
            websave(fout, url);
        else
            disp(['---' ocean{i} '_' yyyy mm dd 'No data.'])
        end
    end
end
