#!/usr/bin/env bash
set -e

if [[ ! -f "/etc/arch-release" ]]; then
  echo "This script is intended for Arch Linux only!"
  exit 1
fi

if [[ -f "/run/archiso/cowspace" ]]; then
  echo "This script is not intended to be run in a live environment!"
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "Don't run this script as root, you will be asked for sudo permissions when necessary."
  exit 1
fi

RED_BOLD="\033[1;31m"
BLUE="\033[0;34m"
RESET="\033[0m"

install_paru() {
  echo -e "${BLUE}Installing AUR helper "paru"...${RESET}"
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si
}

if pacman -Qs paru >/dev/null; then
  echo -e "${BLUE}paru is already installed...${RESET}"
else
  echo -e "${BLUE}paru not found. Installing paru...${RESET}"
  install_paru
fi

install_dependencies() {
  echo -e "${BLUE}Installing dependencies...${RESET}"
  sudo pacman -Syy
  paru -S --noconfirm hyprland-git swww-git zed waterfox-bin rofi-power-menu rofi-wayland waybar gradience swaync whitesur-icon-theme vimix-cursors kitty xdg-desktop-portal-hyprland rofi-bluetooth-git hyprpolkitagent wlogout
  sudo pacman -S --noconfirm python-pywal kitty brightnessctl grim slurp pywalfox pipewire wireframe hypridle
}

setup_terminal_theme() {
  echo -e "${BLUE}Configuring terminal...${RESET}"
  sudo pacman -S zsh
  chsh -s $(which zsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

setup_hyprland() {
  echo -e "${BLUE}Copying config files...${RESET}"
  git clone https://github.com/Torveek/hyprdots.git
  rsync -av --exclude=".git" --exclude="README.md" $HOME/hyprdots/. $HOME/
}

setup_theme(){
  echo -e "${BLUE}Setting up theme...${RESET}"
  gsettings set org.gnome.desktop.interface cursor-theme 'Vimix Cursors - White'
  gsettings set org.gnome.desktop.interface cursor-size 24
  sh $HOME/theme.sh
}

enable_multilib(){
  if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "${BLUE}Enabling multilib repository...${RESET}"
    echo "[multilib]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf

    sudo pacman -Sy --noconfirm
  fi
}

main(){

  echo -e "${RED_BOLD}ATTENTION!${RESET}"
  echo "This script was made for my personal use. You should probably not run it yourself."
  echo "By proceeding, you forefit the right to cry and complain to me about anything that might go wrong."
  read -p "Proceed? (y/n) " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit
  fi

cd $HOME
echo -e "${BLUE}Installation Begins!!!${RESET}"
enable_multilib
install_dependencies
setup_terminal_theme
setup_hyprland
setup_theme

}

main "$@"
