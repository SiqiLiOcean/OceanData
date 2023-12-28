%==========================================================================
% OceanData 
%   UHSLC : get station information
%
%   Link: https://uhslc.soest.hawaii.edu/data/
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
% 2023-12-20
%
% Updates:
%
%==========================================================================
function info = UHSLC_info(varargin)

varargin = read_varargin(varargin, {'xlims'}, {[-180 180]});
varargin = read_varargin(varargin, {'ylims'}, {[-90 90]});
varargin = read_varargin(varargin, {'Poly'}, {[xlims([1 2 2 1 1])' ylims([1 1 2 2 1])']});


xlims = calc_lon_180(xlims);

disp('----- UHSLC information -----')

flist = [fundir('UHSLC_info') 'list\list_UHSLC.dat'];


formatSpec = '%d %d %s %s %f %f %s %s %s %s %s %s %s';

% Read the text file into a table
info0 = readtable(flist, 'Delimiter', '\t', 'ReadVariableNames', false, 'Format', formatSpec);

% Put data into the info struct
j = 0;
for i = 1 : height(info0)
    lat = info0.Var5(i);
    lon = info0.Var6(i);
    in = inpolygon(lon, lat, Poly(:,1), Poly(:,2));
    if ~in
        continue
    end

    disp(['----' num2str(info0.Var1(i), '%3.3d')])
    j = j + 1;
    info(j,1).id = convertCharsToStrings(num2str(info0.Var1(i), '%3.3d'));
    info(j,1).lon = lon;
    info(j,1).lat = lat;
    info(j,1).t1 = info0.Var7(i);
    info(j,1).descr = convertCharsToStrings([info0.Var3{i} ', ' info0.Var4{i}]);
end

