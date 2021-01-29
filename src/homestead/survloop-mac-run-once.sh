#!/bin/bash
set +x
echo '------------------------'
echo 'Install Homebrew Helpers'
echo '========================'
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
xcode-select --install
brew update
brew install perl
brew install php@7.4
brew services start php@7.4
brew link php@7.4 --force
brew link --force --overwrite php@7.4
echo 'Helpers installed.' >> install-scripts/src/homestead/helpers-installed.txt

