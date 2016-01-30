#!/bin/bash

# Generates a patched jar for paperclip

if [[ $# < 3 ]]; then
    echo "Usage ./generateJar.sh {input jar} {mojang_jar} {name}"
    exit 1;
fi;

mkdir -p work/Paperclip
PAPERCLIP_JAR=work/Paperclip/paperclip.jar

if [ ! -f $PAPERCLIP_JAR ]; then
    if [ ! -d Paperclip ]; then
        echo "Paperclip not found"
        exit 1;
    fi
    pushd Paperclip
    mvn -P '!generate' clean install
    if [ ! -f target/paperclip*.jar ]; then
        echo "Couldn't generate paperclip jar"
        exit;
    fi;
    popd
    cp Paperclip/target/paperclip*.jar $PAPERCLIP_JAR
fi;

INPUT_JAR=$1
VANILLA_JAR=$2
NAME=$3

which bsdiff4 2>&1 >/dev/null
if [ $? != 0 ]; then
    echo "Bsdiff4 not found"
    exit 1;
fi;

OUTPUT_JAR=work/Paperclip/$NAME.jar
PATCH_FILE=work/Paperclip/$NAME.patch

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

PATCH_JSON="work/Paperclip/patch.json"

genJson $PATCH_FILE $VANILLA_URL $(hash $VANILLA_JAR) $(hash $INPUT_JAR) > $PATCH_JSON

jar uf $OUTPUT_JAR $PATCH_FILE $PATCH_JSON
