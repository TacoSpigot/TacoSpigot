#!/bin/bash

# Generates a patched jar for paperclip

if [[ $# < 4 ]]; then
    echo "Usage ./generateJar.sh {input jar} {mojang_jar} {source_url} {name}"
    exit 1;
fi;

workdir=work/Paperclip

mkdir -p $workdir
PAPERCLIP_JAR=paperclip.jar

if [ ! -f $workdir/$PAPERCLIP_JAR ]; then
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
    cp Paperclip/target/paperclip*.jar $workdir/$PAPERCLIP_JAR
fi;


INPUT_JAR=$1
VANILLA_JAR=$2
VANILLA_URL=$3
NAME=$4

which bsdiff 2>&1 >/dev/null
if [ $? != 0 ]; then
    echo "Bsdiff not found"
    exit 1;
fi;

OUTPUT_JAR=$NAME.jar
PATCH_FILE=$NAME.patch

hash() {
    echo $(sha256sum $1 | sed -E "s/(\S+).*/\1/")
}

echo "Computing Patch"

bsdiff $VANILLA_JAR $INPUT_JAR $workdir/$PATCH_FILE

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

cp $workdir/$PAPERCLIP_JAR $workdir/$OUTPUT_JAR

PATCH_JSON=patch.json

genJson $PATCH_FILE $VANILLA_URL $(hash $VANILLA_JAR) $(hash $INPUT_JAR) > $workdir/$PATCH_JSON

pushd $workdir

jar uf $OUTPUT_JAR $PATCH_FILE $PATCH_JSON

popd
