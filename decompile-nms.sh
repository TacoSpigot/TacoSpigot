#!/bin/bash -e
cd "$(dirname "$0")"

. util.sh
. version.sh

if [ ! -f "work/mapped.jar" ]; then
	echo "Could not found mapped jar. Please run remap-nms.sh and try again"
	exit 1
fi

newcleandir "work/classes"
echo "Extracting classes"
unzip "work/mapped.jar" "net/minecraft/server/*" -d "work/classes"

newcleandir work/nms-src
echo "Decompiling using FernFlower"
java -jar work/builddata/bin/fernflower.jar -dgs=1 -hdc=0 -rbr=0 -asc=1 -udv=0 "work/classes" work/nms-src

