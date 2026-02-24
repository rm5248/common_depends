#!/bin/bash

FILE_TO_FIND=$1
VCPKG_CACHE_DIR=~/.cache/vcpkg

if [ ! -n "$FILE_TO_FIND" ]; then
	echo "Please provide a file to find"
	exit 1
fi

for f in $(find "$VCPKG_CACHE_DIR" -name '*.zip'); do
	unzip -l "$f" | grep -q $FILE_TO_FIND
	if [ $? -eq 0 ]; then
		echo "ZIP file $f contains file named $FILE_TO_FIND"
	fi
done
