#!/bin/bash

# install tmux
sudo add-apt-repository ppa:ytvwld/asciiquarium
sudo apt-get update
sudo apt-get install -y tmux
sudo apt-get install -y cmatrix
sudo apt-get install -y asciiquarium
curl -fsSL https://get.tmuxai.dev | bash

# install tmux config
tmux_file=$HOME"/.tmux.conf"
if [ -f $tmux_file ]; then
    rm -rf $tmux_file
fi
ln -s ${PWD}/tmux.conf $tmux_file

# install asciiquarium
saver_file=`which asciiquarium`
if [ -z $saver_file ]; then
    sudo ln /usr/games/asciiquarium /usr/bin/asciiquarium
fi

# insall tmux plugins
tmux_plugin=${PWD}"/plugins"
if [ ! -d $tmux_plugin ]; then
    mkdir -p $tmux_plugin
    git clone https://github.com/tmux-plugins/tpm $tmux_plugin/tpm
    git clone https://github.com/tmux-plugins/tmux-sensible $tmux_plugin/tmux-sensible
    git clone https://github.com/tmux-plugins/tmux-resurrect $tmux_plugin/tmux-resurrect
    git clone https://github.com/tmux-plugins/tmux-yank $tmux_plugin/tmux-yank
    git clone https://github.com/nhdaly/tmux-better-mouse-mode $tmux_plugin/tmux-better-mouse-mode
    git clone https://github.com/NHDaly/tmux-scroll-copy-mode $tmux_plugin/tmux-scroll-copy-mode
fi
