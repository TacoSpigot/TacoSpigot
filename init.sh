#!/bin/bash

pushd "$(dirname "$0")"

. util.sh

echo "Cloning Repos"

git clone https://github.com/TacoSpigot/CraftBukkit.git CraftBukkit
git clone https://github.com/TacoSpigot/Bukkit.git Bukkit

mkdir work
git clone https://github.com/TacoSpigot/BuildData.git work/builddata

echo "Resetting to Upstream"
pushd Bukkit
git branch -f upstream
popd
pushd CraftBukkit
git branch -f upstream
popd

echo "Done Initing"
popd
