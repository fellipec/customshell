#!/bin/bash
sudo apt update
sudo apt install zsh zsh-common zsh-doc zsh-autosuggestions command-not-found
cp ~/.bashrc ~/.bashrc.bkp
cp ~/.zshrc ~/.zshrc.bkp
cp bashrc ~/.bashrc
cp zshrc ~/.zshrc
chsh -s /bin/zsh
byobu-enable
