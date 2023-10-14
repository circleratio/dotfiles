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
        install -Cd "$1" "$2/$1"
    else
        echo "$2/$1" already exists. Skipped.
    fi
}

function make_symlink () {
    LINK_TO="${2%/}/$1"
    LINK_FROM="${3%/}/$1"
    if [[ ! -L "${LINK_FROM}" ]]; then
        echo Linking "${LINK_TO}" and "${LINK_FROM}"
        ln -s "${LINK_TO}" "${LINK_FROM}"
    else
        echo "${LINK_FROM}" already exists. Skipped.
    fi
}

SRC=$(pwd $(dirname $0))

echo ========== bash ==========
install_file .bash_profile ${HOME}
install_file .bashrc ${HOME}
make_symlink .bash_aliases "${SRC}" "${HOME}"

echo ========== screen ==========
install_file .screenrc ${HOME}

echo ========== Emacs ==========
install_dir .emacs.d ${HOME}

echo ========== bin files ==========
for f in $(ls bin/*); do
    make_symlink "$f" "${SRC}" "${HOME}"
done

echo ========== mailcap ==========
install_file .mailcap ${HOME}

echo ========== vim ==========
make_symlink .vimrc "${SRC}" "${HOME}"
install_dir .vim/dein "${HOME}"
make_symlink dein.toml "${SRC}/.vim/dein" "${HOME}/.vim/dein" 

echo ========== directory bookmark ==========
install_file .dir_bookmark ${HOME}

echo Done.

