# install my default sysadmin/dev packages
# Requirements: apt


# install if apt
sudo apt update

# package list
sudo apt install curl neofetch nmap snapd tmux wireshark python3 python3-pip lolcat htop proxychains4 python3-full git tree davfs2 cifs-utils ufw tightvncserver -y

# install snapd core
sudo snap install core

# googlr tool https://github.com/Astranno/googlr
#curl -fsSL https://raw.githubusercontent.com/Astranno/googlr/master/Install%20Scripts/install.sh | sudo sh

# bashtop tool
#sudo snap install bashtop

# vscode requirements
sudo apt install software-properties-common apt-transport-https wget


# setup ufw
sudo ufw allow 22
