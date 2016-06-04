#!/usr/bin/env bash

nms="net/minecraft/server"
export MODLOG=""
PS1="$"
basedir=`pwd`

workdir=$basedir/Paper/work
minecraftversion=$(cat Paper/work/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
decompiledir=$workdir/$minecraftversion

export importedmcdev=""
function import {
	export importedmcdev="$importedmcdev $1"
	file="${1}.java"
        target="$basedir/Paper/Paper-Server/src/main/java/$nms/$file"
	base="$decompiledir/$nms/$file"

	if [[ ! -f "$target" ]]; then
		export MODLOG="$MODLOG  Imported $file from mc-dev\n";
		echo "Copying $base to $target"
		cp "$base" "$target"
	fi
}

(
	cd Paper/Paper-Server/
	lastlog=$(git log -1 --oneline)
	if [[ "$lastlog" = *"mc-dev Imports"* ]]; then
		git reset --hard HEAD^
	fi
)

# Sources to import
import IBlockState
import BlockState
import BlockStateBoolean
import BlockStateEnum
import BlockStateInteger
import BlockStateList
import PacketEncoder

(
	cd Paper/Paper-Server/
	git add src -A
	echo -e "mc-dev Imports\n\n$MODLOG" | git commit src -F -
)
