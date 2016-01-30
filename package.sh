#!/bin/bash

MINECRAFT_VERSION=$(cat BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
VANILLA_JAR=work/$MINECRAFT_VERSION/$MINECRAFT_VERSION.jar

./generateJar.sh TacoSpigot-Server/target/server*.jar $VANILLA_JAR TacoSpigot

if [ $? != 0 ]; then
    echo "Failed to generate jar"
    exit 1
fi;

mkdir build

cp work/Paperclip/TacoSpigot.jar build/TacoSpigot.jar
