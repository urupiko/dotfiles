#!/bin/sh

brew bundle

# memo: 透明とかのプロファイル設定はdefaultsコマンドで変更が面倒なので諦め。
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool false
defaults write com.googlecode.iterm2 HideScrollbar -bool true
defaults write com.googlecode.iterm2 Hotkey -bool true
defaults write com.googlecode.iterm2 'HotkeyChar' '63236'
defaults write com.googlecode.iterm2 'HotkeyCode' '122'
defaults write com.googlecode.iterm2 'HotkeyModifiers' '8388864'

mkdir -p ~/.zsh
pushd ~/.zsh
git clone git://github.com/zsh-users/zaw.git
popd

chsh -s /bin/zsh

sh ../mklinks.sh

