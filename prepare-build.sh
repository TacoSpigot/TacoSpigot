#!/bin/bash

git submodule update --recursive --init && \
mkdir BuildTools-work && \
cd BuildTools-work &&\
java -jar ../BuildTools.jar --rev 1.13 && \
rm -rf ../Paper/Bukkit && \
mv Bukkit ../Paper && \
rm -rf ../Paper/Spigot && \
mv Spigot ../Paper && \
rm -rf ../Paper/BuildData && \
mv BuildData ../Paper && \
rm -rf ../Paper/CraftBukkit && \
mv CraftBukkit ../Paper && \
# echo "Updating Paperclip..." && \
# cd ../Paperclip && \
# git checkout ver/1.12.2 && \
cd ../ && \
./remap.sh && ./decompile.sh && ./init.sh && ./applyPatches.sh || exit 1

# Generate paperclip jar in this stage
mkdir -p work/Paperclip
PAPERCLIP_JAR=paperclip.jar

if [ ! -f work/Paperclip/$PAPERCLIP_JAR ]; then
    if [ ! -d Paperclip ]; then
        echo "Paperclip not found"
        exit 1;
    fi
    echo "Generating Paperclip Jar"
    pushd Paperclip
    mvn -P '!generate' clean install
    if [ ! -f target/paperclip*.jar ]; then
        echo "Couldn't generate paperclip jar"
        exit;
    fi;
    popd
    cp Paperclip/target/paperclip*.jar work/Paperclip/$PAPERCLIP_JAR
fi;
