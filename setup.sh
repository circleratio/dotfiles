#!/usr/bin/bash

function install_file () {
    if [[ ! -f "$2/$1" ]]; then
        echo Installing "$1" "$2/$1"
        echo install -C "$1" "$2/$1"
    elif [[ "$1" -nt "$2/$1" ]]; then
        echo Source is newer than destination. Installing "$1" "$2/$1"
        echo install -C "$1" "$2/$1"
    else
        echo "$2/$1" already installed. Skipped.
    fi
}

function install_file_only_if_no_exist () {
    if [[ ! -f "$2" ]]; then
        echo Installing "$1" "$2"
        echo install -C "$1" "$2"
    else
        echo "$2" already exists. Skipped.
    fi
}

function install_dir () {
    if [[ ! -d "$2/$1" ]]; then
        echo install -Cd "$1" "$2/$1"
    else
        echo "$2/$1" already exists. Skipped.
    fi
}

function make_symlink () {
    if [[ ! -L "$2" ]]; then
        Linking "$1" "$2"
        ln -s "$1" "$2"
    else
        echo "$2" already exists. Skipped.
    fi
}

SRC=$(pwd $(dirname $0))

echo ========== bash ==========
install_file .bash_profile ${HOME}
install_file .bashrc ${HOME}
make_symlink "${SRC}/.bash_aliases" "${HOME}/.bash_aliases"

echo ========== screen ==========
install_file .screenrc ${HOME}

echo ========== Emacs ==========
install_dir .emacs.d ${HOME}

echo ========== bin files ==========
for f in $(ls bin/*); do
    make_symlink "${SRC}/${f}" "${HOME}/${f}"
done

echo ========== mailcap ==========
install_file .mailcap ${HOME}

echo ========== directory bookmark ==========
install_file .dir_bookmark ${HOME}

echo Done.

