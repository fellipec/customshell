#!/bin/bash

# This script installs a custom environment and tools for Debian and Mint installs. 
#
# More information on https://github.com/fellipec/customshell or on README.md file
# Luiz Fellipe Carneiro 2024

# Make sure the system is updated
echo -e "=================================="
echo -e "Configuring the custom environment"
echo -e "=================================="
echo -e "\n\nUpdating the system..."
sudo apt update
sudo apt upgrade
sudo apt autoremove

# Install the packages that work on CLI
echo -e "\n\nInstalling packages..."
INSTALL_PKGS="command-not-found byobu lsd bat duf htop btop wget curl git tldr aspell-br rsync fzf fd-find vim ffmpeg"
for i in $INSTALL_PKGS; do
    if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
        echo -e "\n Installing $i"
        sudo apt-get install -y $i
    fi
done

# yt-dlp from the repos is always an ancient version. Install the version from the repo that is up-to-date
echo -e "\nInstalling/updating yt-dlp..."
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp --output /usr/local/bin/yt-dlp
sudo chmod +x /usr/local/bin/yt-dlp

# before tldr can be used, it needs to be updated
if [[ $(dpkg-query -W -f='${Status}' tldr 2>/dev/null | grep -c "ok installed") -eq 1 ]]; then 
    echo -e "\nUpdating tldr..."
    tldr --update
fi

# Install the GUI apps only if in a x11 or wayland session
if [[ $XDG_SESSION_TYPE == 'x11' || $XDG_SESSION_TYPE == 'wayland' ]]; then
    echo -e "\n\nSession ${XDG_SESSION_TYPE} detected, installing gui apps..."
    INSTALL_PKGS_GUI="sakura alacritty gparted fonts-noto flameshot"
    for i in $INSTALL_PKGS_GUI; do
        if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
            echo -e "\n Installing $i"
            sudo apt-get install -y $i
        fi
    done

    # Check if sakura or alacritty got installed and download
    # the configuration and make it the default terminal if it was installed
    # Alacritty is last because it's the prefered terminal application
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
            # Get Alacritty version
            # Older versions of Alacritty that ships with Debian up to Trixie use yml config
            # Newer versions user toml config
            VERSION=$(alacritty --version | awk '{print $2}')
            # Function to compare versions
            version_ge() {
                [[ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ]]
            }
            # Commands to run
            COMMAND_IF_GE="curl -L https://raw.githubusercontent.com/fellipec/customshell/main/alacritty.toml --output ~/.config/alacritty/alacritty.toml"
            COMMAND_IF_LT="curl -L https://raw.githubusercontent.com/fellipec/customshell/main/alacritty.yml --output ~/.config/alacritty/alacritty.yml"

            # Compare versions and run the appropriate command
            if version_ge "$VERSION" "0.13"; then
                eval "$COMMAND_IF_GE"
            else
                eval "$COMMAND_IF_LT"
            fi
            sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
            gsettings set org.cinnamon.desktop.default-applications.terminal exec 'alacritty'
    fi

    # Install or update the Powerlevel10k recommended font
    echo -e "\n\nInstalling fonts..."
    if ! [[ -e ~/.fonts ]]; then
        mkdir ~/.fonts
    fi
    curl --retry 5 -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz | tar xJ --directory=$HOME/.fonts
    fc-cache
    gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font 11'
    gsettings set org.mate.interface monospace-font-name 'MesloLGS Nerd Font 11'

    # Checks for the Euro sign € option
    # Remember to check when the eurosign:E (on 4h) gets implemented from freedesktop to 
    # change the appropriate file. 
    # For Wayland, needs to use the GUI.
    if ! [[ -e /etc/X11/xorg.conf.d/99-abnteuro.conf ]]; then
        echo -e "\nInstalling € configuration"
        sudo curl -L https://raw.githubusercontent.com/fellipec/customshell/main/99-abnteuro.conf --output /etc/X11/xorg.conf.d/99-abnteuro.conf
    fi
fi

# Installs zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Backups the current bashrc and zshrc
echo -e "\n\nBackuping current config..."
cp ~/.bashrc ~/.bashrc.bkp
cp ~/.zshrc ~/.zshrc.bkp

#User selection of shell
echo -e "\n\nInstall and configure zsh and oh my zsh?:\n"
read -p "[y/N]: " ZSHELL

