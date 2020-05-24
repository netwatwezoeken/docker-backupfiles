#!/bin/bash
backupname=$BACKUP_NAME-$(date +%Y%m%d-%H%M%S)

if ! tar -zcvf $backupname.tgz /data/*; then
	echo "Could not create backup archive" 1>&2
	exit 1
fi

if [[ -z "${MINIO_HOST}" ]]; then
	if ! cp $backupname.tgz /backup/; then
		echo "Could not copy backup archive to target directory" 1>&2
		exit 1
	fi
else
	
	if ! mc config host add minio $MINIO_HOST $MINIO_ACCESS_KEY $MINIO_SECRET_KEY; then
		echo "Could not connect to MinIO" 1>&2
		exit 1
	fi
	if ! mc cp $backupname.tgz minio/$MINIO_BACKUP_BUCKET; then
		echo "Could not upload backup archive" 1>&2
		exit 1
	fi
fi

echo "Completed" $backupname