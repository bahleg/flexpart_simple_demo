# Demo example of Flexpart usage

## Abstract

The following repository contains Docker for Flexpart usage with an example and instructions to run.
The docker contains the following apps:
* Flexpart 10.4 (the installation steps were copy-pasted from [this blog](http://www.martin-rdz.de/index.php/2021/02/27/flexpart-10-into-a-docker-container/))
* flex_extract 7.1.2 (a library for downloading and processing data)
* Quicklook (a simple python library for flexpart results visualization)

**Warning** the installation scripts in docker are not optimized and were written in such a manner that it is convenient to debug them. If you want to use a piece of docker code in real life, optimize it.

## Docker build and run
Before docket usage, please turn on VPN: Flexpart is currently unavailable from Russia.

Docker build:
```
docker build . -t flexpart
```

Docker run (as a daemon):
```
sudo docker run -d --name flexpart flexpart
sudo docker exec -it flexpart /bin/bash
```


## Data retrieval

The example provided in [the official documentation for Flexpart](https://www.geosci-model-dev.net/12/4955/2019/gmd-12-4955-2019.pdf) is focused on ERA-5 dataset. However:
* The API for ERA-5 downloading changed and differs from the API mentioned in the documentation
* ERA-5 dataset has a significant size even for a small time interval
* API , currently provided for downloading is extremely slow ([https://confluence.ecmwf.int/display/CUSF/Long+queueing+time+for+reanalysis+ERA5+data+request](see issues like this for example))

Therefore I prepared a version of the example experiment for [CERA-20C](https://www.ecmwf.int/en/forecasts/datasets/reanalysis-datasets/cera-20c), which is simplier to download.
Nevertheless, some instructions for ERA-5 are also provided.

### CERA-20C downloading
1. Register at [ECMWF](https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets)
2. Get keys from [API page](https://api.ecmwf.int/v1/key/)
3. Write the keys into "~/.ecmwfapirc" file (`nano ~/.ecmwfapirc`)
4. `cd /flextract/flex_extract_v7.1.2/Run/`
5. `bash run_example.sh`

**Warning** For the first time the script can exit with an error and a message that you must sumbit an additional agreement (url will be provided in the error message). Submit an agreement and retry.

6. The downloading will be started. It took me about 6 hours to download the dataset.
7. In the final, the dataset will be saved into flextract/flex_extract_v7.1.2/Run/Workspace

### ERA-5 downloading
1. Register at [CDS](https://cds.climate.copernicus.eu/)
2. Get keys from [API page](https://cds.climate.copernicus.eu/api-how-to#install-the-cds-api-key)
3. Write the keys into "~/.cdsapirc" file (`nano ~/.cdsapirc`)
4. `cd /flextract/flex_extract_v7.1.2/Run/`
5. `bash run_era5.sh`

**Warning** For the first time the script can exit with  an error and a message that you must sumbit an additional agreement (url will be provided in the error message). Submit an agreement and retry.
6. The downloading will be started. The downloading is extremely slow, prepare for it.
7. In the final, the dataset will be saved into flextract/flex_extract_v7.1.2/Run/Workspace


## Simulation run
To run FLEXPART the experiment directory should be prepared.
The example experiment directory is located at /flex_src/flexpart_v10.4_3d7eebf/default_exp_CERA/ (For ERA-5 the standard example is prepared at the root directory of flexpart: flex_src/flexpart_v10.4_3d7eebf/).
The main files:
* pathnames - contains paths to options of the simulation, path to dataset and path to store results
* AVAILABLE - contains paths for all the GRIB-files from the dataset. Note the format of the file (6 spaces are used as a column separator, this is an obligatory requirement).
* options/COMMAND - contains parameters of the simulation, including simulation time, forward/backward mode, etc
* options/OUTGRID - grid parameters
* options/RELEASES - parameters of particle release, including time of the release and types of the particles 
* options/RECEPTORS - parameters for receptors (in backward mode)
* options/SPECIES --- directory with different types of particles for release (note, that the only particle types released in simulation are set in options/RELEASES)

Run the experiment:
1. `cd /flex_src/flexpart_v10.4_3d7eebf/default_exp_CERA/`
2. `../src/FLEXPART`
3. The result will be saved into output directory


## Visualization
To the best of my knowledge, currently there are 3 relatively up-to-date  visualization libraries in Python for FLEXPART:
* reflexible - does not support latest FLEXPART
* pyflexplot - uses NetCDF format for FLEXPART (non-default install setting)
* quicklook - supports native FLEXPART format, easy to install, but in Python 2.

There we will be use quicklook.

1. `cd /quicklook/quicklook/src`
2. Enable matplotlib backend that does not require X screen: `export MPLBACKEND=Agg`
3. Create output directory: `mkdir out`
4. Run visualization for the full map:`
python2.7 quick_look.py  -i /flex_src/flexpart_v10.4_3d7eebf/default_exp_CERA/output -o out -t mother -d -25 10 59 74`
5. In the result, there will be multiple map images (for each time interval) + GIF animation of particle release.