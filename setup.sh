#!/usr/bin/env bash


srcdir=$(cd -- $(dirname "${BASH_SOURCE[0]}") && pwd)
username=pnoul
installdir=${HOME}/tmp/${username}

usage() {
    cat<<EOF
Usage: ${0} [OPTION]...
EOF
}


main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"

    debugv srcdir
    debugv username
    debugv installdir
    rm -rf $installdir
    mkdir -p $installdir
    cd $installdir
    mk_std_dir_structure
    tree $installdir
}

mk_std_dir_structure() {
    # Library
    mkdir -p library/{non_fiction,fiction,articles,manuals}
    # Multimedia
    mkdir -p media/{music,videos,movies,documentaries,pictures,lectures}
    # Pictures
    mkdir -p media/pictures/{family,pnoul}
    # Unsorted
    mkdir unsorted
    # Temporary
    mkdir tmp
    # Downloads
    mkdir downloads
    # Projects
    mkdir -p projects/pnoul
    # Src
    mkdir -p src/pnoul/github.com/
    # Trash
    mkdir -p trash
    # Office
    mkdir -p office/{pnoul,paris-noulis,victor-noulis,fenia-hourv,dimitris-noulis}/documents
    # Things
    mkdir -p things
    # Dotfiles
    mkdir -p dotfiles
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -h | --help)
                usage
                exit 0
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="${1:-}"
                shift
                local rest="$@"
                set --
                for i in $(echo "$i" | grep -o '[a-zA-Z]'); do
                    set -- "$@" "-$i"
                done
                set -- $@ $rest
                continue
                ;;
            --)
                shift
                POSARGS+=("$@")
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                fatal "Unrecognized argument ${1:-}"
                ;;
            *)
                POSARGS+=("${1:-}")
                ;;
        esac
        shift
    done
}

parse_param() {
    local param arg
    local -i toshift=0

    if (($# == 0)); then
        return $toshift
    elif [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        ((toshift++))
    fi

    if [[ -z "${arg-}" && ! "${OPTIONAL-}" ]]; then
        fatal "${param:-$1} requires an argument"
    fi

    echo "${arg:-}"
    return $toshift
}

quote() {
    echo \'"$@"\'
}

debug() {
    [ ! $DEBUG ] && return
    echo "$@" >&2
}

fatal() {
    echo $0: "$@" >&2
    exit 1
}

debugv() {
    echo $1:"${!1}"
}


main "$@"
