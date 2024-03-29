#/bin/sh

ln -sf ~/gitroot/dotfiles/.zshrc ~/

dir=~/.config/tmux; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/.tmux.conf ~/

dir=~/.config/vifm; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/vifm/vifmrc ~/.config/vifm/

dir=~/.config/peco; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/peco/config.json ~/.config/peco/

dir=~/.config/nvim; [ ! -e $dir ] && mkdir -p $dir
ln -sf ~/gitroot/dotfiles/neovim/init.vim ~/.config/nvim/

dir="${HOME}/Library/Application Support/Code/User"; [ ! -e "${dir}" ] && mkdir -p "${dir}"
ln -sf ~/gitroot/dotfiles/vscode/settings.json $dir
# ln -sf ~/gitroot/dotfiles/vscode/.json $dir

# dir="${HOME}/Library/Application Support/Sublime Text 3/Packages/User"; [ ! -e "${dir}" ] && mkdir -p "${dir}"
# ln -sf "${HOME}/gitroot/dotfiles/sublime/Default (OSX).sublime-keymap" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
# ln -sf "${HOME}/gitroot/dotfiles/sublime/Package Control.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
# ln -sf "${HOME}/gitroot/dotfiles/sublime/Preferences.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
# ln -sf "${HOME}/gitroot/dotfiles/sublime/insert_date.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"
# ln -sf "${HOME}/gitroot/dotfiles/sublime/Ruby.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"

