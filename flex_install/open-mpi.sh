# Install Open MPI
cd $HOME
source /root/.bashrc
wget -q https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz
tar -xzf openmpi-4.1.1.tar.gz
cd openmpi-4.1.1
./configure --prefix=/usr/local
sudo make -s -j 2 all install
cd $HOME
sudo cp /usr/local/lib/libopen-pal.so.40 /usr/lib
sudo cp /usr/local/bin/* /usr/local/bin
sudo rm openmpi-4.1.1.tar.gz
sudo rm -r openmpi-4.1.1

# Install FLEXPART.
# Normal version: src2.
# MPI version: src3.
cd $FLEX_DIR
sudo cp -r src src3
cd src3
sudo rm makefile
sudo cp $HOME/flex_install/makefile makefile
sudo make -s -j 2 mpi ncf=yes

# Perform tests.
# Test FLEXPART without arguments.
cd $FLEX_DIR
sudo ./src3/FLEXPART
# Test FLEXPART with a simple run.
cd $HOME/flex_install
sudo mkdir output_2
# Run this command to download the files directly.
#sudo $CONDA_FP $FLEX_SUBMIT --controlfile=$HOME/flex_install/CONTROL_EI.public --start_date=20120101 --public=1 --inputdir=$FLEX_INPUT --outputdir=$FLEX_OUTPUT
sudo $FLEX_DIR/src3/FLEXPART pathnames_2