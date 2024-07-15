# Custom ZSH Environment 

This script installs a custom enviroment based on the ZSH Shell. 
In addition it installs the following packages:

- [ZSH](https://www.zsh.org/)
  - [Oh My Zsh](https://ohmyz.sh/)
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/)
- [Aspell](http://aspell.net/)
- [Bat](https://github.com/sharkdp/bat)
- [Btop](https://github.com/aristocratos/btop)
- [Byobu](https://www.byobu.org/)
- [Command-not-found](https://tracker.debian.org/pkg/command-not-found)
- [cURL](https://curl.se/)
- [Duf](https://github.com/muesli/duf)
- [fdfind](https://github.com/sharkdp/fd)
- [fonts-noto](https://notofonts.github.io/)
- [fzf](https://github.com/junegunn/fzf)
- [Git](https://git-scm.com/)
- [GnuPG](https://gnupg.org/)
- [GParted](https://gparted.org/)
- [Htop](https://htop.dev/)
- [LSDeluxe](https://github.com/lsd-rs/lsd)
- [Neovim](https://neovim.io/)
  - [Kickstart (Personal Fork)](https://github.com/fellipec/kickstart.nvim)
- [rsync](https://github.com/RsyncProject/rsync)
- [Sakura](https://github.com/dabisu/sakura)
- [tldr-pages](https://github.com/tldr-pages/tldr)
- [Wget](https://www.gnu.org/software/wget/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)

## Install

To install this custom environment, copy and paste the following code on a terminal:

`bash -c "$(curl -fsSL https://raw.githubusercontent.com/fellipec/customshell/main/webinstall.sh)"`

or

`bash -c "$(wget https://raw.githubusercontent.com/fellipec/customshell/main/webinstall.sh -O -)"`

## Backup

Your original `.bashrc` and `.zshrc` files will be backed up with a `.bkp` extension

## Compatibility

This script was written to be executed on **Debian Bookworm** or newer. When running on Debian derivatives distros, check if all the packages could be installed. It's tested with **Linux Mint 21.3** and partially on **LMDE 6** too.

## Configuration changes:

Besides replacing the `.bashrc` and `.zshrc` with custom ones, the following configurations are changed in the system:

- The default shell is changed to `/usr/bin/zsh`
- Oh My Zsh! is installed and with P10K Theme and some other convenience features
- Neovim installed with kickstart
- The default terminal is changed to Alacritty or Sakura if the former is not available
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

Unless otherwise stated, this repository is licensed under the terms of the [GPL 2.0](https://www.gnu.org/licenses/old-licenses/lgpl-2.0.html).
