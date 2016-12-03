#!/usr/bin/env python3

from subprocess import run
from argparse import ArgumentParser

def update(repo, version):
    print("Updating", repo, "to", version)
    run(["git", "fetch"], check=True, cwd=repo)
    run(["git", "reset", "--hard", version], check=True, cwd=repo)
    run(["git", "add", repo], check=True)

parser = ArgumentParser(description="Updates Paper to the specified version")
parser.add_argument("version", help="The version to update paper to", default="origin/master", nargs='?')

args = parser.parse_args()

update("Paper", args.version)

print("Updating submodules")
run(["git", "submodule", "update", "--recursive"], check=True)
