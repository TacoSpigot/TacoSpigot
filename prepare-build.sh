#!/bin/bash

git submodule update --recursive --init && \
echo "Updating Paper..." && \
cd Paper && \
git checkout ver/1.12.2 && \
echo "Updating BuildData..." && \
cd work/BuildData && \
git checkout be360cc298a06b5355ecd057f5b1feb894a73f0f && \
echo "Updating Bukkit..." && \
cd ../Bukkit && \
git checkout version/1.12.2 && \
echo "Updating CraftBukkit..." && \
cd ../CraftBukkit && \
git checkout version/1.12.2 && \
# echo "Updating Paperclip..." && \
# cd ../Paperclip && \
# git checkout ver/1.12.2 && \
cd ../../.. && \
./remap.sh && ./decompile.sh && ./init.sh && ./applyPatches.sh

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
