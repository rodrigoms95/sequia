# flex_install.sh
#
#
# Installs FLEXPART on an Ubuntu/Debian distribution.
#
#
# Flags:
# -n: The name of the user for which FLEXPART will be installed.
# -c: The type of conda installation.
#     anaconda:  install Anaconda.
#     anaconda3: Anaconda is already installed.
#     miniconda: install miniconda.
#     conda:     Miniconda is already installed.
# -w: Signals the use of a WSL virtual machine,
#     doesn't take parameters.
#
# Stop at first error.
set -e

# Default options for conda and user.
user="rodrigo"
conda="miniconda"

# Read arguments.
while getopts n:c:w flag
do
    case "${flag}" in
        n) user=${OPTARG};;
        c) conda=${OPTARG};;
        w) win=true;;
    esac
done

# Establish home directory.
HOME="/home/$user"
case $conda in
    # For use with anaconda.
    anaconda|anaconda3)
        # Directory for environments.
        CONDA_DIR="$HOME/anaconda3"
        # Directory for source in shell scripts.
        CONDA_SOURCE="$HOME/anaconda3"
        # Download url.
        CONDA_WEB="Anaconda3-2021.05-Linux-x86_64.sh";;
    # For use with miniconda.
    miniconda|conda|*)
        CONDA_DIR="$HOME/.conda"
        CONDA_SOURCE="$HOME/miniconda"
        CONDA_WEB="Miniconda3-py39_4.9.2-Linux-x86_64.sh";;
esac

# Write variables to .bashrc.
sudo echo "" >> $HOME/.bashrc
sudo echo "# Home directory" >> $HOME/.bashrc
sudo echo HOME=$HOME >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# Conda directory" >> $HOME/.bashrc
sudo echo CONDA_DIR=$CONDA_DIR >> $HOME/.bashrc
sudo echo CONDA_SOURCE=$CONDA_SOURCE >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "" >> /root/.bashrc
sudo echo "# Home directory" >> /root/.bashrc
sudo echo HOME=$HOME >> /root/.bashrc
sudo echo "" >> /root/.bashrc
sudo echo "# Conda directory" >> /root/.bashrc
sudo echo CONDA_DIR=$CONDA_DIR >> /root/.bashrc
sudo echo CONDA_SOURCE=$CONDA_SOURCE >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source /root/.bashrc

# Copy API keys.
cd $HOME
cp $HOME/.cdsapirc /root/.cdsapirc
cp $HOME/.ecmwfapirc /root/.ecmwfapirc

# Install required packages.
sudo apt-get update
sudo apt-get -y install g++
sudo apt-get -y install gfortran
sudo apt-get -y install autoconf
sudo apt-get -y install libtool
sudo apt-get -y install automake
sudo apt-get -y install flex
sudo apt-get -y install bison
sudo apt-get -y install git
sudo apt-get -y install python3
sudo apt-get -y install python3-pip
sudo apt-get -y install libnetcdf-dev
sudo apt-get -y install libnetcdff-dev
sudo apt-get -y install libopenjp2-7-dev
sudo apt-get -y install libssl-dev
sudo apt-get -y install make
sudo apt-get -y install unzip
sudo apt-get -y install wget

# Install Cmake.
cd $HOME
wget -q https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3.tar.gz
tar -xzf cmake-3.20.3.tar.gz
cd cmake-3.20.3
./bootstrap
make -s -j 2
sudo make -s -j 2 install
cd $HOME
sudo rm cmake-3.20.3.tar.gz
sudo rm -r cmake-3.20.3

