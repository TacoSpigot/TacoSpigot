#!/bin/bash

PS1="$"
basedir=`pwd`

function update {
    cd "$basedir/$1"
    git fetch && git reset --hard origin/master
    cd ../
    git add $1
}

# TacoSpigot start - update paper, not Craftbukit
#update Bukkit
#update CraftBukkit
#update Paperclip
update Paper
# TacoSpigot end
