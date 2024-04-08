# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# powerline-daemon -q
# POWERLINE_BASH_CONTINUATION=1
# POWERLINE_BASH_SELECT=1
# . /usr/share/powerline/bindings/bash/powerline.sh

alias ls='ls --color=auto'

# Prompt styling
# All non-printable bytes must be contained by the characters:
# '\[<non-printable bytes>\]'

# Which characters are are classified as non-printable bytes?
#
# Terminal control sequences (colors) are non printable bytes and must
# be wrapped.

# Terminal control sequences
# start of color: \e[
# end of color: \e[0m
# red: 31m
# green: 32m
# yellow: 33m
# blue: 34m
# cyan: 36m
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
reset='\e[0m'

# Prompt escape sequence
# https://tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html
# \u the username of the current user
# \h hostname up to the first '.'
# \e ASCII escape character
# \w the current working directory
# \W basename of the current working directory
login='\u'
host='\h'
cwd='\w'
newline='\n'
PS1="\[$red\]$login@$host\[$reset\]${newline}\[$green\]${cwd}\[$reset\]${newline}\[$green\]\$<\[$reset\] "


export MOZ_ENABLE_WAYLAND=1
# fixes firefox is alrady running prroblem
# see: https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/
export MOZ_DBUS_REMOTE=1

export PATH=$HOME/bin:$HOME/.local/bin:/$HOME/bin/flathub_programs/:$PATH
alias ll="/bin/ls -la"
alias la="/bin/ls -a"
alias ld="find . -mindepth 1 -maxdepth 1 -type d"
alias rsync="rsync --progress --verbose"
alias drysync="rsync --progress --verbose --dry-run"
alias today='date +%A-%d-%m-%Y'
alias tommorow="date --date='next day' +%A-%d-%m-%Y"
alias month="date +%B-%m-%Y"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias nodesm='node --experimental-default-type=module'

GIT_AUTHOR_NAME='pavlos noulis'
GIT_AUTHOR_EMAIL='pavlos.noulis@gmail.com'
GITHUB_USERNAME='pnoul'
alias sc='slurp | grim -g - - | wl-copy'


function efind {
    echo "find $1 -regextype posix-extended ${@:2}"
}

alias emt='emacsclient -t'
alias emr='emacsclient -n'
alias emc='emacsclient -nw'
alias diff='diff -u --color'
EDITOR='emacsclient -n'
VISUAL=$EDITOR

function cd {
    builtin cd "$@"
    ls
}

# Load Angular CLI autocompletion.
source <(ng completion script)


[[ "$INSIDE_EMACS" == 'vterm' ]] \
    && [[ -n ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]] \
    && source ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
              
