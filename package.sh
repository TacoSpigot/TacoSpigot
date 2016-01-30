#!/bin/bash

MINECRAFT_VERSION=$(cat BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
VANILLA_JAR=work/$MINECRAFT_VERSION/$MINECRAFT_VERSION.jar

VANILLA_URL="https://s3.amazonaws.com/Minecraft.Download/versions/$MINECRAFT_VERSION/minecraft_server.$MINECRAFT_VERSION.jar"

./generateJar.sh TacoSpigot-Server/target/server*.jar $VANILLA_JAR $VANILLA_URL TacoSpigot

if [ $? != 0 ]; then
    echo "Failed to generate jar"
    exit 1
fi;

mkdir -p build

cp work/Paperclip/TacoSpigot.jar build/TacoSpigot.jar
