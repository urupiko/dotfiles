#!/bin/sh

ln -sf ~/gitroot/dotfiles/.zshrc ~/.zshrc

ln -sf ~/gitroot/dotfiles/ranger/rc.conf ~/.config/ranger/
ln -sf ~/gitroot/dotfiles/ranger/rifle.conf ~/.config/ranger/
ln -sf ~/gitroot/dotfiles/ranger/scope.sh ~/.config/ranger/

ln -sf ~/gitroot/dotfiles/vifm/vifmrc ~/.config/vifm/

ln -sf "${HOME}/gitroot/dotfiles/sublime/Default (OSX).sublime-keymap" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Default (OSX).sublime-keymap"
ln -sf "${HOME}/gitroot/dotfiles/sublime/Package Control.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Package Control.sublime-settings"
ln -sf "${HOME}/gitroot/dotfiles/sublime/Preferences.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings" 
ln -sf "${HOME}/gitroot/dotfiles/sublime/insert_date.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/insert_date.sublime-settings" 
