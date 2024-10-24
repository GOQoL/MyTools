# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

OS="$(uname)"
is_macos() {    
    [[ "${OS}" == "Darwin" ]] && true && return
    false
}

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

# brew
eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# Source/Load zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load completions
autoload -Uz +X compinit && compinit
source <(kubectl completion zsh)
source <(docker completion zsh)
source <(minikube completion zsh)
source <(helm completion zsh)

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Golang
export PATH="$HOME/go/bin:$PATH"

alias k="kubectl"
alias mk="minikube"
alias dc="docker-compose"
alias t="tmux a"
alias zconfig="code $HOME/.zshrc"

brew_update() {
  brew update && brew upgrade -f
}

brew_clean() {
  brew cleanup --prune=all -q
}

go_clean() {
  go clean -cache -modcache -x
}

docker_clean() {
  docker system prune -af --volumes
}

clean_all() {
  brew_clean && go_clean && docker_clean
}

rebase() {
  echo "
  Step1: git resert HEAD~1
  Step2: git add .
  Step3: git commit -am "Message"
  Step4: git push --force"
}

port_listen() {
  sudo lsof -i -P -n | grep LISTEN
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh