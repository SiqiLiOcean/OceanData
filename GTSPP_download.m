%==========================================================================
% OceanData 
%   GTSPP : download TS data
%
%   Link: https://www.ncei.noaa.gov/data/oceans/gtspp/bestcopy/meds_ascii/
%
% input  :
%   ocean  --- pacific, inidian, or/and atlantic (char or string)
%   outdir --- output directory
%   tlims  --- time limits
%
% output :
%
% Siqi Li, SMAST
% 2023-12-28
%
% Updates:
%
%==========================================================================
function GTSPP_download(ocean, outdir, tlims)

disp('----- GTSPP download -----')

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
tmp1 = datevec(tlims(1));
tmp2 = datevec(tlims(2));
tlims(1) = datenum(tmp1(1), tmp1(2), 1);
tlims(2) = datenum(tmp2(1), tmp2(2), 1);

url0 = 'https://www.ncei.noaa.gov/data/oceans/gtspp/bestcopy/meds_ascii/';

n = length(ocean);

for i = 1 : length(ocean)
    
    it = tlims(1);
    while it <= tlims(2)
        
        yyyy = datestr(it, 'yyyy');
        mm = datestr(it, 'mm');
        
        fout1 = [outdir pathsep ocean{i}(1:2) yyyy mm '.gz'];
        fout2 = [outdir pathsep ocean{i}(1:2) yyyy mm];
        fout3 = [outdir pathsep 'GTSPP_' ocean{i} '_' yyyy mm '.dat'];
        url = [url0 ocean{i}(1:2) yyyy mm '.gz'];
        [~, status] = urlread(url);
        if status
            disp(url)
            websave(fout1, url);
            gunzip(fout1, outdir);
            delete(fout1);
            movefile(fout2, fout3);
            % eval(['movefile ' fout2 ' ' fout3 ' f']);
        else
            disp(['---' ocean{i} '_' yyyy mm ' No data.'])
        end
        it = datenum(str2num(yyyy), str2num(mm)+1, 1);
    end

end
