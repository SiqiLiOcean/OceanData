%==========================================================================
% OceanData 
%   IOC : archive one station data
%
%   Link: http://www.ioc-sealevelmonitoring.org
%
% input  :
%   fout  --- archive filename
%   sta   --- struct for one IOC station
%
% output :
%
% Siqi Li, SMAST
% 2023-12-26
%
% Updates:
%
%==========================================================================
function IOC_archive_one(fout, sta)

nt = length(sta.time);
IDStrLen = 7;
LocationStrLen = 50;

ncid = netcdf.create(fout, 'CLOBBER');

station_dimid = netcdf.defDim(ncid, 'station', 1);
time_dimid = netcdf.defDim(ncid, 'time', nt);
IDStrLen_dimid = netcdf.defDim(ncid, 'IDStrLen', 7);
LocationStrLen_dimid = netcdf.defDim(ncid, 'LocationStrLen', LocationStrLen);


id_varid = netcdf.defVar(ncid, 'id', 'char', [IDStrLen_dimid station_dimid]);
netcdf.putAtt(ncid, id_varid, 'description', 'IOC code');

lon_varid = netcdf.defVar(ncid, 'lon', 'double', station_dimid);
netcdf.putAtt(ncid, lon_varid, 'description', 'longitude');
netcdf.putAtt(ncid, lon_varid, 'unit', 'degree_east');

lat_varid = netcdf.defVar(ncid, 'lat', 'double', station_dimid);
netcdf.putAtt(ncid, lat_varid, 'description', 'latitude');
netcdf.putAtt(ncid, lat_varid, 'unit', 'degree_north');

location_varid = netcdf.defVar(ncid, 'location', 'char', [LocationStrLen_dimid station_dimid]);
netcdf.putAtt(ncid, location_varid, 'description', 'city, country');

time_varid = netcdf.defVar(ncid, 'time', 'double', time_dimid);
netcdf.putAtt(ncid, time_varid, 'description', 'GMT');
netcdf.putAtt(ncid, time_varid, 'unit', 'days since 1800-01-01 00:00:00');

zeta_varid = netcdf.defVar(ncid, 'zeta', 'float', [station_dimid time_dimid]);
netcdf.putAtt(ncid, zeta_varid, 'description', 'water surface elevation');
netcdf.putAtt(ncid, zeta_varid, 'unit', 'meter');

netcdf.putAtt(ncid, -1, 'source', 'IOC (http://www.ioc-sealevelmonitoring.org)');
netcdf.putAtt(ncid, -1, 'archive', 'OceanData (https://github.com/SiqiLiOcean/OceanData)');


netcdf.endDef(ncid);

netcdf.putVar(ncid, id_varid, pad(sta.id, IDStrLen, 'left'));
netcdf.putVar(ncid, lon_varid, sta.lon);
netcdf.putVar(ncid, lat_varid, sta.lat);
netcdf.putVar(ncid, location_varid, pad(sta.descr, LocationStrLen, 'left'));
netcdf.putVar(ncid, time_varid, sta.time-datenum(1800,1,1));
netcdf.putVar(ncid, zeta_varid, sta.zeta);

netcdf.close(ncid);
