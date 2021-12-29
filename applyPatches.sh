#!/bin/bash

PS1="$"
basedir=`pwd`
gpgsign=$(git config commit.gpgsign)
echo "Rebuilding Forked projects.... "

function applyPatch {
    what=$1
    target=$2
    branch=$3
    mkdir -p "$basedir/$what"
    cd "$basedir/$what" || exit 1
    git fetch
    git branch -f upstream "$branch" >/dev/null

    cd "$basedir" || exit 1
    if [ ! -d  "$basedir/$target" ]; then
        git clone "$what" "$target"
    fi
    mkdir -p "$basedir/$target" 
    cd "$basedir/$target" || exit 1
    echo "Resetting $target to $what..."
    # Correctly handles already existing branches...
    git remote add -f upstream ../$what # || exit 1
    git checkout -B master || exit 1
    git fetch upstream || exit 1
    git reset --hard upstream/upstream || exit 1
    echo "  Applying patches to $target..."
    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${what}-Patches/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"
        enableCommitSigningIfNeeded
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

function enableCommitSigningIfNeeded {
    if [[ "$gpgsign" == "true" ]]; then
        echo "Re-enabling GPG Signing"
        # Yes, this has to be global
        git config --global commit.gpgsign true
    fi
}

# Disable GPG signing before AM, slows things down and doesn't play nicely.
# There is also zero rational or logical reason to do so for these sub-repo AMs.
# Calm down kids, it's re-enabled (if needed) immediately after, pass or fail.
if [[ "$gpgsign" == "true" ]]; then
    echo "_Temporarily_ disabling GPG signing"
    git config --global commit.gpgsign false
fi

applyPatch Bukkit Spigot-API HEAD && applyPatch CraftBukkit Spigot-Server patched
applyPatch Spigot-API PaperSpigot-API HEAD && applyPatch Spigot-Server PaperSpigot-Server HEAD
applyPatch PaperSpigot-API TacoSpigot-API HEAD && applyPatch PaperSpigot-Server TacoSpigot-Server HEAD

enableCommitSigningIfNeeded
