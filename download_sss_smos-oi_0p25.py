"""
This script downloads SSH data from the Copernicus Marine Environment
Monitoring Service (CMEMS) for a specified date range. The script uses
the Copernicus Marine Python library to access the data.

https://marine.copernicus.eu
https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_SSS_L4_MY_015_015/description
https://doi.org/10.1175/JTECH-D-20-0093.1
https://pypi.org/project/copernicusmarine/

resolution: 0.25 x 0.25
time interval: weekly
format: NetCDF
start: 2010-12-27

The product MULTIOBS_GLO_PHY_SSS_L4_MY_015_015 is a reformatting and a
simplified version of the CATDS L4 product called “SMOS-OI”. This product
is obtained using optimal interpolation (OI) algorithm, that combine,
ISAS in situ SSS OI analyses (Copernicus Marine Service products
INSITU_GLO_PHY_TS_OA_NRT_013_002 and INSITU_GLO_PHY_TS_OA_MY_013_052) to
reduce large scale and temporal variable bias and Soil Moisture Ocean
Salinity (SMOS) satellite image with satellite SST information.

Siqi Li, SMAST
2024-03-04
"""

import sys
import os
from datetime import datetime, timedelta

import copernicusmarine

# Settings
user = "sli12"
pswd = "123qweASDF"
output_directory = './'

prefix = "SSS_SMOS-OI_0p25"

# Dataset information
dataset_id = "cmems_obs-mob_glo_phy-sss_my_multi-oi_P1W"

# Usage instructions
USAGE = """
Usage: python download_sss_data.py [start_date] [end_date]
       python download_sss_data.py [date]
       python download_sss_data.py

Arguments:
  start_date    Start date in yyyymmdd format
  end_date      End date in yyyymmdd format (optional, defaults to start_date)
  date          Single date in yyyymmdd format (optional, defaults to current date)

Example:
  python download_sss_data.py 20220101 20220105
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
    start_date = current_date
    end_date = current_date
else:
    print("Invalid input format.")
    print(USAGE)
    sys.exit()

# Modify the starting and ending time
start_date -= timedelta(days = start_date.weekday())
end_date   -= timedelta(days = end_date.weekday())

def download_data(user, pswd, dataset_id, prefix, date_str, output_directory="./"):
    # Define date range
    date_range = f"*/{date_str[:4]}/*_{date_str}T000000_*.nc"

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
print(current_date.strftime('%Y%m%d'))
while current_date <= end_date:
    # Format the date in yyyymmdd
    formatted_date = current_date.strftime('%Y%m%d')

    # Download the data for one day
    print(f"----Processing data for {formatted_date}")
    download_data(user, pswd, dataset_id, prefix, formatted_date, output_directory=output_directory)
    print("     Data download completed.")
    print()

    # Advance the day
    current_date += timedelta(days = 7)

