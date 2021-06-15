# conda_setup.sh
#
#
# Creates conda environments for Goeviews and climate-indices.
# Either anaconda or miniconda must be already installed.
#
#
# Flags:
# -n: The name of the user for which FLEXPART will be installed.
# -c: The type of conda installation.
#     anaconda, anaconda3: Anaconda is already installed.
#     miniconda, conda:    Miniconda is already installed.

# Stop at first error.
set -e

# Default options for conda and user.
user="rodrigo"
conda="miniconda"

# Read arguments.
while getopts n:c: flag
do
    case "${flag}" in
        n) user=${OPTARG};;
        c) conda=${OPTARG};;
    esac
done

# Establish home directory.
HOME="/home/$user"
case $conda in
    anaconda|anaconda3)
        CONDA_DIR="$HOME/anaconda3";;
    miniconda|conda|*)
        CONDA_DIR="$HOME/miniconda";;
esac
source $CONDA_DIR/etc/profile.d/conda.sh

# Install git.
sudo apt-get update
sudo apt-get install git
yes | conda create -n gv

# Create environment named gv for geoviews.
conda activate gv
conda config --env --add channels pyviz
conda config --env --set channel_priority strict
yes | conda install python=3.7 geoviews descartes
yes | conda create -n ci python=3.8

# Create environment named ci for climate-indices.
conda activate ci
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict
yes | pip install climate-indices
yes | conda install nco
conda activate base
echo
echo Geoviews and climate-indices are configured!