FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

# FLEXPART INSTALLATION
RUN apt-get update && apt-get update && apt-get install -y \
  language-pack-en openssh-server vim software-properties-common \
  build-essential make gcc g++ zlib1g-dev git python3 python3-dev python3-pip \
  pandoc python3-setuptools imagemagick\
  gfortran autoconf libtool automake flex bison cmake git-core \
  libjpeg8-dev libfreetype6-dev libhdf5-serial-dev \
  libeccodes0 libeccodes-data libeccodes-dev \
  libnetcdf-c++4 libnetcdf-c++4-dev libnetcdff-dev \
  binutils  python3-numpy python3-mysqldb \
  python3-scipy python3-sphinx libedit-dev unzip curl wget
  
  
# replaced 'libpng12-dev' by libpng-dev
RUN add-apt-repository ppa:ubuntugis/ppa \
  && apt-get update \
  && apt-get install -y libatlas-base-dev libpng-dev \
     libproj-dev libgdal-dev gdal-bin  
RUN add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main' \
  && apt-get update \
  && apt-get install -y libjasper1 libjasper-dev libeccodes-tools libeccodes-dev
#ENV HTTP https://confluence.ecmwf.int/download/attachments/45757960
#ENV ECCODES eccodes-2.9.2-Source
#
# Download, modify and compile flexpart 10
#
RUN mkdir flex_src && cd flex_src \
  && wget https://www.flexpart.eu/downloads/66 \
  && tar -xvf 66 \
  && rm 66 \
  && cd flexpart_v10.4_3d7eebf/src \
  && cp makefile makefile_local \
  && sed -i '74 a INCPATH1 = /usr/include\nINCPATH2 = /usr/include\nLIBPATH1 = /usr/lib\n F90 = gfortran' makefile_local \
  && sed -i 's/LIBS = -lgrib_api_f90 -lgrib_api -lm -ljasper $(NCOPT)/LIBS = -leccodes_f90 -leccodes -lm -ljasper $(NCOPT)/' makefile_local \
  && make -f makefile_local
ENV PATH /flex_src/flexpart_v10.4_3d7eebf/src/:$PATH


# FLEX EXTRACT INSTALLATION
RUN mkdir flextract  
RUN cd flextract; wget https://phaidra.univie.ac.at/download/o:1097971 -O /flextract/tar.tar 
RUN  cd flextract; tar -xvf tar.tar
RUN apt-get update
RUN apt-get install -y python3 python3-dev python3-pip
RUN apt-get install -y gfortran 
RUN apt-get install -y fftw3-dev
RUN apt-get install -y libeccodes-dev 
RUN apt-get install -y libemos-dev 
RUN apt-get install -y python-tk
RUN apt-get install -y nano
RUN pip3 install --upgrade pip
RUN pip3 install cdsapi>=0.5.1
RUN pip3 install ecmwf-api-client>===1.6.3
RUN pip3 install genshi numpy eccodes>=1.4.2


COPY setup.sh /flextract/flex_extract_v7.1.2/
COPY makefile_local_gfortran /flextract/flex_extract_v7.1.2/Source/Fortran/
RUN cd /flextract/flex_extract_v7.1.2/; bash setup.sh 
RUN cd /flextract/flex_extract_v7.1.2/Testing/Installation/Calc_etadot; ../../../Source/Fortran/calc_etadot


# QUICKLOOK INSTALLATION
RUN  apt-get install -y python python-pip python-dev python-numpy 
RUN python2.7 -m pip install basemap>=1.3.3
RUN python2.7 -m pip install matplotlib>=2.2.5
RUN mkdir /quicklook; cd /quicklook;git clone https://bitbucket.org/radekhofman/quicklook.git; cd quicklook; git checkout readfp10;

# EXAMPLE FILES
COPY run_example.sh /flextract/flex_extract_v7.1.2/Run
COPY run_era5.sh /flextract/flex_extract_v7.1.2/Run
COPY  default_exp_CERA /flex_src/flexpart_v10.4_3d7eebf/default_exp_CERA
RUN mkdir /flex_src/flexpart_v10.4_3d7eebf/default_exp_CERA/output

ENTRYPOINT tail -f /dev/null