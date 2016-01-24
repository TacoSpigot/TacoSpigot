echo "Compiling"

#mvn clean install
mvn install -DskipTests

PATCHED_JAR=$(pwd)/TacoSpigot-Server/target/server*.jar

if [ ! -f $PATCHED_JAR ]; then
    echo "Can't find compiled jar"
    exit 1
fi

echo "Generating Patching Jar"

if [ ! -d work/Paperclip/.git ]; then
    git clone https://github.com/PaperSpigot/Paperclip.git work/Paperclip
fi

pushd work/Paperclip 
echo "Current dir $(pwd)"
bash ../../generateJar.sh $PATCHED_JAR 1.8.8 TacoSpigot
popd

mkdir -p build
cp work/Paperclip/TacoSpigot.jar build/TacoSpigot-1.8.8.jar
