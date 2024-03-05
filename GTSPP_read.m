%==========================================================================
% OceanData 
%   GTSPP : read GTSPP data
%
%   Link: https://www.ncei.noaa.gov/data/oceans/gtspp/bestcopy/meds_ascii/
%         https://www.nodc.noaa.gov/GTSPP/document/codetbls/gtsppcode.html
%
% input  :
%   fin    --- input file
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
% 2023-12-28
%
% Updates:
%
%==========================================================================
function out = GTSPP_read(outdir, varargin)

varargin = read_varargin(varargin, {'tlims'}, {[0 1e8]});
varargin = read_varargin(varargin, {'xlims'}, {[-180 180]});
varargin = read_varargin(varargin, {'ylims'}, {[-90 90]});
varargin = read_varargin(varargin, {'Poly'}, {[xlims([1 2 2 1 1])' ylims([1 1 2 2 1])']});


disp('----- GTSPP read -----')

%------------Set the tlims input--------------
if numel(tlims) == 1
    tlims = [tlims tlims];
end

fins = arrayfun(@(x) [x.folder pathsep x.name], dir([outdir pathsep 'GTSPP_*.dat']), 'UniformOutput', false);


out = struct([]);
for i = 1 : length(fins)
    fin = fins{i};

    year = str2num(fin(end-9:end-6));
    month = str2num(fin(end-5:end-4));
    day1 = datenum(year, month, 1);
    day2 = datenum(year, month+1, 1);
    
    if day1>tlims(2) || day2<tlims(1)
        continue
    end

    one = GTSPP_read_one(fin);

    out = [out one];
end

% Remove the data out of domain
in = inpolygon([out.lon], [out.lat], Poly(:,1), Poly(:,2));
out = out(in);

% Remove the data out of time limits
time = [out.time];
it = (time>=tlims(1) & time<=tlims(2));
out = out(it);
