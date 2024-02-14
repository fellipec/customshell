# Custom ZSH Environment 

This script installs a custom enviroment based on the ZSH Shell. 
In addition it installs the following packages:

- [ZSH](https://www.zsh.org/)
  - [Oh My Zsh](https://ohmyz.sh/)
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Command-not-found](https://tracker.debian.org/pkg/command-not-found)
- [Byobu](https://www.byobu.org/)
- [LSDeluxe](https://github.com/lsd-rs/lsd)
- [Bat](https://github.com/sharkdp/bat)
- [Duf](https://github.com/muesli/duf)
- [Htop](https://htop.dev/)
- [Btop](https://github.com/aristocratos/btop)
- [Wget](https://www.gnu.org/software/wget/)
- [cURL](https://curl.se/)
- [Git](https://git-scm.com/)
- [tldr-pages](https://github.com/tldr-pages/tldr)
- [Sakura](https://github.com/dabisu/sakura)
- [GParted](https://gparted.org/)

## Install

To install this custom enviroment, copy and paste the following code on a terminal:

`bash -c "$(curl -fsSL https://raw.githubusercontent.com/fellipec/customshell/main/webinstall.sh)"`

or

`bash -c "$(wget https://raw.githubusercontent.com/fellipec/customshell/main/webinstall.sh -O -)"`

## Backup

Your original `.bashrc` and `.zshrc` files will be backuped with a `.bkp` extension

## Compatibility

This script was written to be executed on **Debian Bookworm** or newer. When running on Debian derivatives distros, check if all the packages could be installed.

## Configuration changes:

Besides replacing the `.bashrc` and `.zshrc` with custom ones, the following configurations are changed in the system:

- The default shell is changed to `/usr/bin/zsh`
- The default terminal is changed to Sakura
- Add xkboption `eurosign:e` to X11
- An alias redirect `ls` to `lsd`
- An alias redirect `cat` to `bat`
- An alias redirect `upd` to `sudo apt update && sudo apt upgrade`
- An alias redirect `tracert` to `traceroute` because I used Windows for decades and can't help myself.

## PowerLevel10k configuration

The install script will ask for your preferences for the Powerlevel10k theme. The options are:

#### Black (default)

![Preview of the Black config](img/black.png)


#### Color

![Preview of the Color config](img/color.png)


#### Full

![Preview of the Full config](img/full.png)


#### Laptop

![Preview of the Laptop config](img/laptop.png)


## License

This repository includes the beautiful [MesloLGS NF font](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#meslo-nerd-font-patched-for-powerlevel10k) and it is released under the terms of [Apache License](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20License.txt).

Unless otherwise stated, this repository is licensed under the terms of the [GPL 2.0](https://www.gnu.org/licenses/old-licenses/lgpl-2.0.html).
