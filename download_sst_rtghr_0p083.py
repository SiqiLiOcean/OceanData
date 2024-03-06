"""
This script downloads satellite SST data.
Real-time, global, sea surface temperature (RTG-SST-HR) analysis

https://www.nco.ncep.noaa.gov/pmb/products/sst/

resolution: 0.05 x 0.05
time interval: daily
period: (only the last 2 days are available)
format: grib2 (converted to netcdf)

Siqi Li, SMAST
2024-03-05
"""
import os
import sys
from datetime import datetime
import urllib.request
from urllib.error import URLError, HTTPError
import pygrib
import numpy as np
from netCDF4 import Dataset

# Settings
output_directory = './'

prefix = "SST_RTGHR_0p083"

url0 = "ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/nsst/v1.2/"

# Usage instructions
USAGE = """
Usage: python download_ssh_data.py [date]
       python download_ssh_data.py

Arguments:
  date          Single date in yyyymmdd format (optional, defaults to current date)

Example:
  python download_ssh_data.py 20240105
"""

# Time
if len(sys.argv) == 2:
    date = datetime.strptime(sys.argv[1], "%Y%m%d")
elif len(sys.argv) == 1:
    date = datetime.now()
else:
    print("Invalid input format.")
    print(USAGE)
    sys.exit()
date_str = date.strftime('%Y%m%d')

grb_name = "rtgssthr_grb_0.083_awips.grib2"
nc_name = prefix + "_" + date_str + '.nc'
url = url0 + "nsst." + date.strftime('%Y%m%d') + "/" + grb_name
grb_path = os.path.join(output_directory, grb_name)
nc_path = os.path.join(output_directory, nc_name)

# Download the data
def urlDownload(url, destination):
    try:
        ftp = urllib.request.urlopen(url)
        # If the FTP link is available, download the file
        with open(destination, 'wb') as f:
            f.write(ftp.read())
        print(f"  URL : {url}")
        print(f"  SAVE: {destination}")
    except HTTPError as e:
        print(f"HTTP Error: {e.code}, {e.reason}")
        sys.exit()
    except URLError as e:
        print(f"URL Error: {e.reason}")
        sys.exit()

print("---- Download the data")
urlDownload(url, grb_path)

# Read the data from the grib2 file
print("---- Read the grib2 file")
# Open the grib2 file
grbs = pygrib.open(grb_path)
# Get the variable by name
grb = grbs.select(name='Temperature')[0]
# Read the grids
lat, lon = grb.latlons()
# Read the variable values
sst = grb.values
# Read the time
#grb.dataDate
ny, nx = sst.shape
# Close the grib2 file
grbs.close()

# Write the data into netcdf
print("---- Write the NetCDF file")
# Create a new NetCDF file
nc = Dataset(nc_path, 'w')
nc.title = 'RTGHR SST'
nc.date = date_str
# Create dimensions
lon_dim = nc.createDimension('lon', nx)
lat_dim = nc.createDimension('lat', ny)
time_dim = nc.createDimension('time', None)
# Create variables
lon_var = nc.createVariable('longitude', np.float32, ('lat', 'lon'))
lon_var.long_name = 'longitude'
lon_var.unit = 'degree_north'
lat_var = nc.createVariable('latitude', np.float32, ('lat', 'lon'))
lat_var.long_name = 'latitude'
lat_var.unit = 'degree (0-360)'
sst_var = nc.createVariable('sst', np.float32, ('time', 'lat', 'lon'))
sst_var.long_name = 'sea surface temperature'
sst_var.unit = 'Kelvin'
# Write the data
lon_var[:] = lon
lat_var[:] = lat
sst_var[0, :, :] = sst
# Close the file
nc.close()

# Remove the grb2 file
os.remove(grb_path)

