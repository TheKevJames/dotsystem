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

# CCMenu
defaults write net.sourceforge.cruisecontrol.CCMenu "PlaySound Broken" -int 0
defaults write net.sourceforge.cruisecontrol.CCMenu "PlaySound Fixed" -int 0
defaults write net.sourceforge.cruisecontrol.CCMenu "PlaySound StillFailing" -int 0
defaults write net.sourceforge.cruisecontrol.CCMenu "PlaySound Successful" -int 0
defaults write net.sourceforge.cruisecontrol.CCMenu "SendNotification Broken" -int 1
defaults write net.sourceforge.cruisecontrol.CCMenu "SendNotification Fixed" -int 1
defaults write net.sourceforge.cruisecontrol.CCMenu "SendNotification StillFailing" -int 1
defaults write net.sourceforge.cruisecontrol.CCMenu "SendNotification Successful" -int 0
# TODO: configure connected projects
# defaults delete net.sourceforge.cruisecontrol.CCMenu Projects
# for project in ${projects}; do
#     defaults write net.sourceforge.cruisecontrol.CCMenu Projects \
#         -array-add '{projectName = "'"${project}"'"; serverUrl = "https://circleci.com/cc.xml?circle-token='"${circleci_token}"'";}'
# done

# Magnet
## clear unused
defaults write com.crowdcafe.windowmagnet centerWindowComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowCenterThirdComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowLeftThirdComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowLeftTwoThirdsComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowNorthWestComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowRightThirdComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowRightTwoThirdsComboKey '{}'
defaults write com.crowdcafe.windowmagnet expandWindowSouthWestComboKey '{}'
defaults write com.crowdcafe.windowmagnet moveWindowToNextDisplay '{}'
defaults write com.crowdcafe.windowmagnet moveWindowToPreviousDisplay '{}'
defaults write com.crowdcafe.windowmagnet restoreWindowComboKey '{}'
## set the rest
### Keys:
###   6:   z
###   123: <
###   124: >
###   125: v
###   126: ^
### Modifiers:
###   1441792: cmd+ctrl+shift
###   1966080: cmd+ctrl+shift+option
defaults write com.crowdcafe.windowmagnet expandWindowEastComboKey -dict keyCode 124 modifierFlags 1441792
defaults write com.crowdcafe.windowmagnet expandWindowNorthComboKey -dict keyCode 126 modifierFlags 1441792
defaults write com.crowdcafe.windowmagnet expandWindowNorthEastComboKey -dict keyCode 126 modifierFlags 1966080
defaults write com.crowdcafe.windowmagnet expandWindowSouthComboKey -dict keyCode 125 modifierFlags 1441792
defaults write com.crowdcafe.windowmagnet expandWindowSouthEastComboKey -dict keyCode 125 modifierFlags 1966080
defaults write com.crowdcafe.windowmagnet expandWindowWestComboKey -dict keyCode 123 modifierFlags 1441792
defaults write com.crowdcafe.windowmagnet maximizeWindowComboKey -dict keyCode 6 modifierFlags 1441792
