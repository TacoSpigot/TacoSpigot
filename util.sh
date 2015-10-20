UNAME="$(uname)"
OPNAME="${UNAME%%_*}"
case "x$OPNAME" in
	xMINGW32)
		unix2native() {
			echo -n "$1" | sed -e 's/\//\\/g' -e 's/^\\\([A-Z]\)\\/\1:\\/'
		}
		;;

	xCYGWIN)
		unix2native() {
			cygpath -w "$1"
		}
		;;

	*)
		unix2native() {
			echo -n "$1"
		}
esac

if hash md5sum 2> /dev/null; then
	filemd5() {
		md5sum "$1" | cut -f1 -d' '
	}
else
	filemd5() {
		md5 "$1" | cut -f4 -d' '
	}
fi

downloadfile() {
	local FILE="$1"
	local URL="$2"
	local MD5="$3"

	if [ -f "${FILE}" ]; then
		CALCMD5=$(filemd5 "${FILE}")
		if [ $CALCMD5 == $MD5 ]; then
			echo "Using cached version of ${FILE}"
			return
		fi

		echo "Found a cached but corrupted version of ${FILE} (expected MD5: ${NMS_MD5}, got ${CALCMD5})"
		rm "${FILE}"
	fi

	echo "Downloading ${FILE}"
	curl -o "${FILE}" "${URL}"

	CALCMD5=$(filemd5 "${FILE}")
	if [ $CALCMD5 == $NMS_MD5 ]; then
		echo "Download OK"
		return
	fi

	echo "Corrupted download (expected MD5: ${NMS_MD5}, got ${CALCMD5})"
	rm "${FILE}"
	exit 1
}

newcleandir() {
	local DIR="$1"

	if [ -d "${DIR}" ]; then
		echo "Cleaning up ${DIR}"
		rm -Rf "${DIR}"
	fi
	mkdir -p "${DIR}"
}
