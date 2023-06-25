#!/bin/sh

fancy_echo() {
    local fmt="$1"; shift
    printf "\\n$fmt\\n" "$@"
}

append_to_zshrc() {
    local text="$1" zshrc
    local skip_new_line="${2:-0}"
    
    if [ -w "$HOME/.zshrc.local" ]; then
        zshrc="$HOME/.zshrc.local"
    else
        zshrc="$HOME/.zshrc"
    fi

    if ! grep -Fqs "$text" "$zshrc"; then
        if [ "$skip_new_line" -eq 1 ]; then
            printf "%s\\n" "$text" >> "$zshrc"
        else
            printf "\\n%s\\n" "$text" >> "$zshrc"
        fi
    fi
}

if [[ $EUID -eq 0 ]]; then
    fancy_echo "Do not run this script as root!"
    exit 1
fi

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
set -e

if [ ! -d "$HOME/.bin/" ]; then
    mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
fi

append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

arch="$(uname -m)"
if [ "$arch" = "arm64" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

# Install Rosetta
if [ "$(uname -m)" = "arm64" ]; then
    # If Rosetta is already installed, skip
    if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto > /dev/null 2>&1; then
        fancy_echo "Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license > /dev/null 2>&1
        fancy_echo "Rosetta is installed"
    else
        fancy_echo "Rosetta is installed"
    fi
fi

# Install Homebrew
if ! command -v brew >/dev/null; then
    fancy_echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    append_to_zshrc "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\""
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
    fancy_echo "Homebrew is installed"
fi

# Install packages from Homebrew
fancy_echo "Installing packages from Homebrew..."
    fancy_echo "Spotify"
    brew install --cask spotify
    fancy_echo "VLC"
    brew install --cask vlc
    fancy_echo "iTerm2"
    brew install --cask iterm2
    fancy_echo "Neovim"
    brew install neovim
    fancy_echo "Bitwarden"
    brew install --cask bitwarden
    fancy_echo "Hidden Bar"
    brew install --cask hiddenbar
    fancy_echo "Insomnia"
    brew install --cask insomnia
    fancy_echo "Visual Studio Code"
    brew install --cask visual-studio-code
    fancy_echo "Rectangle"
    brew install --cask rectangle
    fancy_echo "Jumpcut"
    brew install --cask jumpcut
    fancy_echo "Google Chrome"
    brew install --cask google-chrome
    fancy_echo "Python 3"
    brew install python
    fancy_echo "UTM"
    brew install --cask utm
    fancy_echo "LibreOffice"
    brew install --cask libreoffice
    fancy_echo "Mac App Store (MAS) CLI"
    brew install mas
    fancy_echo "Git"
    brew install git
fancy_echo "Completed installing packages from Homebrew"
