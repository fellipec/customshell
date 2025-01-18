#!/bin/bash
curl -L https://raw.githubusercontent.com/fellipec/customshell/main/vim_config.tar.gz --output ~/vim_config.tar.gz
tar -xvzf ~/vim_config.tar.gz -C ~/
rm ~/vim_config.tar.gz
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sudo cp -r ~/.vim /root
sudo cp ~/.vimrc /root