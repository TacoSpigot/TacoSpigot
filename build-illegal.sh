#!/bin/bash
# Build an 'illegal' version of the TacoSpigot jar, which violates the DMCA.
# Although it's technically legal to use this jar on your own computer,
# distributing it to somone else is illegal without first packaging it with Paperclip.
# 
# TLDR: Only use this jar on your own computer, or you'll get sued.
./prepare-build.sh || exit 1
mvn clean install || exit 1

MINECRAFT_VERSION=$(cat Paper/work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
SERVER_JAR=TacoSpigot-Server/target/paper-$MINECRAFT_VERSION.jar
if [ ! -f $SERVER_JAR ]; then
    echo "Unable to find compiled jar!"
    exit 1;
fi

mkdir -p build
cp $SERVER_JAR build/TacoSpigot-illegal.jar

