#!/bin/bash -e
cd "$(dirname "$0")"

. util.sh
. version.sh

mkdir -p $(dirname ${NMS_JAR}) # Make the cache dir
downloadfile "${NMS_JAR}" "${NMS_URL}" "${NMS_MD5}"

echo "Creating cl-mapped jar"
java -jar work/builddata/bin/SpecialSource-2.jar map -i "${NMS_JAR}" -m "work/builddata/mappings/bukkit-${NMS_VERSION}-cl.csrg" -o "work/cl.jar"

echo "Creating member-mapped jar"
java -jar work/builddata/bin/SpecialSource-2.jar map -i "work/cl.jar" -m "work/builddata/mappings/bukkit-${NMS_VERSION}-members.csrg" -o "work/member.jar"

echo "Creating final mapped jar"
java -jar work/builddata/bin/SpecialSource.jar -i "work/member.jar" --access-transformer "work/builddata/mappings/bukkit-${NMS_VERSION}.at" -m "work/builddata/mappings/package.srg" -o "work/mapped.jar"

echo "Installing in Maven repository"
# We have to do this to ignore the tacospigot pom
pushd work
mvn install:install-file -Dfile="mapped.jar" -Dpackaging=jar -DgroupId=org.spigotmc -DartifactId=minecraft-server -Dversion="${NMS_VERSION}-SNAPSHOT"
popd