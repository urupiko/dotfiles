#!/bin/sh

brew bundle

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

