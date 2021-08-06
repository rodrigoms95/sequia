# jekyll_install.sh
#
#
# Installs Jekyll on an Ubuntu/Debian distribution.
#
#
# Flags:
# -n: The name of the user for which FLEXPART will be installed.

# Stop at first error.
set -e

# Default options for user.
user="rodrigo"

# Read arguments.
while getopts n: flag
do
    case "${flag}" in
        n) user=${OPTARG};;
    esac
done

# Establish home directory.
HOME="/home/$user"
source /root/.bashrc

# Install Jekyll.
sudo apt-get update
sudo apt-get -y install ruby-full build-essential zlib1g-dev git
echo '' >> /root/.bashrc
echo '# Install Ruby Gems to $HOME/gems' >> /root/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> /root/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> /root/.bashrc
source /root/.bashrc
echo '' >> $HOME/.bashrc
echo '# Install Ruby Gems to $HOME/gems' >> $HOME/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> $HOME/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> $HOME/.bashrc
source /root/.bashrc
gem install jekyll bundler
echo
echo Jekyll is installed!
# It may be necessary to run source ~/.bashrc after script completion.