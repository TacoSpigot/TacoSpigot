#!/bin/bash

# Generates a patched jar for paperclip

if [[ $# < 3 ]]; then
    echo "Usage ./generateJar.sh {input jar} {minecraft_version} {name}"
    exit 1;
fi;

PAPERCLIP_JAR=paperclip.jar

if [ ! -f $PAPERCLIP_JAR ]; then
    if [[ -d ".git" ]]; then
        REPO=$(pwd)
        pushd .
    else
        if [ ! -d Paperclip ]; then
            git clone "https://github.com/TacoSpigot/Paperclip.git";
        fi
        REPO=$(pwd)/Paperclip
        pushd Paperclip
    fi;   
    mvn -P '!generate' clean install
    popd
    if [ ! -f $REPO/target/paperclip*.jar ]; then
        echo "Couldn't generate paperclip jar"
        exit;
    fi;
    cp $REPO/target/paperclip*.jar $PAPERCLIP_JAR
fi;

INPUT_JAR=$1
MINECRAFT_VERSION=$2
NAME=$3

VANILLA_URL="https://s3.amazonaws.com/Minecraft.Download/versions/$MINECRAFT_VERSION/minecraft_server.$MINECRAFT_VERSION.jar"
VANILLA_JAR=vanilla-1.8.8.jar

if [ ! -f $VANILLA_JAR ]; then
    echo "Downloading Vanilla Jar"
    wget -O "$VANILLA_JAR" $VANILLA_URL 2>&1 >/dev/null
    if [[ $? != 0 ]]; then
        echo "Error downloading vanilla jar"
        exit 1;
    fi;
fi;

which bsdiff4 2>&1 >/dev/null
if [ $? != 0 ]; then
    echo "Bsdiff4 not found"
    exit 1;
fi;

OUTPUT_JAR=$NAME.jar
PATCH_FILE=$NAME.patch

hash() {
    echo $(sha256sum $1 | sed -E "s/(\S+).*/\1/")
}

echo "Computing Patch"

bsdiff4 $VANILLA_JAR $INPUT_JAR $PATCH_FILE

genJson() {
    PATCH=$1
    SOURCE_URL=$2
    ORIGINAL_HASH=$3
    PATCHED_HASH=$4
    echo "{"
    echo "    \"patch\": \"$PATCH\","
    echo "    \"sourceUrl\": \"$SOURCE_URL\","
    echo "    \"originalHash\": \"$ORIGINAL_HASH\","
    echo "    \"patchedHash\": \"$PATCHED_HASH\""
    echo "}"
}

echo "Generating Final Jar"

cp $PAPERCLIP_JAR $OUTPUT_JAR

genJson $PATCH_FILE $VANILLA_URL $(hash $VANILLA_JAR) $(hash $INPUT_JAR) > patch.json

jar uf $OUTPUT_JAR $PATCH_FILE patch.json
