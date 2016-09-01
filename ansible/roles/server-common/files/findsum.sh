#!/bin/bash
#
# look for checksums in a file
#
# $1 - the sha512 checksum of the line to look for
# $2 - the file to look in

# get the sha512sum of every line in a file.
function sums {
    while read -r LINE; do
        echo "$LINE" | sha512sum -
    done <"$1"
}

# for each line of the file, look for a given checksum
sums "$2" | grep -q "$1"
rc=$?

if [[ $rc -eq 0 ]]; then
    echo "SUCCESS: checksum found"
    exit 0
else
    echo "FAILURE: checksum not found"
    exit 1
fi
