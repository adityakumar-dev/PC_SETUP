#!/bin/bash

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred during the last command. Exiting!"
        exit 1
    fi
}

echo "Changing default shell to zsh..."
chsh -s /usr/bin/zsh
check_error

echo "Script for installing all the necessary tools after installing Arch:"

echo "Installing packages with pacman..."
sudo pacman -S --noconfirm unzip zsh git nerd-fonts zsh-syntax-highlighting zsh-autosuggestions bluez gnome-tweaks fastfetch lolcat
check_error

echo "Installing packages with yay..."
yay -S --noconfirm microsoft-edge-stable-bin vscodium-bin
check_error

echo "Adding zsh plugin configuration..."
{
    echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
} >> ~/.zshrc
check_error

sudo git clone https://github.com/z-shell/F-Sy-H /usr/share/zsh/plugins/fast-syntax
check_error
echo "source /usr/share/zsh/plugins/fast-syntax/F-Sy-H.plugin.zsh" >> ~/.zshrc

{
    echo "fastfetch | lolcat"
    echo "Welcome $(whoami)"
} >> ~/.zshrc

echo "Configuring zsh..." | lolcat
CONFIG=$(cat << EOF
# Set location of history file 
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY

# Set a custom prompt to show the current history index
PROMPT='%F{green}%n@%m %F{blue}%~ %F{yellow}[%!]%f %# '

# Load history when starting a new shell
if [[ -f \$HISTFILE ]]; then
    fc -R \$HISTFILE
fi

# Save history when exiting
trap 'fc -W \$HISTFILE' EXIT
EOF
)

echo "$CONFIG" >> ~/.zshrc
check_error

echo "Installing Powerlevel10k zsh theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
check_error
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

# Restart zsh to apply changes
exec zsh

echo "Adding sdkmanager configuration..." | lolcat
echo "Downloading sdkmanager..."
toolsDownloadUrl=$(curl -s https://developer.android.com/studio | grep -o "https://dl.google.com/android/repository/commandlinetools-linux-[0-9]*_latest.zip")
check_error

curl -o commandlinetools-linux.zip "$toolsDownloadUrl"
check_error

mkdir -p ~/android
unzip commandlinetools-linux.zip -d ~/android
check_error

rm -r commandlinetools-linux.zip
check_error

mkdir -p ~/android/cmdline-tools/latest
mv ~/android/cmdline-tools/* ~/android/cmdline-tools/latest
check_error

{
    echo 'export ANDROID_HOME="$HOME/android/"'
    echo 'export PATH="$PATH:$HOME/android/cmdline-tools/latest/bin"'
    echo 'export PATH="$PATH:$HOME/android/emulator"'
    echo 'export PATH="$PATH:$HOME/android/platforms"'
    echo 'export PATH="$PATH:$HOME/android/build-tools"'
} >> ~/.zshrc
check_error

source ~/.zshrc

sdkmanager --list
check_error

sdkmanager --install "emulator" "build-tools;35.0.0" "system-images;android-30;google_apis;x86_64" "platform-tools" "platforms;android-30"
check_error

avdmanager create avd --name "mypixel" -d "pixel_3" -k "system-images;android-30;google_apis;x86_64"
check_error

echo "Downloading Flutter versions JSON..."
flutter_json=$(curl -s https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json | jq -r '.base.release.version')
check_error

curl -o flutter-stable.zip "https://storage.googleapis.com/flutter_infra_release/releases/stable/$flutter_json/flutter_linux_$flutter_json-stable.zip"
check_error

echo "Extracting flutter-stable.zip..."
unzip flutter-stable.zip -d ~/android
check_error

echo 'export PATH="$PATH:$HOME/android/flutter/bin"' >> ~/.zshrc
check_error

echo "Script is now completed!" | lolcat