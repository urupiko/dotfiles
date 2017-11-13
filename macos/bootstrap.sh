#!/bin/sh

brew bundle

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


# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/gitroot/dotfiles/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true


mkdir -p ~/.zsh
pushd ~/.zsh
git clone git://github.com/zsh-users/zaw.git
popd
chsh -s /bin/zsh

RUBY_VERSION=2.2.2
cat <<"EOF" >> ~/.profile

export PATH="${HOME}/.rbenv/bin:${PATH}"
eval "$(rbenv init -)"

EOF
source ~/.profile
rbenv --version
rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}



sh ./mklinks.sh

