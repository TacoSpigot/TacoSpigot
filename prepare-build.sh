cd $(dirname "$0")

./init.sh

if [ ! -d work/nms-src ]; then
echo "NMS Sources not found"
echo "Remapping Vanilla to NMS"
./remap-nms.sh
echo "Decompiling NMS"
./decompile-nms.sh
fi;

./apply-bukkit.sh
./applyPatches.sh