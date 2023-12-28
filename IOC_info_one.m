%==========================================================================
% OceanData 
%   IOC : get one station information
%
%   Link: http://www.ioc-sealevelmonitoring.org
%
% input  :
%   station --- IOC code
%
% output :
%   lon   --- longitude
%   lat   --- latitude
%   descr --- description
%
% Siqi Li, SMAST
% 2023-12-26
%
% Updates:
%
%==========================================================================
function [lon, lat, descr] = IOC_info_one(station)

url0 = 'http://www.ioc-sealevelmonitoring.org/station.php?code=';

url = [url0 convertStringsToChars(station)];

txt = webread(url);

latRegex = '<tr\s*><td\s*class=field>Latitude\s*</td><td\s*class=nice>([-?\d.]+)</td>';
lonRegex = '<tr\s*><td\s*class=field>Longitude\s*</td><td\s*class=nice>(-?[\d.]+)</td>';
cityRegex = '<tr\s*><td\s*class=field>Location\s*</td><td\s*class=nice>\s*([^\s<]+(?:\s+[^\s<]+)*)\s*</td>';
countryRegex = '<tr\s*><td\s*class=field>Country\s*</td><td\s*class=nice>\s*([^\s<]+(?:\s+[^\s<]+)*)\s*</td>';


lon = str2double(regexp(txt, lonRegex, 'tokens', 'once'));
lat = str2double(regexp(txt, latRegex, 'tokens', 'once'));
city = regexp(txt, cityRegex, 'tokens', 'once');
country = regexp(txt, countryRegex, 'tokens', 'once');

descr = [city{1} ', ' country{1}];
