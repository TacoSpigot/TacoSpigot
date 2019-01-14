#!/bin/bash

pushd Paper # TacoSpigot

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
minecraftversion=$(cat work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
spigotdecompiledir="$workdir/Minecraft/$minecraftversion/spigot"
nms="$spigotdecompiledir/net/minecraft/server"
cb="src/main/java/net/minecraft/server"
gitcmd="git -c commit.gpgsign=false"

patch=$(which patch 2>/dev/null)
if [[ "x$patch" == "x" ]]; then
    patch=${basedir}/hctap.exe
fi

echo "Applying CraftBukkit patches to NMS..."
cd "$basedir/work/CraftBukkit"
${gitcmd} checkout -B patched HEAD >/dev/null 2>&1
rm -rf "$cb"
mkdir -p "$cb"
for file in $(ls nms-patches)
do
    patchFile="nms-patches/$file"
    file="$(echo "$file" | cut -d. -f1).java"
    cp "$nms/$file" "$cb/$file"
done
${gitcmd} add src
${gitcmd} commit -m "Minecraft $ $(date)" --author="Auto <auto@mated.null>"

for file in $(ls nms-patches)
do
    patchFile="nms-patches/$file"
    file="$(echo "$file" | cut -d. -f1).java"

    echo "Patching $file < $patchFile"
    set +e
    sed -i 's/\r//' "$nms/$file" > /dev/null
    set -e

    "$patch" -s -d src/main/java/ "net/minecraft/server/$file" < "$patchFile"
done

${gitcmd} add src >/dev/null 2>&1
${gitcmd} commit -m "CraftBukkit $ $(date)" --author="Auto <auto@mated.null>" >/dev/null 2>&1
${gitcmd} checkout -f HEAD~2 >/dev/null 2>&1

popd # TacoSpigot
)
