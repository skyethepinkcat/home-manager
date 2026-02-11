function format_directory() {
    directory=''
    if [[ "$2" == 'dirname' ]]; then
        directory="$(basename "$(dirname "$1")")/"
        if [[ "$(dirname $1)" == $HOME ]]; then
            directory='~/'
        elif [[ "$(dirname $1)" == '/' ]]; then
            directory=''
        fi
    else
        directory="$(basename "$1")"
        if [[ "$1" == "$HOME" ]]; then
            directory='~'
        fi
    fi
    echo "$directory"
}

function set_win_title {
    basename=$(format_directory "$PWD" basename)
    dirname=$(format_directory "$PWD" dirname)
    dir="$basename"
    parent_dir="$dirname"
    if [[ "$PWD" == "$HOME" ]]; then
        parent_dir=''
    fi
    ssh_prompt=''
    if [[ $SSH_CONNECTION  ]]; then
        ssh_prompt="$USER@$(hostname -s):"
    fi
    echo -ne "\033]0; $ssh_prompt$parent_dir$dir \007"
}
