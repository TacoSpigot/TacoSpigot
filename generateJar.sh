#!/bin/bash

# Generates a patched jar for paperclip

if [[ $# -lt 4 ]]; then
    echo "Usage ./generateJar.sh {input jar} {mojang_jar} {source_url} {name}"
    exit 1;
fi;

basedir="$(pwd)"

mkdir -p work/Paperclip
PAPERCLIP_JAR=paperclip.jar

if [ ! -f work/Paperclip/$PAPERCLIP_JAR ]; then
    if [ ! -d Paperclip ]; then
        echo "Paperclip not found"
        exit 1;
    fi
    echo "Generating Paperclip Jar"
    pushd Paperclip
    mvn -P '!generate' clean install || exit 1
    RESULT_JARS=( target/paperclip*.jar )
    if [ ! -f ${RESULT_JARS[0]} ]; then
        echo "Couldn't generate paperclip jar" 2>/dev/null;
        exit 1;
    fi;
    cp "${RESULT_JARS[0]}" "$basedir/work/Paperclip/$PAPERCLIP_JAR"
    popd
fi;

if [ ! -f work/jbsdiff.jar ]; then
    echo "jbsdiff not found"
    if [ ! -d work/jbsdiff ]; then
        echo "Cloning jbsdiff"
        git clone "https://github.com/malensek/jbsdiff.git" work/jbsdiff
        if [ ! -d work/jbsdiff ]; then
            echo "Failed to clone bsdiff " 2>/dev/null;
            exit 1
        fi;
    fi
    echo "Compiling jbsdiff"
    pushd work/jbsdiff
    mvn clean package || exit 1
    RESULT_JARS=( target/jbsdiff*.jar )
    if [ ! -f ${RESULT_JARS[0]} ]; then
        echo "Couldn't generate jbsdiff jar" 2>/dev/null;
        exit 1;
    fi;
    cp "${RESULT_JARS[0]}" "$basedir/work/jbsdiff.jar"
    popd
fi;

INPUT_JAR=$1
VANILLA_JAR=$2
VANILLA_URL=$3
NAME=$4

OUTPUT_JAR=$NAME.jar
PATCH_FILE=$NAME.patch

hash() {
    echo "$(sha256sum $1 | sed -E "s/(\S+).*/\1/")"
}

echo "Computing Patch"

java -jar work/jbsdiff.jar diff $VANILLA_JAR $INPUT_JAR work/Paperclip/$PATCH_FILE || exit 1

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

cp work/Paperclip/$PAPERCLIP_JAR work/Paperclip/$OUTPUT_JAR

PATCH_JSON=patch.json

genJson $PATCH_FILE $VANILLA_URL "$(hash $VANILLA_JAR)" "$(hash $INPUT_JAR)" > work/Paperclip/$PATCH_JSON

pushd work/Paperclip

jar uf $OUTPUT_JAR $PATCH_FILE $PATCH_JSON

popd
