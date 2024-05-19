#!/bin/bash

# This script installs a custom enviroment based on the ZSH Shell. 
# In addition it installs the following packages:

# - [ZSH](https://www.zsh.org/)
#   - [Oh My Zsh](https://ohmyz.sh/)
#   - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
# - [Command-not-found](https://tracker.debian.org/pkg/command-not-found)
# - [Byobu](https://www.byobu.org/)
# - [LSDeluxe](https://github.com/lsd-rs/lsd)
# - [Bat](https://github.com/sharkdp/bat)
# - [Duf](https://github.com/muesli/duf)
# - [Htop](https://htop.dev/)
# - [Btop](https://github.com/aristocratos/btop)
# - [Wget](https://www.gnu.org/software/wget/)
# - [cURL](https://curl.se/)
# - [Git](https://git-scm.com/)
# - [tldr-pages](https://github.com/tldr-pages/tldr)
# - [Sakura](https://github.com/dabisu/sakura)
# - [GParted](https://gparted.org/)
#
# More information on https://github.com/fellipec/customshell
#


#Make sure the system is updated
echo -e "================================="
echo -e "Configuring the custom enviroment"
echo -e "================================="
echo -e "\n\nUpdating the system..."
sudo apt update
sudo apt upgrade
sudo apt autoremove

#Install the packages that work on CLI
echo -e "\n\nInstalling packages..."
INSTALL_PKGS="zsh zsh-common zsh-doc zsh-autosuggestions command-not-found byobu lsd bat duf htop btop wget curl git tldr"
for i in $INSTALL_PKGS; do
    if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
        echo -e "\n Installing $i"
        sudo apt-get install -y $i
    fi
done
#yt-dlp from the repos are not always update
echo -e "\nInstalling/updating yt-dlp..."
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp --output /usr/local/bin/yt-dlp

#before tldr can be used, it needs to be updated
if [[ $(dpkg-query -W -f='${Status}' tldr 2>/dev/null | grep -c "ok installed") -eq 1 ]]; then 
    echo -e "\nUpdating tldr..."
    tldr --update
fi

#Install the GUI apps only if in a x11 or wayland session
if [[ $XDG_SESSION_TYPE == 'x11' || $XDG_SESSION_TYPE == 'wayland' ]]; then
    echo -e "\n\nSession ${XDG_SESSION_TYPE} detected, installing gui apps..."
    INSTALL_PKGS_GUI="sakura alacritty gparted"
    for i in $INSTALL_PKGS_GUI; do
        if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
            echo -e "\n Installing $i"
            sudo apt-get install -y $i
        fi
    done

    # Check if sakura or alacritty got installed and download
    # the configuration and make it the default terminal if it was installed
    if command -v sakura &> /dev/null
        then
            echo -e "\n\nConfiguring Sakura terminal"
            if ! [[ -e ~/.config/sakura ]]; then
                mkdir ~/.config/sakura
            fi
            curl -L https://raw.githubusercontent.com/fellipec/customshell/main/sakura.conf --output ~/.config/sakura/sakura.conf
            sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
            gsettings set org.cinnamon.desktop.default-applications.terminal exec 'sakura'
    fi

    if command -v alacritty &> /dev/null
        then
            echo -e "\n\nConfiguring Alacritty terminal"
            if ! [[ -e ~/.config/alacritty ]]; then
                mkdir ~/.config/alacritty
            fi
            curl -L https://raw.githubusercontent.com/fellipec/customshell/main/alacritty.toml --output ~/.config/alacritty/alacritty.toml
            sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
            gsettings set org.cinnamon.desktop.default-applications.terminal exec 'alacritty'
    fi



    # Install or update the Powerlevel10k recommended font
    echo -e "\n\nInstalling fonts..."
    mkdir ~/.fonts
    curl --retry 5 -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz | tar xJ --directory=$HOME/.fonts
    fc-cache
    gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font 11'
    gsettings set org.mate.interface monospace-font-name 'MesloLGS Nerd Font 11'

fi

#Backups the current bashrc and zshrc
echo -e "\n\nBackuping current config..."
cp ~/.bashrc ~/.bashrc.bkp
cp ~/.zshrc ~/.zshrc.bkp

#Checks for oh-my-zsh and install if needed
if ! [[ -e ~/.oh-my-zsh ]]; then
    echo -e "\n\nInstalling Oh My Zsh! \n Type exit after install is completed"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo -e "\nOh My Zsh already installed, skipping..."
