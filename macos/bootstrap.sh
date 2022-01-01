#!/bin/sh

# Homebrew
################################################################################
if !(type "brew" > /dev/null 2>&1); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle

# System Settings
################################################################################
# System Settings Tweak
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 50
# Enable `Tap to click`
defaults write com.apple.driver.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
# Disable auto run for image
defaults write com.apple.ImageCapture disableHotPlug -bool NO
# Make the home directory opened in the Finder by default
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
# Avoid creating `.DS_Store` files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Make key repeat speed faster
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10
# Show the ~/Library folder
chflags nohidden ~/Library

# Disable Spotlight
sudo mdutil -a -i off

# Tell iTerm2 to use the custom preferences in the directory
# defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/gitroot/dotfiles/iterm2"
# defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# VS Code key repeat
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false

# Dock
################################################################################
dockutil --remove 'Safari'
dockutil --remove 'TV'
dockutil --remove 'メッセージ'
dockutil --remove 'リマインダー'
dockutil --remove '連絡先'
dockutil --remove 'ミュージック'
dockutil --remove 'FaceTime'
dockutil --remove 'マップ'
dockutil --remove '写真'
dockutil --remove 'メール'
dockutil --remove 'Podcast'
dockutil --remove 'メモ'

dockutil --add '/Applications/iTerm.app' --label 'iTerm'
dockutil --add '/Applications/Microsoft To Do.app' --label 'ToDo'
dockutil --add '/Applications/p4v.app' --label 'P4V'
dockutil --add '/Applications/Visual Studio Code.app' --label 'VS Code'
dockutil --add '/Applications/Google Chrome.app' --label 'Chrome'
dockutil --add '/Applications/Slack.app' --label 'Slack'

# Vifm 
################################################################################
rm -rf ~/.config/vifm/colors
git clone https://github.com/vifm/vifm-colors ~/.config/vifm/colors
git clone https://github.com/cirala/vifm_devicons ~/.config/vifm/scripts

# Zaw 
################################################################################
mkdir -p ~/.zsh
pushd ~/.zsh
git clone git://github.com/zsh-users/zaw.git
popd

# Memo: these are no longer necessary
# chsh -s /bin/zsh
# Supress insecure direcotry warnings
# compaudit | xargs chmod g-w

# Git
################################################################################
git config --global user.name "urupiko"
git config --global core.editor 'nvim'
git config --global color.ui true

# Ruby
################################################################################
RUBY_VERSION=2.7.2
cat <<"EOF" >> ~/.zprofile

export PATH="${HOME}/.rbenv/bin:${PATH}"
eval "$(rbenv init -)"

EOF
source ~/.zprofile
rbenv --version
rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}



sh ./mklinks.sh