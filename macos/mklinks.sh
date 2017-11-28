#!/bin/sh

ln -sf ~/gitroot/dotfiles/.zshrc ~/

dir=~/.config/tmux; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/.tmux.conf ~/
# ln -sf ~/gitroot/dotfiles/ranger/rc.conf ~/.config/ranger/
# ln -sf ~/gitroot/dotfiles/ranger/rifle.conf ~/.config/ranger/
# ln -sf ~/gitroot/dotfiles/ranger/scope.sh ~/.config/ranger/

dir=~/.config/vifm; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/vifm/vifmrc ~/.config/vifm/

dir=~/.config/peco; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/peco/config.json ~/.config/peco/

dir="${HOME}/Library/Application Support/Sublime Text 3/Packages/User"; [ ! -e "${dir}" ] && mkdir -p "${dir}"
ln -sf "${HOME}/gitroot/dotfiles/sublime/Default (OSX).sublime-keymap" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
ln -sf "${HOME}/gitroot/dotfiles/sublime/Package Control.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
ln -sf "${HOME}/gitroot/dotfiles/sublime/Preferences.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
ln -sf "${HOME}/gitroot/dotfiles/sublime/insert_date.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
ln -sf "${HOME}/gitroot/dotfiles/sublime/Ruby.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"

dir=~/.config/nvim; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/neovim/init.vim ~/.config/nvim/
