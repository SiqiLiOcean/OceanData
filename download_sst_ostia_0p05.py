"""
This script downloads SST data from the Copernicus Marine Environment
Monitoring Service (CMEMS) for a specified date range. The script uses
the Copernicus Marine Python library to access the data.

https://marine.copernicus.eu
https://doi.org/10.48670/moi-00165
https://pypi.org/project/copernicusmarine/

resolution: 0.05 x 0.05
time interval: daily
format: NetCDF

The Operational Sea Surface Temperature and Ice Analysis (OSTIA) 
system is run by the UK's Met Office and delivered by IFREMER PU. 
OSTIA uses satellite data provided by the GHRSST project together 
with in-situ observations to determine the sea surface temperature. 
A high resolution (1/20° - approx. 6 km) daily analysis of sea surface 
temperature (SST) is produced for the global ocean and some lakes.

Siqi Li, SMAST
2024-03-04
"""

import sys
import os
from datetime import datetime, timedelta

import copernicusmarine

# Settings
user = ""
pswd = ""
output_directory = './'

prefix = "SST_PSTIA_0p05"

# Dataset information
# Starting from 2007-01-01
dataset_id = "METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2"

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
    current_date = datetime.now()
    today = current_date.strftime("%Y%m%d")
    start_date = current_date
    end_date = current_date
else:
    print("Invalid input format.")
    print(USAGE)
    sys.exit(1)


def download_data(user, pswd, dataset_id, prefix, date_str, output_directory="./"):
    # Define date range
    date_range = f"*/{date_str[:4]}/{date_str[4:6]}/{date_str}*.nc"

    # Call the get function for each dataset to save files for the date range
    download_file = copernicusmarine.get(
        username=user,
        password=pswd,
        dataset_id=dataset_id,
        output_directory=output_directory,
        filter=date_range,
        no_directories=True,
        force_download=True,
        overwrite_output_data=True)

    # Rename the output
    original_path = download_file[0]
    output_file = f"{prefix}_{date_str}.nc"
    output_path = os.path.join(output_directory, output_file)
    os.rename(original_path, output_path)

    return


current_date = start_date
while current_date <= end_date:
    # Format the date in yyyymmdd
    formatted_date = current_date.strftime('%Y%m%d')

    # Download the data for one day
    print(f"----Processing data for {formatted_date}")
    download_data(user, pswd, dataset_id, prefix, formatted_date, output_directory=output_directory)
    print("     Data download completed.")
    print()

    # Advance the day
    current_date += timedelta(days=1)