if [[ $ZSHELL == 'y' ]]; then

    echo -e "\n\nInstalling packages..."
    INSTALL_PKGS="zsh zsh-common zsh-doc zsh-autosuggestions zsh-syntax-highlighting"
    for i in $INSTALL_PKGS; do
        if [[ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
            echo -e "\n Installing $i"
            sudo apt-get install -y $i
        fi
    done

    # Checks for oh-my-zsh and install if needed
    if ! [[ -e ~/.oh-my-zsh ]]; then
        echo -e "\n\nInstalling Oh My Zsh! \n Type exit after install is completed"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo -e "\nOh My Zsh already installed, skipping..."
    fi

    # Checks for Powerlevel10k and install if needed
    if ! [[ -e ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
        echo -e "\n\nInstalling Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    else
        echo -e "\n\nPowerlevel10k already installed, skipping..."
    fi


    # Download the custom configuration for ZSH and Powerlevel10k, and nano
    echo -e "\n\nDownloading new configuration..."
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/zshrc --output ~/.zshrc
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/bashrc --output ~/.bashrc
    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/nanorc --output ~/.nanorc

    # Change the default shell to ZSH (If is not already)
    if [[ $SHELL != '/usr/bin/zsh' ]]; then
        echo -e "\n\nChanging the default shell to zsh..."
        chsh -s $(which zsh)
    fi

    #User selection of the Powerlevel10k theme. 
    echo -e "\n\nChoose the p10k config:\n"
    echo -e "    0) Don't change (defaut)"
    echo -e "    1) Black"
    echo -e "    2) Color"
    echo -e "    3) Laptop"
    echo -e "    4) Full"
    echo -e "    5) Simple"

    read -p "Pick an option: " PTKFLAVOR

    if [[ $PTKFLAVOR == '1' ]]; then
        echo -e "Copy Powerlevel 10k Black config..."
        curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.black --output ~/.p10k.zsh
    elif [[ $PTKFLAVOR == '2' ]]; then
        echo -e "Copy Powerlevel 10k Color config..."
        curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.color --output ~/.p10k.zsh
    elif [[ $PTKFLAVOR == '3' ]]; then
        echo -e "Copy Powerlevel 10k Laptop config..."
        curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.laptop --output ~/.p10k.zsh
    elif [[ $PTKFLAVOR == '4' ]]; then
        echo -e "Copy Powerlevel 10k Full config..."
        curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.full --output ~/.p10k.zsh
    elif [[ $PTKFLAVOR == '5' ]]; then
        echo -e "Copy Powerlevel 10k Simple config..."
        curl -L https://raw.githubusercontent.com/fellipec/customshell/main/p10k.zsh.simple --output ~/.p10k.zsh
        sed -i 's/alias ls="lsd"/alias ls="lsd --icon never"/' .zshrc
    else
        echo -e "Don't touch the p10k theme"
    fi

fi

# Theme and GUI options
# =====================

# User selection to copy the Dracula theme
if [[ $XDG_SESSION_TYPE == 'x11' || $XDG_SESSION_TYPE == 'wayland' ]]; then

    echo -e "Install/Update Dracula Theme and configure the Cinnamon GUI?"
    echo -e "ATTENTION: Only tested with Cinnamon Desktop"
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
        ./install.sh -d $HOME/.icons 
        ./install.sh -d $HOME/.icons dracula
        ./install.sh -d $HOME/.icons blue
        ./install.sh -d $HOME/.icons orange
        ./install.sh -d $HOME/.icons black
        cd ..
        rm -rf Tela-circle-icon-theme
        gsettings set org.x.apps.portal color-scheme prefer-dark
        gsettings set org.cinnamon.desktop.interface clock-show-date true
        gsettings set org.gnome.desktop.interface clock-show-date true
        gsettings set org.cinnamon.desktop.interface cursor-theme Dracula-cursors
        gsettings set org.cinnamon.desktop.interface icon-theme Tela-circle
        gsettings set org.cinnamon.desktop.interface gtk-theme Mint-Y-Dark-Aqua
        gsettings set org.cinnamon.desktop.wm.preferences theme Mint-Y-Dark-Aqua
        gsettings set org.cinnamon.theme name Mint-Y-Dark-Aqua

        gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', 'XF86ScreenSaver']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l']"
        gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Primary><Alt>l']"
        if command -v flatpak &> /dev/null ; then
            sudo flatpak override --filesystem=$HOME/.themes
            sudo flatpak override --filesystem=$HOME/.icons
            sudo flatpak override --env=GTK_THEME=Mint-Y-Dark-Aqua:dark
            sudo flatpak override --env=ICON_THEME=Tela-circle
            sudo flatpak override --env=QT_STYLE_OVERRIDE=Mint-Y-Dark-Aqua
            sudo flatpak override --env=GTK_STYLE_OVERRIDE=Mint-Y-Dark-Aqua
        fi


        # At this point the theme is installed but not in use
        # Ask user to activate it, setting the theme active and overriding the flatpak theme
        echo -e "Use Dracula Theme?"
        read -p "y/[n]" USE_DRACULA

        if [[ $USE_DRACULA == 'y' ]]; then
            gsettings set org.cinnamon.desktop.interface gtk-theme Dracula-slim-standard-buttons
            gsettings set org.cinnamon.desktop.wm.preferences theme Dracula-slim-standard-buttons 
            gsettings set org.cinnamon.desktop.interface cursor-theme Dracula-cursors
            gsettings set org.cinnamon.theme name Dracula-slim-standard-buttons
            gsettings set org.cinnamon.desktop.interface icon-theme Tela-circle-dracula
            if command -v flatpak &> /dev/null ; then
                sudo flatpak override --filesystem=$HOME/.themes
                sudo flatpak override --filesystem=$HOME/.icons
                sudo flatpak override --env=GTK_THEME=Dracula-slim-standard-buttons:dark
                sudo flatpak override --env=ICON_THEME=Tela-circle-dracula
                sudo flatpak override --env=QT_STYLE_OVERRIDE=Dracula-slim-standard-buttons
                sudo flatpak override --env=GTK_STYLE_OVERRIDE=Dracula-slim-standard-buttons
            fi
        else
            echo -e "Dracula theme installed but not in use\n"
        fi

    else
        echo -e "Ignoring Dracula theme and GUI settings\n"
    fi


    echo -e "Configure Flameshot Print Screen Shortcut?"
    echo -e "This will configure the Print Screen key to open Flameshot AND ERASE ALL OTHER CUSTOM KEYBINDINGS"
    read -p "y/[n]" FS_SHORTCUT

    if [[ $FS_SHORTCUT == 'y' ]]; then
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['Print']"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'Screen Shot with Flameshot'"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'flameshot gui'"
        dconf write /org/cinnamon/desktop/keybindings/custom-list "['custom0', '__dummy__']"
    fi


fi



#User selection to install vim config
echo -e "\n\nDownload VIM config?:\n"
read -p "[y/N]: " DLVIM
if [[ $DLVIM == 'y' ]]; then

    curl -L https://raw.githubusercontent.com/fellipec/customshell/main/vim_config.tar.gz --output ~/vim_config.tar.gz
    tar -xvzf ~/vim_config.tar.gz -C ~/
    rm ~/vim_config.tar.gz
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    sudo cp -r ~/.vim /root
    sudo cp ~/.vimrc /root
fi

#User selection of /tmp to be on RAM
echo -e "\n\nConfigure /tmp to RAM?:\n"
read -p "[y/N]: " TMPR

if [[ $TMPR == 'y' ]]; then
    sudo cp /usr/share/systemd/tmp.mount /etc/systemd/system
    sudo systemctl enable tmp.mount
fi

# User selection of journalctl to be volatile
echo -e "\n\nConfigure journalctl to Volatile?:\n"
read -p "[y/N]: " JCTLV

if [[ $JCTLV == 'y' ]]; then

    FILE="/etc/systemd/journald.conf"

    # Check if any line starts with "Storage"
    if ! grep -q "^Storage" "$FILE"; then
        # If no such line exists, append "Storage=volatile"
        echo "Storage=volatile" | sudo tee -a "$FILE"
        echo "Added 'Storage=volatile' to $FILE"
    else
        echo "Already have Storage config $FILE. Will do nothing"
    fi

    # Optionally install log2ram 
    echo -e "\n\nInstall log2ram?:\n"
    read -p "[y/N]: " ILTR

    if [[ $ILTR == 'y' ]]; then
        sudo journalctl --vacuum-size=100M
        sudo rm "/var/log/*.gz"

        curl -L https://github.com/azlux/log2ram/archive/master.tar.gz | tar zxf -
        cd log2ram-master
        chmod +x install.sh && sudo ./install.sh
        cd ..
        rm -r log2ram-master

        sudo curl -L https://raw.githubusercontent.com/fellipec/customshell/main/log2ram.conf --output /etc/log2ram.conf

        # Path to the log2ram config file
        CONFIG_FILE="/etc/log2ram.conf"
        # Get the total system RAM in MB
        TOTAL_RAM=$(free -m | awk '/^Mem/{print $2}')

        # Calculate SIZE as 15% of total RAM
        SIZE=$(echo "scale=0; $TOTAL_RAM * 0.15 / 1" | bc)

        # Calculate LOG_DISK_SIZE as 2.5 times SIZE
        LOG_DISK_SIZE=$(echo "scale=0; $SIZE * 2.5 / 1" | bc)

        SIZE="${SIZE}M"
        LOG_DISK_SIZE="${LOG_DISK_SIZE}M"

        # Update the config file
        sudo sed -i "s/^SIZE=.*/SIZE=${SIZE}/" "$CONFIG_FILE"
        sudo sed -i "s/^LOG_DISK_SIZE=.*/LOG_DISK_SIZE=${LOG_DISK_SIZE}/" "$CONFIG_FILE"
        sudo sed -i "s/^MAIL=.*/MAIL=false/" "$CONFIG_FILE"
        sudo sed -i "s/^ZL2R=.*/ZL2R=true/" "$CONFIG_FILE"

        echo "Updated $CONFIG_FILE:"
        echo "SIZE=$SIZE"
        echo "LOG_DISK_SIZE=$LOG_DISK_SIZE"

    fi

fi 


echo -e "\n"
echo -e "======================"
echo -e "Instalation completed!"
echo -e "======================"
echo -e "\n"

if ! command -v lsd &> /dev/null ; then
    echo -e "\n"
    echo -e "Your distro still don't have LSD available. Install manually from https://github.com/lsd-rs/lsd"
fi

