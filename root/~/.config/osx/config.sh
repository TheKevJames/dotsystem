#!/usr/bin/env bash
# TODO: it might be better to use `plutil` to sync literal plist files from an
# editable (xml/json) source of truth

# key repeat > key hold
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 0

# use list view in finder
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# do not create .DS_Store files on network drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

# show ~/Library
chflags nohidden ~/Library

# show removables on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
