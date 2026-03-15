# install my default sysadmin/dev packages
# Requirements: apt


# add sources
# Define the Debian version
DEBIAN_VERSION=$(lsb_release -cs)

# Add Tailscale's GPG key
curl -fsSL https://pkgs.tailscale.com/stable/debian/${DEBIAN_VERSION}.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
# Add Tailscale's repository
curl -fsSL https://pkgs.tailscale.com/stable/debian/${DEBIAN_VERSION}.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list


# install if apt
sudo apt update


# package list
sudo apt install curl neofetch nmap snapd tmux wireshark python3 python3-pip lolcat htop proxychains4 python3-full git tree davfs2 cifs-utils gawk ufw tightvncserver ncdu speedtest-cli tailscale -y

# install snapd core
#sudo snap install core

# googlr tool https://github.com/Astranno/googlr
#curl -fsSL https://raw.githubusercontent.com/Astranno/googlr/master/Install%20Scripts/install.sh | sudo sh

# bashtop tool
#sudo snap install bashtop

# vscode requirements
sudo apt install software-properties-common apt-transport-https wget -y

# setup ufw
sudo ufw allow 22

sudo apt autoremove -y

