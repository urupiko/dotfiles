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


# Tell iTerm2 to use the custom preferences in the directory
# defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/gitroot/dotfiles/iterm2"
# defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# Vifm 
################################################################################
rm -rf ~/.config/vifm/colors
git clone https://github.com/vifm/vifm-colors ~/.config/vifm/colors

# Zaw 
################################################################################
mkdir -p ~/.zsh
pushd ~/.zsh
git clone git://github.com/zsh-users/zaw.git
popd
chsh -s /bin/zsh
# Supress insecure direcotry warnings
compaudit | xargs chmod g-w

# Git
################################################################################
git config --global user.name "urupiko"
git config --global core.editor 'nvim'
git config --global color.ui true

# Ruby
################################################################################
RUBY_VERSION=2.7.2
cat <<"EOF" >> ~/.profile

export PATH="${HOME}/.rbenv/bin:${PATH}"
eval "$(rbenv init -)"

EOF
source ~/.profile
rbenv --version
rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}



sh ./mklinks.sh