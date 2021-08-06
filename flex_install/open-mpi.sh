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

source $CONDA_SOURCE/etc/profile.d/conda.sh

# Install Open MPI
cd $HOME
source /root/.bashrc
wget -q https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz
tar -xzf openmpi-4.1.1.tar.gz
cd openmpi-4.1.1
./configure --prefix=/usr/local
make -s -j 2
make check
sudo make -s -j 2 install
cd $HOME
#sudo cp /usr/local/lib/libopen-pal.so.40 /usr/lib
sudo cp -r /usr/local/lib/* /usr/lib
#sudo cp -r /usr/local/bin/* /usr/local/bin
sudo rm openmpi-4.1.1.tar.gz
sudo rm -r openmpi-4.1.1

# Install FLEXPART MPI.
# Normal version: src2.
# MPI version: src3.
FLEX_DIR="/usr/local/flexpart_v10.4"
cd $FLEX_DIR
sudo cp -r src src3
cd src3
sudo rm makefile
sudo cp $HOME/flex_install/makefile makefile
sudo make -s -j 2 mpi ncf=yes

# Perform tests on FLEXPART MPI.
# Test FLEXPART without arguments.
cd $FLEX_DIR
sudo ./src3/FLEXPART_MPI
# Test FLEXPART with a simple run.
cd $HOME/flex_install
sudo mkdir output_2
# Run this command to download the files directly.
#sudo $CONDA_FP $FLEX_SUBMIT --controlfile=$HOME/flex_install/CONTROL_EI.public --start_date=20120101 --public=1 --inputdir=$FLEX_INPUT --outputdir=$FLEX_OUTPUT
sudo $FLEX_DIR/src3/FLEXPART_MPI pathnames_2

echo
echo FLEXPART IS INSTALLED!
