%==========================================================================
% OceanData 
%   UHSLC : read elevation data
%
%   Link: https://uhslc.soest.hawaii.edu/data/
%
% input  :
%   fin    --- NetCDF filename (char or string)
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

disp('----- UHSLC read -----')

if ischar(source)
    source = convertCharsToStrings(source);
elseif isstring(source) || iscell(source)
    % Nothing to do.
else
    error('Unknown source format.')
end

n = length(source);

for i = 1 : n

    fin = source{i};

    if ~isfile(fin)
        error([fin ' not exist'])
    end

    disp(fin)

    out(i,1).lon = ncread(fin, 'lon');
    out(i,1).lat = ncread(fin, 'lat');
    out(i,1).id = convertCharsToStrings(num2str(ncread(fin, 'uhslc_id'), '%3.3d'));
    out(i,1).descr = convertCharsToStrings([ncread(fin, 'station_name')' ', ' ncread(fin, 'station_country')']);
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

    out(i,1).time = time;
    out(i,1).zeta = zeta;
    
end





