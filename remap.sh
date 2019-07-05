#!/bin/bash

pushd Paper # TacoSpigot

PS1="$"
basedir=`pwd`
workdir=$basedir/work
minecraftversion=$(cat work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
minecrafthash=$(cat work/BuildData/info.json | grep minecraftHash | cut -d '"' -f 4)
accesstransforms=work/BuildData/mappings/$(cat work/BuildData/info.json | grep accessTransforms | cut -d '"' -f 4)
classmappings=work/BuildData/mappings/$(cat work/BuildData/info.json | grep classMappings | cut -d '"' -f 4)
membermappings=work/BuildData/mappings/$(cat work/BuildData/info.json | grep memberMappings | cut -d '"' -f 4)
packagemappings=work/BuildData/mappings/$(cat work/BuildData/info.json | grep packageMappings | cut -d '"' -f 4)
jarpath=$workdir/Minecraft/$minecraftversion/$minecraftversion
minecrafturl=https://theseedmc.com/mirrors/vanilla_1.13.jar
useragent='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36'

echo "[TacoSpigot/remap.sh] Downloading unmapped vanilla jar from $minecrafturl to $jarpath..."
if [ ! -f  "$jarpath.jar" ]; then
    mkdir -p "$workdir/Minecraft/$minecraftversion"
    curl -A "$useragent" -s -o "$jarpath.jar" "$minecrafturl"
    if [ "$?" != "0" ]; then
        echo "Failed to download the vanilla server jar. Check connectivity or try again later."
        exit 1
    fi
fi

# OS X doesn't have md5sum, just md5 -r
if [[ "$OSTYPE" == "darwin"* ]]; then
   shopt -s expand_aliases
   alias md5sum='md5 -r'
   echo "[TacoSpigot/remap.sh] Using an alias for md5sum on OS X"
fi

checksum=$(md5sum "$jarpath.jar" | cut -d ' ' -f 1)
if [ "$checksum" != "$minecrafthash" ]; then
    echo "[TacoSpigot/remap.sh] The MD5 checksum of the downloaded server jar ($checksum) does not match the work/BuildData hash ($minecrafthash)."
    exit 1
fi

echo "[TacoSpigot/remap.sh] Applying class mappings..."
if [ ! -f "$jarpath-cl.jar" ]; then
    if [ ! -f "$classmappings" ]; then
        echo "[TacoSpigot/remap.sh] Class mappings not found!"
        exit 1
    fi
    java -jar work/BuildData/bin/SpecialSource-2.jar map -i "$jarpath.jar" -m "$classmappings" -o "$jarpath-cl.jar"
    if [ "$?" != "0" ]; then
        echo "[TacoSpigot/remap.sh] Failed to apply class mappings."
        exit 1
    fi
fi

echo "[TacoSpigot/remap.sh] Applying member mappings..."
if [ ! -f "$jarpath-m.jar" ]; then
    if [ ! -f "$membermappings" ]; then
        echo "[TacoSpigot/remap.sh] Member mappings not found!"
        exit 1
    fi
    java -jar work/BuildData/bin/SpecialSource-2.jar map -i "$jarpath-cl.jar" -m "$membermappings" -o "$jarpath-m.jar"
    if [ "$?" != "0" ]; then
        echo "[TacoSpigot/remap.sh] Failed to apply member mappings."
        exit 1
    fi
fi

echo "[TacoSpigot/remap.sh] Creating remapped jar..."
if [ ! -f "$jarpath-mapped.jar" ]; then
    java -jar work/BuildData/bin/SpecialSource.jar --kill-lvt -i "$jarpath-m.jar" --access-transformer "$accesstransforms" -m "$packagemappings" -o "$jarpath-mapped.jar"
    if [ "$?" != "0" ]; then
        echo "[TacoSpigot/remap.sh] Failed to create remapped jar."
        exit 1
    fi
fi

echo "[TacoSpigot/remap.sh] Installing remapped jar..."
cd work/CraftBukkit # Need to be in a directory with a valid POM at the time of install.
mvn install:install-file -q -Dfile="$jarpath-mapped.jar" -Dpackaging=jar -DgroupId=org.spigotmc -DartifactId=minecraft-server -Dversion="$minecraftversion-SNAPSHOT"
if [ "$?" != "0" ]; then
    echo "[TacoSpigot/remap.sh] Failed to install remapped jar."
    exit 1
fi

popd # TacoSpigot
