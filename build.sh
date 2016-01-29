#!/bin/bash

./prepare-build.sh && mvn clean install && ./package.sh
