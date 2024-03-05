%==========================================================================
% OceanData 
%   ARGO : archive one station data
%
%   Link: https://data-argo.ifremer.fr/geo/
%
% input  :
%   fin     --- NetCDF filename (char or string)
%   [tlims] --- time limits (datenum)
%   [Clean] --- flag to stations with no data
%
% output :
%   out    --- struct containing data
%              id    --- UHSLC ID
%              descr --- station description
%              time  --- date and time (datenum)
%              lon   --- longitude (degree east)
%              lat   --- latitude (degree north)
%              t     --- temperature (degree C)
%              s     --- salinity (psu)
%
% Siqi Li, SMAST
% 2023-12-20
%
% Updates:
%
%==========================================================================
function out = ARGO_read(outdir, varargin)

varargin = read_varargin(varargin, {'tlims'}, {[0 1e8]});
varargin = read_varargin(varargin, {'xlims'}, {[-180 180]});
varargin = read_varargin(varargin, {'ylims'}, {[-90 90]});
varargin = read_varargin(varargin, {'Poly'}, {[xlims([1 2 2 1 1])' ylims([1 1 2 2 1])']});


disp('----- ARGO read -----')

%------------Set the tlims input--------------
if numel(tlims) == 1
    tlims = [tlims tlims];
end

fins = arrayfun(@(x) [x.folder pathsep x.name], dir([outdir pathsep 'ARGO_*.nc']), 'UniformOutput', false);

k = 0;
out = struct([]);
for i = 1 : length(fins)
    fin = fins{i};

    day = datenum(fin(end-10:end-3),'yyyymmdd');
    if day<tlims(1) || day>tlims(2)
        continue
    end

    lon = ncread(fin, 'LONGITUDE');
    lat = ncread(fin, 'LATITUDE');
    z = ncread(fin, 'PRES');
    time = ncread(fin, 'JULD') + datenum(1950,1,1);
    t = ncread(fin, 'TEMP');
    s = ncread(fin, 'PSAL');

    for j = 1 : length(lon)
        
        if ~inpolygon(lon(j), lat(j), Poly(:,1), Poly(:,2))
            continue
        end

        ts = [t(:,j) s(:,j)];
        id = find(~isnan(sum(ts,2)));
        
        k = k + 1;
        out(k,1).lon = lon(j);
        out(k,1).lat = lat(j);
        out(k,1).z = z(id);
        out(k,1).time = time(j);
        out(k,1).t = t(id,j);
        out(k,1).s = s(id,j);
    end

end
