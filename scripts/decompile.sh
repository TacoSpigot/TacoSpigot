#!/bin/bash

pushd Paper # TacoSpigot

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
minecraftversion=$(cat work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
windows="$([[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]] && echo "true" || echo "false")"
decompiledir="$workdir/Minecraft/$minecraftversion"
spigotdecompiledir="$decompiledir/spigot"
forgedecompiledir="$decompiledir/forge"
forgeflowerversion="1.5.380.19"
forgeflowerurl="http://files.minecraftforge.net/maven/net/minecraftforge/forgeflower/$forgeflowerversion/forgeflower-$forgeflowerversion.jar"
# temp use patched version
forgeflowerurl="https://zachbr.keybase.pub/paper/forgeflower-patched/forgeflower-1.5.380.19.jar?dl=1"
forgeflowerbin="$workdir/ForgeFlower/$forgeflowerversion.jar"
# TODO: Make this better? We don't need spigot compat for this stage
forgefloweroptions="-dgs=1 -hdc=0 -asc=1 -udv=1 -jvn=1"
forgeflowercachefile="$decompiledir/forgeflowercache"
forgeflowercachevalue="$forgeflowerurl - $forgeflowerversion - $forgefloweroptions";
classdir="$decompiledir/classes"
versionjson="$workdir/Minecraft/$minecraftversion/$minecraftversion.json"

if [[ ! -f "$versionjson" ]]; then
    echo "Downloading $minecraftversion JSON Data"
    verescaped=$(echo ${minecraftversion} | sed 's/\./\\./g')
    verentry=$(curl -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" | grep -oE "{\"id\": \"${verescaped}\".*${verescaped}\.json")
    jsonurl=$(echo ${verentry} | grep -oE https:\/\/.*\.json)
    curl -o "$versionjson" "$jsonurl"
    echo "$versionjson - $jsonurl"
fi

function downloadLibraries {
    group=$1
    groupesc=$(echo ${group} | sed 's/\./\\./g')
    grouppath=$(echo ${group} | sed 's/\./\//g')
    libdir="$decompiledir/libraries/${group}/"
    mkdir -p "$libdir"
    shift
    for lib in "$@"
    do
        jar="$libdir/${lib}-sources.jar"
        destlib="$libdir/${lib}"
        if [[ ! -f "$jar" ]]; then
            libesc=$(echo ${lib} | sed 's/\./\\]./g')
            ver=$(grep -oE "${groupesc}:${libesc}:[0-9\.]+" "$versionjson" | sed "s/${groupesc}:${libesc}://g")
            echo "Downloading ${group}:${lib}:${ver} Sources"
            curl -s -o "$jar" "https://libraries.minecraft.net/${grouppath}/${lib}/${ver}/${lib}-${ver}-sources.jar"
            set +e
            grep "<html>" "$jar" && grep -oE "<title>.*?</title>" "$jar" && rm "$jar" && echo "Failed to download $jar" && exit 1
            set -e
        fi

        if [[ ! -d "$destlib/$grouppath" ]]; then
            echo "Extracting $group:$lib Sources"
            mkdir -p "$destlib"
            (cd "$destlib" && jar xf "$jar")
        fi
    done
}

downloadLibraries "com.mojang" datafixerupper authlib brigadier

# prep folders
mkdir -p "$workdir/ForgeFlower"
mkdir -p "$spigotdecompiledir"
mkdir -p "$forgedecompiledir"

echo "Extracting NMS classes..."
if [[ ! -d "$classdir" ]]; then
    mkdir -p "$classdir"
    cd "$classdir"
    set +e
    jar xf "$decompiledir/$minecraftversion-mapped.jar" net/minecraft/server
    if [[ "$?" != "0" ]]; then
        cd "$basedir"
        echo "Failed to extract NMS classes."
        exit 1
    fi
    set -e
fi

if [[ -d "$decompiledir/net" ]]; then
    cp -r "$decompiledir/net" "$spigotdecompiledir/"
fi

if [[ ! -d "$spigotdecompiledir/net" ]]; then
    echo "Decompiling classes (stage 2)..."
    cd "$basedir"
    set +e
    java -jar "$workdir/BuildData/bin/fernflower.jar" -dgs=1 -hdc=0 -asc=1 -udv=0 "$classdir" "$spigotdecompiledir"
    if [[ "$?" != "0" ]]; then
        rm -rf "$spigotdecompiledir/net"
        echo "Failed to decompile classes."
        exit 1
    fi
fi

# set a symlink to current
currentlink="$workdir/Minecraft/current"
if ([[ ! -e "$currentlink" ]] || [[ -L "$currentlink" ]]) && [[ "$windows" == "false" ]]; then
	set +e
	echo "Pointing $currentlink to $minecraftversion"
	rm -rf "$currentlink" || true
	ln -sfn "$minecraftversion" "$currentlink" || echo "Failed to set current symlink"
fi
)

popd # TacoSpigot