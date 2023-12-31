%==========================================================================
% OceanData 
%   UHSLC : read elevation data
%
%   Link: https://uhslc.soest.hawaii.edu/data/
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
%              zeta  --- surface elevation (m)
%
% Siqi Li, SMAST
% 2023-12-20
%
% Updates:
%
%==========================================================================
function out = UHSLC_read(source, varargin)

varargin = read_varargin(varargin, {'tlims'}, {[]});
varargin = read_varargin2(varargin, {'Clean'});


disp('----- UHSLC read -----')

if ischar(source)
    source = convertCharsToStrings(source);
elseif isstring(source) || iscell(source)
    % Nothing to do.
else
    error('Unknown source format.')
end

n = length(source);

k = 0;
for i = 1 : n

    fin = source{i};

    if ~isfile(fin)
        error([fin ' not exist'])
    end

    disp(fin)

    lon = calc_lon_180(ncread(fin, 'lon'));
    lat = ncread(fin, 'lat');
    id = convertCharsToStrings(num2str(ncread(fin, 'uhslc_id'), '%3.3d'));
    descr = convertCharsToStrings([ncread(fin, 'station_name')' ', ' ncread(fin, 'station_country')']);
    time = ncread(fin, 'time') + datenum(1800, 1, 1);
    zeta = ncread(fin, 'sea_level') / 1000;

    % Remove the NaN
    j = find(~isnan(zeta));
    time = time(j);
    zeta = zeta(j);
    
    % Set the time limits
    if ~isempty(tlims)
        j = find(time>=tlims(1) & time<=tlims(2));
        time = time(j);
        zeta = zeta(j);
    end

    if ~isempty(Clean) && isempty(time)
        continue
    end

    k = k + 1;
    out(k,1).lon = lon;
    out(k,1).lat = lat;
    out(k,1).id = id;
    out(k,1).descr = descr;
    out(k,1).time = time;
    out(k,1).zeta = zeta;
    
end





