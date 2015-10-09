TacoSpigot[![Build Status](https://travis-ci.org/TacoSpigot/TacoSpigot.svg?branch=master)](https://travis-ci.org/TacoSpigot/TacoSpigot)
===========

A even-higher high performance Spigot fork that adds new features.

[IRC Support and Project Discussion](http://irc.spi.gt/iris/?channels=techcable)

[Contribution Guidelines](Contributing.md)


How To
---------------------------------

Apply Patches : `./applyPatches.sh`

### Create patch for server ###

`cd PaperSpigot-Server`

Add your file for commit : `git add <file>`

Commit : `git commit -m <msg>`

`cd ..`

Create Patch `./rebuildPatches.sh`

### Create patch for API ###

`cd Paperspigot-API`

Add your file for commit : `git add <file>`

Commit : `git commit -m <msg>`

`cd ..`

Create Patch `./rebuildPatches.sh`




Compilation
-----------

We use maven to handle our dependencies.

* Install [Maven 3](http://maven.apache.org/download.html)
* Clone this repo and: `mvn clean install`
