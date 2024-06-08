%==========================================================================
% OceanData 
%   IOC : download elevation data
%
%   Link: http://www.ioc-sealevelmonitoring.org
%
% input  :
%   ID     --- ID names (integer, char, or string)
%   outdir --- output directory
%
% output :
%
% Siqi Li, SMAST
% 2023-12-26
%
% Updates:
%
% 2024-05-08 ChenYu Zhang  Changed webread to readtable, as there's empty 
%                          at table causing len(time) ~= len(zeta).
%==========================================================================
function ID_out = IOC_download(ID, outdir, tlims)

nday = 30;

disp('----- IOC download -----')
if ischar(ID)
    ID = convertCharsToStrings(ID);
elseif isstring(ID) || iscell(ID)
    % Nothing to do.
else
    error('Unknown ID format.')
end

url0 = 'http://www.ioc-sealevelmonitoring.org/bgraph.php?';

n = length(ID);
pattern1 = '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}';
pattern2 = '(?<=</td><td>)-?\d+(\.\d+)?(?=</td></tr>)';
t1 = tlims(1);
t2 = tlims(2);
flag = nan(n,1);
for i = 1 : n
    disp(['----' ID{i}])
    
    time0 = [];
    zeta0 = [];
    t = t1;
    while t < t2
        t = t + nday;
        url = [url0 'code=' ID{i} '&output=tab&period=' num2str(nday) '&endtime=' datestr(t,'yyyy-mm-dd')];
        % txt = webread(url);
        % 
        % if contains(txt, 'NO DATA')
        %     continue
        % end
        % 
        % match1 = datenum(regexp(txt, pattern1, 'match')', 'yyyy-mm-dd HH:MM:SS');
        % match2 = str2double(regexp(txt, pattern2, 'match')');

        try
            table = readtable(url,'FileType','html');
        catch ME1
            if (strcmp(ME1.identifier,'MATLAB:io:html:detection:NoTablesFound'))
                continue
            end
        end
        match1 = datenum(table(:,1).Variables);
        match2 = table(:,end).Variables;
        time0 = [time0; match1];
        zeta0 = [zeta0; match2];
    end
    [time, zeta] = data_random2hourly(time0, zeta0, 'Tlims', [t1 t2], 'Twindow', 3);
    
    if all(isnan(zeta))
        flag(i) = 0;
    else
        flag(i) = 1;
        [lon, lat, descr] = IOC_info_one(ID{i});
        sta.id = ID{i};
        sta.descr = descr;
        sta.lon = lon;
        sta.lat = lat;
        sta.time = time;
        sta.zeta = zeta;
        fout = [outdir '/IOC_zeta_' ID{i} '_' datestr(t1, 'yyyymmdd') '_' datestr(t2, 'yyyymmdd') '.nc'];
        IOC_archive_one(fout, sta)
    end
end

ID_out(:) = ID(find(flag));

