# install my default systadmin/dev packages

# Requirements: apt

# toadd: wemux?


# install if apt
sudo apt update

sudo apt install curl neofetch nmap snapd tmux wireshark python3 python3-pip lolcat htop proxychains4 python3-full

# install snapd core
sudo snap install core

# googlr tool https://github.com/Astranno/googlr
curl -fsSL https://raw.githubusercontent.com/Astranno/googlr/master/Install%20Scripts/install.sh | sudo sh

# histstat tool https://github.com/vesche/histstat
sudo pip install histstat

# bashtop tool
sudo snap install bashtop
