#!/bin/bash

cd "$(dirname "$0")"

. util.sh
. version.sh

pushd CraftBukkit
echo "Resetting to master"
git fetch origin
git checkout -B upstream origin/master
echo "Applying patches"
./applyPatches.sh ../work/nms-src
echo "Commiting NMS Sources"
git add "src/main/java/net/minecraft/server"
git commit -m "CraftBukkit \$ $(date)"
popd