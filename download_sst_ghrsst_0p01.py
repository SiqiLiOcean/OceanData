"""
This script downloads SST data
Group for High Resolution Sea Surface Temperature

https://www.ghrsst.org/about-ghrsst/overview/
https://coastwatch.pfeg.noaa.gov/erddap/files/jplMURSST41/

resolution: 0.01 x 0.01
time interval: daily (since 2002-06-01)
format: NetCDF

Siqi Li, SMAST
2024-03-04
"""

import sys
import os
from datetime import datetime, timedelta
import urllib.request
from urllib.error import URLError, HTTPError


# Settings
output_directory = './'
lon_limits = [-77.97, -56.85]
lat_limits = [31.84, 46.15]
lon_stride = 10
lat_stride = 10

prefix = "SST_GHRSST_0p01"

# Set the default limits of longitude and latitude
if lon_limits is None:
    lonlims = [-179.99, 180.00]

if lat_limits is None:
    latlims = [-89.99, 89.99]

# Usage instructions
USAGE = """
Usage: python download_sst_data.py [start_date] [end_date]
       python download_sst_data.py [date]
       python download_sst_data.py

Arguments:
  start_date    Start date in yyyymmdd format
  end_date      End date in yyyymmdd format (optional, defaults to start_date)
  date          Single date in yyyymmdd format (optional, defaults to current date)

Example:
  python download_sst_data.py 20240101 20240105
"""

# Parse command-line arguments
if len(sys.argv) == 3:
    start_date = datetime.strptime(sys.argv[1], "%Y%m%d")
    end_date = datetime.strptime(sys.argv[2], "%Y%m%d")
elif len(sys.argv) == 2:
    start_date = datetime.strptime(sys.argv[1], "%Y%m%d")
    end_date = start_date
elif len(sys.argv) == 1:
    start_date = datetime.now()
    end_date = datetime.now()
else:
    print("Invalid input format.")
    sys.exit()

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

current_date = start_date
while current_date <= end_date:
    # Format the date in yyyymmdd
    date_str = current_date.strftime('%Y%m%d')
    yyyy = date_str[:4]
    mm = date_str[4:6]
    dd = date_str[6:8]

    # URL
    file_name = f"{prefix}_{date_str}.nc"
    file_path = os.path.join(output_directory, file_name)
    url  = "https://coastwatch.pfeg.noaa.gov/erddap/griddap/jplMURSST41.nc?"
    url += "analysed_sst"
    url += f"%5B({yyyy}-{mm}-{dd}T09:00:00Z):1:({yyyy}-{mm}-{dd}T09:00:00Z)%5D"
    url += f"%5B({lat_limits[0]}):{lat_stride}:({lat_limits[1]})%5D"
    url += f"%5B({lon_limits[0]}):{lon_stride}:({lon_limits[1]})%5D"

    # Download the data for one day
    print(f"----Processing data for {date_str}")
    urlDownload(url, file_path)
    print("     Data download completed.")
    print()

    # Advance the day
    current_date += timedelta(days=1)

