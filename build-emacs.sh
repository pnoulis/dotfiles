#!/usr/bin/env bash

set -o errexit

##################################################
# Constants
##################################################
pkgname=emacs
pkgver=29.3
pkgorg=gnu
pkgdistname=${pkgname}-${pkgver}
pkgupstreamsrc=ftp.gnu.org/gnu/emacs/${pkgdistname}.tar.gz

script_depens=(
    curl
)
# apt build-dep -y ${pkgname}
pkg_depens=(
    build-essential
    emacs-bin-common
    emacs-common-non-dfsg
    gcc-12
    ncurses-term
    mailutils
    libacl1-dev
    libc6-dev
    libdbus-1-dev
    libgmp-dev
    libjansson4
    libjansson-dev
    libncurses-dev
    liblcms2-dev
    libselinux1-dev
    libsystemd-dev
    libxml2-dev
    libgpm-dev
    zlib1g-dev
    libgccjit-12-dev
    libgccjit0
    libgnutls28-dev
    pkg-config
    libtree-sitter-dev
    libsqlite3-dev
    hicolor-icon-theme
)

##################################################
# Options
##################################################
srcrootdir=~/src/${pkgorg}/${pkgname}
buildname=${pkgdistname}.build
buildir=${srcrootdir}/$buildname

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"

    for depen in ${script_depens}; do
        printf "dependency: %s " $depen
        if ! is_depen_installed $depen; then
            echo '(missing)'
            apt install -y $depen
        else
            echo '(installed)'
        fi
    done

    mkdir -p $srcrootdir
    srcrootdir=$(realpath -e $srcrootdir)
    cd $srcrootdir

    # download package upstream src tree
    if [[ ! -e ${pkgdistname}.tar.gz ]]; then
        curl $pkgupstreamsrc > ${pkgdistname}.tar.gz
    fi

    tar -xvf ${pkgdistname}.tar.gz
    srcdir=${srcrootdir}/${pkgdistname}
    buildir=${srcrootdir}/${buildname}
    rm -rf $buildir
    mkdir $buildir
    cd $buildir
    srcdir_rel=$(realpath -e --relative-to=$(pwd) $srcdir)

    debug_var pkgname pkgver pkgorg pkgdistname pkgsrc \
              srcrootdir srcdir buildname buildir srcdir_rel


    for depen in ${pkg_depens[@]}; do
        printf "dependency: %s " $depen
        if ! is_depen_installed $depen; then
            echo '(missing)'
            apt install -y $depen
        else
            echo '(installed)'
        fi
    done

    CC=/usr/bin/gcc-12 \
        CXX=/usr/bin/gcc-12 \
        ${srcdir_rel}/configure --prefix=/usr/local \
        --sysconfdir=/etc \
        --without-x \
        --without-sound \
        --with-mailutils \
        --with-native-compilation \
        --with-json \
        --with-tree-sitter \
        --with-wide-int \
        --with-modules | tee config.out


    make -j $(nproc)
    sudo make install
}

debug_var() {
    for i in "$@"; do
        printf "%s:%s\n" "$i" "${!i}"
    done
}

is_depen_installed() {
    dpkg-query --status $1 &>/dev/null
    return $?
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -s | --srcrootdir*)
                srcrootdir="$(parse_param "$@")" || shift $?
                ;;
            -b | --buildname*)
                buildname="$(parse_param "$@")" || shift $?
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
                echo "Unrecognized argument ${1:-}"
                exit 1
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
        echo "${param:-$1} requires an argument"
        exit 1
    fi

    echo "${arg:-}"
    return $toshift
}

main "$@"
