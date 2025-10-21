#!/bin/bash

FROM="/etc"
TO="/backup"
if [ ! -d "$TO" ]; then
    mkdir -p $TO
fi


Date=$(date +%F)

F_archive="Backup-etc-$Date.tar.xz"

tar -cJf "$TO/$F_archive" "$FROM"

echo "BACKUP DONE"