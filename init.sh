#!/bin/bash

pushd "$(dirname "$0")"

. util.sh

echo "Cloning Repos"

if [ ! -d CraftBukkit/.git ]; then
    git clone https://github.com/TacoSpigot/CraftBukkit.git CraftBukkit
fi;
if [ ! -d Bukkit/.git ]; then
    git clone https://github.com/TacoSpigot/Bukkit.git Bukkit
fi;

mkdir work
if [ ! -d work/builddata/.git ]; then
    git clone https://github.com/TacoSpigot/BuildData.git work/builddata
fi;

echo "Resetting to Upstream"
pushd Bukkit
git branch -f upstream
popd
pushd CraftBukkit
git branch -f upstream
popd

echo "Done Initing"
popd
