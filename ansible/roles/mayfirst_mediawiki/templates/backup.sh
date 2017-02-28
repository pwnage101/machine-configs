#!/bin/bash
# {{ ansible_managed }}

DB_NAME=wiki_sankey_info_db
DB_USER=wiki_readonly
DB_PASSWORD='{{ SECRETS.MAYFIRST.DB.wiki_sankey_info_db.wiki_readonly.PASSWORD }}'
DB_BACKUP_FILENAME=~/backup/wiki/db/${DB_NAME}-$(date '+%Y%m%d').sql.gz

WEB_SRC=/home/members/troysankey/sites/sankey.info/web/
WEB_DEST=/home/members/troysankey/sites/sankey.info/users/sankey/backup/wiki/web/

###################
# DATABASE BACKUP #
###################

db_backup_exists=false
if [[ -f "$DB_BACKUP_FILENAME" ]]; then
  db_backup_exists=true
  echo "backup.sh: backup file already exists, attempting to overwrite it anyway."
fi

nice -n 19 mysqldump -u "$DB_USER" --password="$DB_PASSWORD" --single-transaction "$DB_NAME" -c | nice -n 19 gzip --best > "$DB_BACKUP_FILENAME"

if [[ "$db_backup_exists" = true ]]; then
  echo "backup.sh: backup file overwritten: $DB_BACKUP_FILENAME"
else
  echo "backup.sh: backup file created: $DB_BACKUP_FILENAME"
fi

chmod 0600 "$DB_BACKUP_FILENAME"
chown sankey:sankey "$DB_BACKUP_FILENAME"

##############
# WEB BACKUP #
##############

echo "backup.sh: creating a snapshot of the docroot using rdiff-backup..."
/usr/bin/rdiff-backup -v4 "$WEB_SRC" "$WEB_DEST"

