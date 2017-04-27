#!/bin/bash
printHelp() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "    -h, --help            Print this help message"
    echo "    -O, --aggressive      Run git gc --aggressive"
    echo "    -p, --prune           Prune all loose objects"
    echo "    -r, --repack          Repack all objects in the repository"
    echo "    -f, --force           Imply --aggressive --prune --repack"
    echo "    -v, --verbose         Show status output from git"
}

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            printHelp
            ;;
        -O|--aggressive)
            AGGRESSIVE=true
            ;;
        -p|--prune)
            PRUNE=true
            ;;
        -r|--repack)
            REPACK=true
            ;;
        -f|--force)
            AGGRESSIVE=true
            PRUNE=true
            REPACK=true
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
        *)
            echo "Unknown option: $arg" >&2
            printHelp >&2
            exit 1
        ;;
    esac
done

shopt -s globstar nullglob
REPOSITORIES=()
for git_dir in **/.git; do
    repo="$(dirname $git_dir)"
    repo="$(realpath --relative-to=. $repo)" # Relativize\
    REPOSITORIES+=("$repo")
done;
OPTIONS=()
REPACK_OPTIONS=("-ad")
if [ $AGGRESSIVE ]; then
    OPTIONS+=("--aggressive");
fi;
if [ $PRUNE ]; then
    OPTIONS+=("--prune=now");
fi
if [ ! $VERBOSE ]; then
    OPTIONS+=("-q")
    REPACK_OPTIONS+=("-q")
fi
echo "Using git gc" "${OPTIONS[@]}"
if [ $REPACK ]; then
    echo "Using git repack" "${REPACK_OPTIONS[@]}"
fi;
for repo in "${REPOSITORIES[@]}"; do
    pushd "$repo" > /dev/null
    echo "Cleaning $repo"
    git gc "${OPTIONS[@]}" || { popd & exit 1; }
    if [ $REPACK ]; then
        if [ $VERBOSE ]; then
            echo "Repacking $repo"
        fi
        git repack "${REPACK_OPTIONS[@]}" || { popd & exit 1; }
    fi;
    popd > /dev/null
done;
