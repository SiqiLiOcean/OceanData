%==========================================================================
% OceanData 
%   IOC : get station information
%
%   Link: http://www.ioc-sealevelmonitoring.org
%
% input  :
%   [xlims] --- x-coordiante limits
%   [ylims] --- y-coordiante limits
%   [poly]  --- coordinate of boundary lines. Column 1: lon; Column 2: lat 
%               Poly has a higher priority than xlims and ylims.
%
% output :
%   info   --- struct containing data
%              id    --- station ID
%              lon   --- longitude
%              lat   --- latitude
%              descr --- starting time (yyyy-mm-dd)
%              t1    --- date and time (datenum)
%
% Siqi Li, SMAST
% 2023-12-26
%
% Updates:
%
%==========================================================================
function info = IOC_info(varargin)

varargin = read_varargin(varargin, {'xlims'}, {[-180 180]});
varargin = read_varargin(varargin, {'ylims'}, {[-90 90]});
varargin = read_varargin(varargin, {'Poly'}, {[xlims([1 2 2 1 1])' ylims([1 1 2 2 1])']});
varargin = read_varargin2(varargin, {'Update'});

xlims = calc_lon_180(xlims);

disp('----- IOC information -----')

flist = [fundir('IOC_info') 'list\list_IOC.mat'];

if isempty(Update)
    
    load(flist);

else

    x = input('Are you sure to update the IOC station list? This may take up to 10 min. [y/n]\n', "s");
    switch lower(x)
        case {'y', 'yes'}
            % Nothing happens
        case {'n', 'no'}
            error('Re-run your command with the ''Update'' removed.')
        otherwise
            error('Unknown option')
    end

    url = 'http://www.ioc-sealevelmonitoring.org/list.php';
    txt = webread(url);

    pattern = '<a href=''station.php\?code=\w*''>(\w+)</a>';
    matches = regexp(txt, pattern, 'tokens')';

    for i = 1 : length(matches)
        station = matches{i}{1};
        disp(['----' station])
        [lon, lat, descr] = IOC_info_one(station);

        info(i,1).id = convertCharsToStrings(station);
        info(i,1).lon = lon;
        info(i,1).lat = lat;
        info(i,1).descr = convertCharsToStrings(descr);
    end

    save(flist, 'info')
end

lon = [info.lon];
lat = [info.lat];
in = inpolygon(lon, lat, Poly(:,1), Poly(:,2));
info = info(in);