# Install Eccodes.
cd $HOME
mkdir source_builds
cd source_builds
mkdir eccodes
cd eccodes
wget -q https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.21.0-Source.tar.gz?api=v2
tar -xzf eccodes-2.21.0-Source.tar.gz?api=v2
mkdir build
cd build
sudo mkdir /usr/local/eccodes
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/eccodes -DENABLE_JPG=ON ../eccodes-2.21.0-Source
make -s -j 2
ctest
sudo make -s -j 2 install
cd /usr/local/eccodes/bin
sudo cp -r * /usr/bin
sudo echo "# Eccodes directory" >> $HOME/.bashrc
sudo echo 'export ECCODES_DIR=/usr/local/eccodes' >> $HOME/.bashrc
sudo echo 'export ECCODES_DEFINITION_PATH=/usr/local/eccodes/share/eccodes/definitions' >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# Eccodes directory" >> /root/.bashrc
sudo echo 'export ECCODES_DIR=/usr/local/eccodes' >> /root/.bashrc
sudo echo 'export ECCODES_DEFINITION_PATH=/usr/local/eccodes/share/eccodes/definitions' >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source /root/.bashrc
cd $HOME
sudo rm -r source_builds
sudo cp /usr/local/eccodes/lib/libeccodes.so /usr/lib/x86_64-linux-gnu
sudo cp /usr/local/eccodes/include/* /usr/include/

# Install Eccodes for Python.
sudo apt-get -y install libemos-dev
sudo apt-get -y install libeccodes-dev
pip3 install eccodes-python
python3 -m eccodes selfcheck

# Install conda if required.
case $conda in
    miniconda|anaconda)
        cd $HOME
        wget -q https://repo.anaconda.com/miniconda/$CONDA_WEB
        sudo bash $HOME/$CONDA_WEB -b -p $CONDA_SOURCE
        sudo rm $CONDA_WEB
        sudo echo "# Path to conda binaries." >> $HOME/.bashrc
        sudo echo export PATH="$CONDA_SOURCE/bin:$PATH" >> $HOME/.bashrc
        sudo echo export PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc
        sudo echo "" >> $HOME/.bashrc
        sudo echo "# Path to conda binaries." >> /root/.bashrc
        sudo echo export PATH="$CONDA_SOURCE/bin:$PATH" >> /root/.bashrc
        sudo echo export PATH="$HOME/.local/bin:$PATH" >> /root/.bashrc
        sudo echo "" >> /root/.bashrc
        source /root/.bashrc
        source $CONDA_SOURCE/etc/profile.d/conda.sh
        conda init
        source $CONDA_SOURCE/etc/profile.d/conda.sh
        conda config --append envs_dirs $CONDA_DIR/envs;;
esac

# Create conda environment named fp for use with FLEXPART.
source $CONDA_SOURCE/etc/profile.d/conda.sh
yes | conda create -q -n fp python=3.8 pip
conda activate fp
yes | pip3 install -q genshi
yes | pip3 install -q numpy
yes | pip3 install -q cdsapi
yes | pip3 install -q ecmwf-api-client
yes | pip3 install -q eccodes
yes | pip install netCDF4 --upgrade
CONDA_FP="$CONDA_DIR/envs/fp/bin/python"
sudo echo "# Conda fp environment pathname" >> $HOME/.bashrc
sudo echo CONDA_FP=$CONDA_FP  >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# Conda fp environment pathname" >> /root/.bashrc
sudo echo CONDA_FP=$CONDA_FP  >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source /root/.bashrc

# Install HDF5.
cd $HOME
wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/hdf5-1.8.13.tar.gz
tar -xzf hdf5-1.8.13.tar.gz
prefix="/usr/local/hdf5-1.8.13"
sudo echo "# HDF5 libraries for python" >> $HOME/.bashrc
sudo echo export HDF5_DIR=$prefix  >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# HDF5 libraries for python" >> /root/.bashrc
sudo echo export HDF5_DIR=$prefix  >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source /root/.bashrc
cd hdf5-1.8.13
./configure --enable-shared --enable-hl --prefix=/usr/local/hdf5-1.8.13
make -s -j 2
make check
sudo make -s -j 2 install
cd $HOME
sudo rm hdf5-1.8.13.tar.gz
sudo rm -r hdf5-1.8.13

# Install NetCDF4.
cd $HOME
wget -q https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-c-4.8.0.tar.gz
tar -xzf netcdf-c-4.8.0.tar.gz
prefix="/usr/local/"
sudo echo "# NETCDF4 libraries for python" >> $HOME/.bashrc
sudo echo export NETCDF4_DIR=$prefix  >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# NETCDF4 libraries for python" >> /root/.bashrc
sudo echo export NETCDF4_DIR=$prefix  >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source $HOME/.bashrc
source /root/.bashrc
cd netcdf-c-4.8.0
CPPFLAGS=-I/usr/local/hdf5-1.8.13/include LDFLAGS=-L/usr/local/hdf5-1.8.13/lib ./configure --enable-netcdf-4 --enable-shared --enable-dap --prefix=$NETCDF4_DIR
make -s -j 2
make check
sudo make -s -j 2 install
cd $HOME
sudo cp /usr/local/lib/libnetcdf.so.19 /usr/lib/x86_64-linux-gnu
sudo rm netcdf-c-4.8.0.tar.gz
sudo rm -r netcdf-c-4.8.0

# Install flex_extract.
cd /usr/local
sudo git clone --single-branch --branch master https://www.flexpart.eu/gitmob/flex_extract
cd flex_extract
sudo mkdir tmp
sudo rm setup_local.sh
sudo cp $HOME/flex_install/setup_local.sh setup_local.sh
cd Source/Fortran
sudo rm makefile_local_gfortran
sudo cp $HOME/flex_install/makefile_local_gfortran makefile_local_gfortran
cd ../..
sudo bash ./setup_local.sh
FLEX_SUBMIT="/usr/local/flex_extract/Source/Python/submit.py"
FLEX_INPUT="/usr/local/flex_extract/tmp"
FLEX_OUTPUT="/usr/local/flexpart_v10.4/preprocess/flex_extract/work"
sudo echo "# flex_extract pathnames" >> $HOME/.bashrc
sudo echo FLEX_SUBMIT=$FLEX_SUBMIT >> $HOME/.bashrc
sudo echo FLEX_INPUT=$FLEX_INPUT >> $HOME/.bashrc
sudo echo FLEX_OUTPUT=$FLEX_OUTPUT >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# flex_extract pathnames" >> /root/.bashrc
sudo echo FLEX_SUBMIT=$FLEX_SUBMIT >> /root/.bashrc
sudo echo FLEX_INPUT=$FLEX_INPUT >> /root/.bashrc
sudo echo FLEX_OUTPUT=$FLEX_OUTPUT >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source /root/.bashrc

# Install FLEXPART.
# Normal version: src2.
cd /usr/local
sudo wget -q https://www.flexpart.eu/downloads/66
sudo tar -xf 66
sudo mv flexpart_v10.4_3d7eebf flexpart_v10.4
sudo rm -r 66
FLEX_DIR="/usr/local/flexpart_v10.4"
sudo echo "# FLEXPART directory" >> $HOME/.bashrc
sudo echo FLEX_DIR=$FLEX_DIR >> $HOME/.bashrc
sudo echo "" >> $HOME/.bashrc
sudo echo "# FLEXPART directory" >> /root/.bashrc
sudo echo FLEX_DIR=$FLEX_DIR >> /root/.bashrc
sudo echo "" >> /root/.bashrc
source /root/.bashrc
sudo mkdir $FLEX_DIR/preprocess/flex_extract/work
sudo cp -r $FLEX_DIR/src $FLEX_DIR/src2
cd $FLEX_DIR/src2
sudo rm makefile
sudo cp $HOME/flex_install/makefile makefile
sudo make -s -j 2 ncf=yes

# Perform tests.
cd $HOME/flex_install
# Test Eccodes.
$CONDA_FP -m eccodes selfcheck
# Test Python libraries.
$CONDA_FP flex_check_1.py
# Test ECMWF-API.
$CONDA_FP flex_check_2.py
# Test CDSAPI
$CONDA_FP flex_check_3.py
sudo rm download_cdsapi.grib
sudo rm download_erainterim_ecmwfapi.grib
cd /usr/local/flex_extract/Testing/Installation/Calc_etadot
# Test calc_etadot, from flex_part.
sudo ../../../Source/Fortran/calc_etadot
# Test FLEXPART without arguments.
cd $FLEX_DIR
sudo ./src2/FLEXPART
# Test flex_extract with a simple request.
sudo $CONDA_FP $FLEX_SUBMIT --controlfile=CONTROL_EI.public --start_date=20120101 --public=1 --inputdir=$FLEX_INPUT --outputdir=$FLEX_OUTPUT
sudo rm $FLEX_OUTPUT/*
# Test FLEXPART with a simple run.
cd $HOME/flex_install
sudo mkdir output_1
# Run this command to download the files directly.
#sudo $CONDA_FP $FLEX_SUBMIT --controlfile=$HOME/flex_install/CONTROL_EI.public --start_date=20120101 --public=1 --inputdir=$FLEX_INPUT --outputdir=$FLEX_OUTPUT
sudo $FLEX_DIR/src2/FLEXPART pathnames

# Anaconda installation may remove the path to execute explorer.exe in WSL virtual machines.
# It may be necessary to run source ~/.bashrc after script completion.
source /root/.bashrc
if [ $win == true ]
    then
        sudo echo "# Windows PATH in WSL" >> $HOME/.bashrc
        sudo echo export PATH="/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:$PATH" >> $HOME/.bashrc
        sudo echo "" >> $HOME/.bashrc
        sudo echo "# Windows PATH in WSL" >> /root/.bashrc
        sudo echo export PATH="/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:$PATH" >> /root/.bashrc
        sudo echo "" >> /root/.bashrc
fi
cd $HOME
echo
echo FLEXPART IS INSTALLED!
