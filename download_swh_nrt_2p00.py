"""
This script downloads SWH data from the Copernicus Marine Environment
Monitoring Service (CMEMS) for a specified date range. The script uses
the Copernicus Marine Python library to access the data.

https://marine.copernicus.eu
https://doi.org/10.48670/moi-00180
https://pypi.org/project/copernicusmarine/

resolution: 2 x 2
time interval: daily
format: NetCDF

Near-Real-Time gridded multi-mission merged satellite significant wave 
height. Only valid data are included. This product is processed in 
Near-Real-Time by the WAVE-TAC multi-mission altimeter data processing 
system and is based on CMEMS level-3 SWH datasets (see the product 
WAVE_GLO_WAV_L3_SWH_NRT_OBSERVATIONS_014_001). It merges along-track 
SWH data from the following missions: Jason-3, Sentinel-3A, 
Sentinel-3B, SARAL/AltiKa, Cryosat-2, CFOSAT and HaiYang-2B.

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

prefix = "SWH_NRT_2p00"

# Dataset information
# Choose one of the dataset IDs and corresponding prefix

# https://doi.org/10.48670/moi-00148
# This dataset contains history data from 1993-01-01 to several months ago.
# Good for multi-year re-analysis
# dataset_id = "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D"

# or

# https://doi.org/10.48670/moi-00149
# This dataset only stores the data of recent years, but has today's data.
# Good for operational forecast and hindcast
dataset_id = "cmems_obs-wave_glo_phy-swh_nrt_multi-l4-2deg_P1D"

# Usage instructions
USAGE = """
Usage: python download_swh_data.py [start_date] [end_date]
       python download_swh_data.py [date]
       python download_swh_data.py

Arguments:
  start_date    Start date in yyyymmdd format
  end_date      End date in yyyymmdd format (optional, defaults to start_date)
  date          Single date in yyyymmdd format (optional, defaults to current date)

Example:
  python download_swh_data.py 20240101 20240105
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


def download_data(user, pswd, dataset_id, prefix, date_str, output_directory="./"):
    # Define date range
    date_range = f"*/{date_str[:4]}/{date_str[4:6]}/*_{date_str}T120000Z_*.nc"

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

