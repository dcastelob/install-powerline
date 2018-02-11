#!/bin/bash
# Instalacao do powerline
# Script adaptado para a instalação em Fedora
#

function msg()
{
	echo -e "\033[01;32m$@\033[01;37m"
}

function getDistro()
{
	cat /etc/*release*| grep -o -i -E "debian|ubuntu|centos|fedora|rhel" | tr [a-z] [A-Z] | uniq
}

function verificaRoot()
{
	if [ $(id -u) -ne 0 ]; then
		echo "Use sudo $0 "
		exit 1
	fi
}

function installPackages()
{
	
	
	msg "[info] Install packages, (verify sudo user): $DISTRO..."

	case "$DISTRO" in
		"UBUNTU"|"DEBIAN")
			sudo apt-get install vim-nox git python-pip && sudo pip install git+git://github.com/Lokaltog/powerline			
			;;
		"FEDORA"|"CENTOS"|"RHEL")

			sudo dnf install vim powerline powerline-fonts vim-powerline -y			
			;;
	esac
}

function getFonts()
{
	msg "[info] Get fonts for powerline..."
	
	case "$DISTRO" in
		"UBUNTU"|"DEBIAN")
			wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf 
			wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf 
			msg "Use sudo for copy fonts for $DISTRO..."
			sudo mv -f PowerlineSymbols.otf /usr/share/fonts/ 
			sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/
			sudo fc-cache -vf 

			;;
		"FEDORA"|"CENTOS"|"RHEL")

			wget https://github.com/powerline/powerline/blob/develop/font/10-powerline-symbols.conf
			wget https://github.com/powerline/powerline/blob/develop/font/PowerlineSymbols.otf

			if [ ! -d ~/.fonts ];then
				mkdir -p ~/.fonts
			fi
			mv -f PowerlineSymbols.otf ~/.fonts/
	
			if [ ! -d ~/.cache/fontconfig ];then
				mkdir -p ~/.cache/fontconfig
			fi
			mv -f 10-powerline-symbols.conf ~/.cache/fontconfig/

			fc-cache -vf ~/.fonts/
			;;
	esac	

}

function updatePowerlineConfig()
{

	msg "[info] Create powerline.conf ..."

	case "$DISTRO" in
		"UBUNTU"|"DEBIAN")
cat <<EOF>~/.powerline.conf
if [ -f /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh ]; 
then source /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh 
fi
EOF
			;;
		"FEDORA"|"CENTOS"|"RHEL")
cat <<EOF>~/.powerline.conf
if [ -f `which powerline-daemon` ]; then
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bash/powerline.sh
fi
EOF
			;;
	esac

echo 'source ~/.powerline.conf' >> ~/.bashrc

}

function configureVim()
{
	msg "[info] Configure powerline for vim..."

case "$DISTRO" in
		"UBUNTU"|"DEBIAN")
cat <<EOF >~/.vimrc
set rtp+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/vim/  " Always show statusline 
set laststatus=2  " Use 256 colours (Use this setting only if your terminal supports 256 colours) 
set t_Co=256
EOF
			;;
		"FEDORA"|"CENTOS"|"RHEL")
cat <<EOF >~/.vimrc
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256

EOF
			;;
esac

}

export DISTRO=$(getDistro)
getFonts
updatePowerlineConfig
configureVim

#verificaRoot
installPackages
msg "Finished. Close this terminal for update settings..."
exit 0