fi

#Checks for Powerlevel10k and install if needed
if ! [[ -e ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
    echo -e "\n\nInstalling Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo -e "\n\nPowerlevel10k already installed, skipping..."
fi

#Download the custom configuration for ZSH and Powerlevel10k
echo -e "\n\nDownloading new configuration..."
curl -L https://raw.githubusercontent.com/fellipec/customshell/main/zshrc --output ~/.zshrc
curl -L https://raw.githubusercontent.com/fellipec/customshell/main/bashrc --output ~/.bashrc


#Change the default shell to ZSH (If is not already)
if [[ $SHELL != '/usr/bin/zsh' ]]; then
    echo -e "\n\nChanging the default shell to zsh..."
    chsh -s $(which zsh)
fi

#Checks for the Euro sign € option
#Remember to check when the eurosign:E (on 4h) gets implemented from freedesktop to 
#change the appropriate file. 
#For Wayland, needs to use the GUI.
if ! [[ -e /etc/X11/xorg.conf.d/99-abnteuro.conf ]]; then
    echo -e "\nInstalling € configuration"
    sudo curl -L https://raw.githubusercontent.com/fellipec/customshell/main/99-abnteuro.conf --output /etc/X11/xorg.conf.d/99-abnteuro.conf
fi

#Checks for autoenv and installs
#Checks for Powerlevel10k and install if needed
if ! [[ -e ~/.autoenv ]]; then
    echo -e "\n\nInstalling autoenv..."
    git clone 'https://github.com/hyperupcall/autoenv' ~/.autoenv
else
    echo -e "\n\nautoenv already installed, skipping..."
fi


#User selection of the Powerlevel10k theme. 
echo -e "\n\nChoose the p10k config:\n"
echo -e "    1) Black (default)"
echo -e "    2) Color"
echo -e "    3) Laptop"
echo -e "    4) Full"

read -p "Pick an option: " PTKFLAVOR

if [[ $PTKFLAVOR == '2' ]]; then
    echo -e "Copy Powerlevel 10k Color config..."
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.color --output ~/.p10k.zsh
elif [[ $PTKFLAVOR == '3' ]]; then
    echo -e "Copy Powerlevel 10k Laptop config..."
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.laptop --output ~/.p10k.zsh
elif [[ $PTKFLAVOR == '4' ]]; then
    echo -e "Copy Powerlevel 10k Full config..."
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.full --output ~/.p10k.zsh
else
    echo -e "Copy Powerlevel 10k Black config..."
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.black --output ~/.p10k.zsh
fi

# User selection to copy the Dracula theme
if [[ $XDG_SESSION_TYPE == 'x11' || $XDG_SESSION_TYPE == 'wayland' ]]; then

    echo -e "Install/Update Dracula Theme?"
    read -p "y/[n]" INST_DRACULA

    if [[ $INST_DRACULA == 'y' ]]; then
        cd $HOME
        if ! [[ -e ~/.icons ]]; then
            mkdir .icons
        fi
        if ! [[ -e ~/.themes ]]; then
            mkdir .themes
        fi
        cd $HOME/.themes
        curl -L https://github.com/dracula/gtk/releases/latest/download/Dracula.tar.xz | tar -xJf -
        cd $HOME/.icons
        curl -L https://github.com/dracula/gtk/releases/latest/download/Dracula-cursors.tar.xz | tar -xJf -
        git clone --depth 1 https://github.com/vinceliuice/Tela-circle-icon-theme.git
        cd Tela-circle-icon-theme
        ./install.sh -d $HOME/.icons dracula
        cd ..
        rm -rf Tela-circle-icon-theme
        gsettings set org.cinnamon.desktop.interface gtk-theme Dracula-slim-standard-buttons
        gsettings set org.cinnamon.desktop.wm.preferences theme Dracula-slim-standard-buttons 
        gsettings set org.cinnamon.desktop.interface cursor-theme Dracula-cursors
        gsettings set org.cinnamon.theme name Dracula-slim-standard-buttons
        gsettings set org.cinnamon.desktop.interface icon-theme Tela-circle-dracula
        gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', 'XF86ScreenSaver']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l']"
        gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Primary><Alt>l']"
    else
        echo -e "Ignoring Dracula theme\n"
    fi
fi

echo -e "\n"
echo -e "======================"
echo -e "Instalation completed!"
echo -e "======================"
echo -e "\n"