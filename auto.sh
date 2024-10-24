#!/bin/bash

set -o errexit
set -o pipefail

OS="$(uname)"

is_macos() {    
    [[ "${OS}" == "Darwin" ]] && true && return
    false
}

terminal_default_colors() {
    if [[ -t 1 ]]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        MAGENTA=$(printf '\033[35m')
        CYAN=$(printf '\033[36m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        BOLD=""
        RESET=""
    fi
}

terminal_printf() {
    local set_color=""
    local set_style=""
    local set_box=""
    [[ -z "${2}" ]] && echo -ne "${1}" >&2 && return
    [[ ${1:0:1} == "d" ]] && set_color=${RESET}
    [[ ${1:0:1} == "r" ]] && set_color=${RED}
    [[ ${1:0:1} == "g" ]] && set_color=${GREEN}
    [[ ${1:0:1} == "y" ]] && set_color=${YELLOW}
    [[ ${1:0:1} == "b" ]] && set_color=${BLUE}
    [[ ${1:0:1} == "m" ]] && set_color=${MAGENTA}
    [[ ${1:0:1} == "c" ]] && set_color=${CYAN}
    [[ ${1:1:1} == "b" ]] && set_style=${BOLD}
    [[ ${1:2:1} == "s" ]] && set_box="[-] "
    [[ ${1:2:1} == "d" ]] && set_box="\r[\033[0;32m\xE2\x9C\x94\033[0m] "
    [[ ${1:2:1} == "f" ]] && set_box="\r[\033[0;31m\xe2\x9c\x98\033[0m] "
    echo -e "${set_box}${set_color}${set_style}${2}${RESET}" >&2 && return
}

waiting_confirm() {
    local response
    while true; do
        read -r -p "Do you wish to continue (y/N)? " response
        case "${response}" in
        [yY][eE][sS] | [yY])
            echo
            break
            ;;
        *)
            echo
            exit
            ;;
        esac
    done
}

command_exists() {
    command -v "${@}" >/dev/null 2>&1
}

install_dependency() {
    terminal_printf cb? "Checking for setup dependencies..."
    if is_macos; then
        terminal_printf ??s "Checking for Xcode command line tools..."
        if xcode-select -p >/dev/null 2>&1; then
            terminal_printf ??d "Xcode command line tools are installed.$(tput el)"
        else
            terminal_printf ??f "\n"
            terminal_printf mb? "Attempting to install Xcode command line tools..."
            if xcode-select --install >/dev/null 2>&1; then
                terminal_printf gb? "Re-run script after Xcode command line tools have finished installing.\n"
            else
                terminal_printf rb? "Xcode command line tools install failed.\n"
            fi
            exit 1
        fi
    fi
}

setting_zsh() {
    HOMEBREW_PREFIX=""
    if is_macos; then
        UNAME_MACHINE="$(/usr/bin/uname -m)"
        if [[ "${UNAME_MACHINE}" == "arm64" ]] then
            HOMEBREW_PREFIX="/opt/homebrew"
        else
            HOMEBREW_PREFIX="/usr/local"
        fi
    else
        HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    fi
    export HOMEBREW_PREFIX="${HOMEBREW_PREFIX}"
    eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

    terminal_printf ??s "Config zshrc, p10k ..."
    curl -fsSL -o ${HOME}/.zshrc https://raw.githubusercontent.com/GOQoL/MyTools/main/zshrc
    curl -fsSL -o ${HOME}/.p10k.zsh https://raw.githubusercontent.com/GOQoL/MyTools/main/p10k.zsh
    terminal_printf ??d "Config completed.$(tput el)"
}

install_homebrew() {
    terminal_printf cb? "\nInstalling Homebrew..."
    terminal_printf ??s "Checking for Homebrew..."
    if command_exists "brew"; then
        terminal_printf ??d "Homebrew is installed.$(tput el)"
        terminal_printf ??s "Running brew update..."
        if brew update >/dev/null 2>&1; then
            terminal_printf ??d "Brew update completed.$(tput el)"
        else
            terminal_printf ??f "Brew update failed.$(tput el)"
        fi
        terminal_printf ??s "Running brew upgrade..."
        if brew upgrade >/dev/null 2>&1; then
            terminal_printf ??d "Brew upgrade completed.$(tput el)"
        else
            terminal_printf ??f "Brew upgrade failed.$(tput el)"
        fi
    else
        terminal_printf ??f "\n"
        terminal_printf mb? "Attempting to install Homebrew..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            terminal_printf ??d "Homebrew installed.\n"
        else
            terminal_printf ??f "Homebrew install failed.\n"
            exit 1
        fi
    fi
}

brew_packages() {
    if is_macos; then
        if [[ ! -z "$cask_list" ]]; then
            for cask in ${cask_list}; do
                terminal_printf mbs "Attempting to install cask ${cask}..."
                if brew install --cask "${cask}" -f; then
                    terminal_printf ??d "Package ${cask} installed.\n"
                else
                    terminal_printf ??f "Package ${cask} install failed.\n"
                fi
            done
        fi
    else
        term_list="$term_list docker-completion docker docker-compose"
    fi
    if [[ ! -z "$term_list" ]]; then
        for pkg in ${term_list}; do
            terminal_printf mbs "Attempting to install ${pkg}..."
            if brew install "${pkg}" -f; then
                terminal_printf ??d "Package ${pkg} installed.\n"
            else
                terminal_printf ??f "Package ${pkg} install failed.\n"
            fi
        done
    fi
}

brew_cleanup() {
    terminal_printf ??s "Running brew cleanup..."
    if brew cleanup --prune=all -q >/dev/null 2>&1; then
        terminal_printf ??d "Brew cleanup completed.$(tput el)"
    else
        terminal_printf ??f "Brew cleanup failed.$(tput el)"
    fi
}

main() {
    term_list="go fzf tmux wget helm kubernetes-cli k9s minikube lazydocker node telnet gcc"
    cask_list="docker github visual-studio-code telegram"
    clear
    terminal_default_colors
    waiting_confirm
    install_dependency
    install_homebrew
    setting_zsh
    if command_exists "brew"; then
        brew_packages
        brew_cleanup
    fi
    terminal_printf gb? "\nScript completed."
    chsh -s $(which zsh)
}

main "${@}"
