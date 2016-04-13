#!/bin/bash

PS1="$"
basedir=`pwd`
gpgsign=$(git config commit.gpgsign)
echo "Rebuilding Forked projects.... "

function applyPatch {
    what=$1
    what_name=$(basename $what) # the 'name' of what, for situations where 'what' contains a slash
    target=$2
    branch=$3
    cd "$basedir/$what"
    git fetch
    git branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d  "$basedir/$target" ]; then
        git clone "$what" "$target"
    fi
    cd "$basedir/$target"
    echo "Resetting $target to $what_name..."
    git remote add -f upstream ../$what >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git fetch upstream >/dev/null 2>&1
    git reset --hard upstream/upstream
    echo "  Applying patches to $target..."
    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${what_name}-Patches/"*.patch
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

# Move into paper dir
pushd Paper
basedir=$basedir/Paper

# Move into spigot dir
pushd work/Spigot
basedir=$basedir/work/Spigot
# Apply Spigot
applyPatch ../Bukkit Spigot-API HEAD && applyPatch ../CraftBukkit Spigot-Server patched
# Move out of Spigot
popd
basedir=$(dirname $(dirname $basedir))

echo "Importing Paper MC Dev"

./scripts/importmcdev.sh

# Apply paper

applyPatch work/Spigot/Spigot-API Paper-API HEAD && applyPatch work/Spigot/Spigot-Server Paper-Server HEAD
# Move out of paper
popd
basedir=$(dirname $basedir)

echo "Importing TacoSpigot mc-dev"
./importmcdev.sh

# Apply TacoSpigot
applyPatch Paper/Paper-API TacoSpigot-API HEAD && applyPatch Paper/Paper-Server TacoSpigot-Server HEAD

enableCommitSigningIfNeeded
