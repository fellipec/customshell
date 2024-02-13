#!/bin/bash

#
echo -e "================================="
echo -e "Configuring the custom enviroment"
echo -e "================================="
echo -e "\n\nUpdating the system..."
sudo apt update
sudo apt upgrade
sudo apt autoremove


echo -e "\n\nInstalling packages..."
INSTALL_PKGS="zsh zsh-common zsh-doc zsh-autosuggestions command-not-found byobu lsd bat duf htop btop wget curl git tldr"
for i in $INSTALL_PKGS; do
    if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
        echo -e "\n Installing $i"
        sudo apt-get install -y $i
    fi
done
#yt-dlp from the repos are not always update
echo -e "\nInstalling yt-dlp..."
sudo curl https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp --output /usr/local/bin/yt-dlp
#before tldr can be used, it needs to be updated
echo -e "\nUpdating tldr..."
tldr --update

#Install the GUI apps only if in a x11 or wayland session
if [[ $XDG_SESSION_TYPE == 'x11' || $XDG_SESSION_TYPE == 'wayland' ]]; then
    echo -e "\n\nSession ${XDG_SESSION_TYPE} detected, installing gui apps..."
    INSTALL_PKGS_GUI="sakura gparted"
    for i in $INSTALL_PKGS_GUI; do
        if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
            echo -e "\n Installing $i"
            sudo apt-get install -y $i
        fi
    done
    if [[ $(dpkg-query -W -f='${Status}' sakura 2>/dev/null | grep -c "ok installed") -eq 1 ]]; then 
        echo -e "\n\nConfiguring Sakura terminal"
        if ! [[ -e ~/.config/sakura ]]; then
            mkdir ~/.config/sakura
        fi
        curl https://clementine.fellipec.com/cs/sakura.conf --output ~/.config/sakura/sakura.conf
        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
    fi

    #Checks and install the Powerlevel10k recommended font
    if ! [[ -e ~/.fonts/MesloLGS\ NF\ Regular.ttf ]]; then
        echo -e "\n\nInstalling fonts..."
        mkdir ~/.fonts
        curl --retry 5 https://clementine.fellipec.com/cs/fonts.tar.gz | tar xz --directory=$HOME/.fonts
        fc-cache
    else
        echo -e "\n\nFonts installed, skipping"
    fi
fi

echo -e "\n\nBackuping current config..."
cp ~/.bashrc ~/.bashrc.bkp
cp ~/.zshrc ~/.zshrc.bkp

if ! [[ -e ~/.oh-my-zsh ]]; then
    echo -e "\n\nInstalling Oh My Zsh! \n Type exit after install is completed"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo -e "\nOh My Zsh already installed, skipping..."
fi

if ! [[ -e ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
    echo -e "\n\nInstalling Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo -e "\n\nPowerlevel10k already installed, skipping..."
fi


echo -e "\n\nDownloading new configuration..."
curl https://clementine.fellipec.com/cs/zshrc --output ~/.zshrc
curl https://clementine.fellipec.com/cs/bashrc --output ~/.bashrc



if [[ $SHELL != '/usr/bin/zsh' ]]; then
    echo -e "\n\nChanging the default shell to zsh..."
    chsh -s $(which zsh)
fi

echo -e "\n\nChoose the p10k config:\n"
echo -e "    1) Black (default)"
echo -e "    2) Color"
echo -e "    3) Laptop"
echo -e "    4) Full"


read -p "Pick an option: " PTKFLAVOR

if [[ $PTKFLAVOR == '2' ]]; then
    echo -e "Copy Powerlevel 10k Color config..."
    curl https://clementine.fellipec.com/cs/p10k.zsh.color --output ~/.p10k.zsh
elif [[ $PTKFLAVOR == '3' ]]; then
    echo -e "Copy Powerlevel 10k Laptop config..."
    curl https://clementine.fellipec.com/cs/p10k.zsh.laptop --output ~/.p10k.zsh
elif [[ $PTKFLAVOR == '4' ]]; then
    echo -e "Copy Powerlevel 10k Full config..."
    curl https://clementine.fellipec.com/cs/p10k.zsh.full --output ~/.p10k.zsh
else
    echo -e "Copy Powerlevel 10k Black config..."
    curl https://clementine.fellipec.com/cs/p10k.zsh.black --output ~/.p10k.zsh
fi

echo -e "Install autofs?"

read -p "y/[n]" INST_AUTOFS

if [[ $INST_AUTOFS == 'y' ]]; then
    sudo apt install autofs
    echo -e "/net    -hosts -fstype=nfs4,rw" | sudo tee -a /etc/auto.master
    echo -e "192.168.100.1 scarlett.lan" | sudo tee -a /etc/hosts
    sudo mkdir /net
    sudo systemctl restart autofs.service
else
    echo -e "Ignoring autofs install\n"
fi


echo -e "\n"
echo -e "========================"
echo -e "Post-installation tasks:"
echo -e "========================"
echo -e "\n"
echo -e "    - Configure the MesloLGS font in your graphical terminal."
echo -e "    - Set up your graphical terminal to use the default shell or /bin/usr/zsh."