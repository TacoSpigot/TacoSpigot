#!/bin/bash

pushd Paper # TacoSpigot

PS1="$"
basedir=`pwd`
workdir=$basedir/work
minecraftversion=$(cat work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
decompiledir=$workdir/Minecraft/$minecraftversion
nms=$decompiledir/net/minecraft/server
cb=src/main/java/net/minecraft/server

patch=$(which patch 2>/dev/null)
if [ "x$patch" == "x" ]; then
    patch=$basedir/hctap.exe
fi

echo "Applying CraftBukkit patches to NMS..."
cd "$basedir/work/CraftBukkit"
git checkout -B patched HEAD >/dev/null 2>&1
rm -rf $cb
mkdir -p $cb
for file in $(ls nms-patches)
do
    patchFile="nms-patches/$file"
    file="$(echo $file | cut -d. -f1).java"

    echo "Patching $file < $patchFile"
    sed -i 's/\r//' "$nms/$file" > /dev/null

    cp "$nms/$file" "$cb/$file"
    "$patch" -s -d src/main/java/ "net/minecraft/server/$file" < "$patchFile"
done

git add src >/dev/null 2>&1
git commit -m "CraftBukkit $ $(date)" >/dev/null 2>&1
git checkout -f HEAD^ >/dev/null 2>&1

popd # TacoSpigot
