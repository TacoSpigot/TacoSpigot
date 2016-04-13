#!/bin/bash

pushd Paper
MINECRAFT_VERSION=$(cat work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
popd
VANILLA_JAR=Paper/work/$MINECRAFT_VERSION/$MINECRAFT_VERSION.jar

VANILLA_URL="https://s3.amazonaws.com/Minecraft.Download/versions/$MINECRAFT_VERSION/minecraft_server.$MINECRAFT_VERSION.jar"

SERVER_JAR=TacoSpigot-Server/target/paper-$MINECRAFT_VERSION.jar

if [ ! -f "$SERVER_JAR" ]; then
    echo "Server Jar: $SERVER_JAR not found"
    exit 1;
fi;

./generateJar.sh "$SERVER_JAR" "$VANILLA_JAR" "$VANILLA_URL" "TacoSpigot"

if [ $? != 0 ]; then
    echo "Failed to generate jar"
    exit 1
fi;

mkdir -p build

cp work/Paperclip/TacoSpigot.jar build/TacoSpigot.jar
