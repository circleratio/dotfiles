#!/usr/bin/bash

function install_file () {
    if [ ! -f $2 ]; then
        echo Installing $1 $2
        install -C $1 $2
    elif [ $1 -nt $2 ]; then
        echo Installing $1 $2
        install -C $1 $2
    fi
}

function install_file_only_if_no_exist () {
    if [ ! -f $2 ]; then
        echo Installing $1 $2
        install -C $1 $2
    fi
}

echo Install files...

files=(.bash_profile  .bashrc .screenrc bin/*)

for f in "${files[@]}"; do
    install_file "$f" ~/"$f"
done

files=(.dir_bookmark)
for f in "${files[@]}"; do
    install_file_only_if_no_exist "$f" ~/"$f"
done

echo Done.

