export EDITOR=nvim
autoload -U colors && colors



if [[ -n "$WSL_DISTRO_NAME" ]]; then
  case "${WSL_DISTRO_NAME:l}" in
    *fedora*)
      BRACKET_COLOR="#6d8dad"
      USER_COLOR="#61afef"
      AT_COLOR="#abb2bf"
      HOST_COLOR="#545862"
      PATH_COLOR="#abb2bf"
      ;;
    *ubuntu*)
      BRACKET_COLOR="#caaa6a"
      USER_COLOR="#EBCB8B"
      AT_COLOR="#abb2bf"
      HOST_COLOR="#caaa6a"
      PATH_COLOR="#EBCB8B"
      ;;
    *arch*)
      BRACKET_COLOR="#6d8dad"
      USER_COLOR="#61afef"
      AT_COLOR="#abb2bf"
      HOST_COLOR="#545862"
      PATH_COLOR="#abb2bf"
      ;;
    *kali*)
      BRACKET_COLOR="#7EC7A2"
      USER_COLOR="#61afef"
      AT_COLOR="#abb2bf"
      HOST_COLOR="#7EC7A2"
      PATH_COLOR="#EBCB8B"
      ;;
    *debian*)
      BRACKET_COLOR="#e06c75"
      USER_COLOR="#c678dd"
      AT_COLOR="#abb2bf"
      HOST_COLOR="#e06c75"
      PATH_COLOR="#c678dd"
      ;;
    *)
      BRACKET_COLOR="#545862"
      USER_COLOR="#abb2bf"
      AT_COLOR="#abb2bf"
      HOST_COLOR="#545862"
      PATH_COLOR="#abb2bf"
      ;;
  esac
else
  BRACKET_COLOR="#545862"
  USER_COLOR="#abb2bf"
  AT_COLOR="#abb2bf"
  HOST_COLOR="#545862"
  PATH_COLOR="#abb2bf"
fi

setopt PROMPT_SUBST
PS1='%B%F{$BRACKET_COLOR}[%F{$USER_COLOR}%n%F{$AT_COLOR}@%F{$HOST_COLOR}%M %F{$PATH_COLOR}%~%F{$BRACKET_COLOR}]%{$reset_color%}$%b '

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history

setopt SHARE_HISTORY             # Share history between sessions (includes immediate write)
setopt EXTENDED_HISTORY          # Record timestamp with each command
setopt HIST_REDUCE_BLANKS        # Remove extra whitespace

autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist

if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

_comp_options+=(globdots)        # Include hidden files

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt MENU_COMPLETE
setopt LIST_PACKED
setopt LIST_TYPES
setopt REC_EXACT

bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init

echo -ne '\e[5 q' # Use beam shape cursor on startup
autoload -Uz add-zsh-hook
_reset_cursor() { echo -ne '\e[5 q'; }
add-zsh-hook preexec _reset_cursor

# Edit line in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt CDABLE_VARS

setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NUMERIC_GLOB_SORT
setopt NULL_GLOB

setopt NO_CLOBBER
setopt NO_NOMATCH
setopt INTERACTIVE_COMMENTS
setopt CORRECT
setopt AUTO_PARAM_SLASH
setopt AUTO_REMOVE_SLASH
setopt AUTO_LIST
setopt MAGIC_EQUAL_SUBST
setopt LONG_LIST_JOBS
setopt PRINT_EIGHT_BIT
setopt TRANSIENT_RPROMPT
setopt IGNORE_EOF


win() {
  local winprofile=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r' | sed 's/\\/\//g' | sed 's/C:/\/mnt\/c/g')
  if [[ -n "$winprofile" && -d "${winprofile}/Downloads/Dev" ]]; then
    cd "${winprofile}/Downloads/Dev"
  else
    echo "Dev folder not found at ${winprofile}/Downloads/Dev"
  fi
}

mot() {
  local winprofile=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r' | sed 's/\\/\//g' | sed 's/C:/\/mnt\/c/g')
  if [[ -n "$winprofile" && -d "${winprofile}/Downloads/Dev/motorwise.io" ]]; then
    cd "${winprofile}/Downloads/Dev/motorwise.io"
  else
    echo "motorwise.io folder not found at ${winprofile}/Downloads/Dev/motorwise.io"
  fi
}
export LS_COLORS="${LS_COLORS}:ow=01;34:tw=01;34"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ls aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'

# Misc
alias reload='source ~/.zshrc'
alias zshconfig='$EDITOR ~/.zshrc'

export PATH="$HOME/.local/bin:$PATH"

ZSH_PLUGIN_DIR="${HOME}/.local/share/zsh/plugins"


[[ -f "${ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "${ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"


[[ -f "${ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "${ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

