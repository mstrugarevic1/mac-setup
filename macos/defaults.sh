#!/bin/bash

# Stop on errors, unset variables, and failed commands inside pipelines.
set -euo pipefail

# macOS does not create this custom screenshot directory itself.
screenshots_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshots_dir"

# Appearance
# Use the system-wide dark interface for applications that follow macOS appearance.
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Finder
# NSGlobalDomain applies this extension setting across macOS applications.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Display the current folder path at the bottom of Finder windows.
defaults write com.apple.finder ShowPathbar -bool true
# Display item count and available disk space at the bottom of Finder windows.
defaults write com.apple.finder ShowStatusBar -bool true
# Sort directories before files when Finder sorts by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Search the current Finder directory instead of the whole Mac by default.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Avoid Finder metadata files on shared network volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# User home
# Keep the normally hidden user Library folder visible in Finder.
chflags nohidden "$HOME/Library"

# Activity Monitor
# Show all processes instead of only the current user's processes.
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Dock
# Keep the Dock visible.
defaults write com.apple.dock autohide -bool false
# Do not add recently used applications after pinned Dock applications.
defaults write com.apple.dock show-recents -bool false
# Set Dock icons to 54 points.
defaults write com.apple.dock tilesize -int 54

# Keyboard and text input
# Lower values mean faster repeat and a shorter delay before repeating.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Repeat held keys, navigate controls with the keyboard, and avoid double-space periods.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Preserve spelling, punctuation, and capitalization instead of rewriting them automatically.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Save dialogs
# Open the full file browser in save dialogs; the second key covers newer dialog variants.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# Save new documents locally instead of defaulting to iCloud.
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Screenshots
# Store screenshots in the directory created above as PNG files without window shadows.
defaults write com.apple.screencapture location -string "$screenshots_dir"
defaults write com.apple.screencapture type -string png
defaults write com.apple.screencapture disable-shadow -bool true

# App Store
# Disable rating and review prompts from App Store applications.
defaults write com.apple.appstore InAppReviewEnabled -int 0

# Restart affected UI processes so most changes appear immediately; macOS relaunches them.
killall Finder Dock SystemUIServer 2>/dev/null || true
