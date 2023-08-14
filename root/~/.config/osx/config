#!/usr/bin/env bash
# UI
## dark mode
defaults write "Apple Global Domain" AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
## make the dock small
defaults write com.apple.dock tilesize -int 36
## autohide the dock (quickly!)
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
## remove app pins from dock -- only show open apps
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock static-only -bool true
defaults write com.apple.dock show-recents -bool false
## don't auto-reorder spaces
defaults write com.apple.dock mru-spaces -bool false

# Files
## don't warn on emptying trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false
## do not create .DS_Store files on network drives or USBs
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
## use list view in finder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
## show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
## don't whine about modifying extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
## show ~/Library and /Volumes
chflags nohidden ~/Library
sudo chflags nohidden /Volumes
## show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
## show removables on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
## set default finder window to ~
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Mouse
## enable two-finger tap to right-click
defaults write "Apple Global Domain" com.apple.trackpad.twoFingerDoubleTapGesture -int 1
defaults write NSGlobalDomain com.apple.trackpad.twoFingerDoubleTapGesture -int 1
## enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
## disable force-click help mode
defaults write "Apple Global Domain" com.apple.trackpad.forceClick -bool true
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true
## disable "Natural Scroll"
defaults write "Apple Global Domain" com.apple.swipescrolldirection -int 0
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
## disable launchpad gesture
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Keyboard
## remap caps lock > escape
## https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc": 0x700000039, "HIDKeyboardModifierMappingDst": 0x700000029}]}' >/dev/null
## key repeat > key hold
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 0
defaults write NSGlobalDomain InitialKeyRepeat -int 10
## disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
## disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
## disable period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
## disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Misc
## replace ActivityMonitor icon with CPU monitor
defaults write com.apple.ActivityMonitor IconType -int 5
## show all in ActivityMonitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0
## enable infinite caffeination
# TODO: what'd they change now?
# sudo launchctl load /Library/LaunchAgents/in.thekev.caffeinate.plist
