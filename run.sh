#!/bin/sh
cd "$(dirname "$0")"
echo "\n\nSetting up Mac...\n"

# Ask for the administrator password upfront
echo "\n\nIf installing app store apps using mas, please log into app store if you haven't already...\n"
echo "Need sudo privileges...\n"
sudo -v

# Keep sudo mode alive until script finish
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check for Homebrew and install if not present
echo "\n\nChecking for Homebrew and install if not present\nThis should install command line tools too automatically if not installed\n"
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update Homebrew recipes
echo "\n\nUpdating Homebrew recipes\n"
brew update --verbose

# Install brew taps and casks with bundle (See Brewfile)
echo "\n\nInstalling brew, brew cask and mas packages...\n"
brew tap homebrew/bundle --verbose
brew bundle --verbose

# Install other brews that don't work properly in brewfile
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
brew cask install adoptopenjdk/openjdk/adoptopenjdk11
# brew cask install osxfuse
# brew cask install lulu
# brew cask install oversight

# Setup PSQL
echo "\n\nSetting up Postgres DB for first time use... \n"
pg_ctl -D /usr/local/var/postgres start
createdb `whoami`
pg_ctl -D /usr/local/var/postgres stop

# Install oh my zsh
echo "\n\nInstalling oh my zsh... \n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Copy Mackup config file to the home directory
echo "\n\nSymlinking Mackup config to home directory...\n"
cp -i ./.mackup.cfg $HOME/.mackup.cfg

# Ask whether to set macOS preferences
echo "\n\nDo you want to set macOS preferences? [Y,n]\n"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "\nSetting macOS preferences\n"
        source .macos
else
        echo "\nmacOS preferences not set\n"
fi

# Ask whether to clear brew cache
echo "\n\nDo you want to clear brew cache? [Y,n]\n"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "\nClearing brew cache\n"
        rm -rf $(brew --cache)
else
        echo "\nBrew cache not cleared\n"
fi

# Install Meslo fonts
echo "\n\nCopying MesloLGS fonts used by PowerLevel10K theme to Fonts folder"
cp ./fonts/*.ttf /Library/Fonts/

# Install Powerlevel10K Zsh theme
echo "\n\nInstalling Powerlevel10K zsh theme...\n"
brew install romkatv/powerlevel10k/powerlevel10k

# Last steps
echo "\nrun 'mackup restore' after mackup files have synced from cloud storage!\n\nComplete!!"
