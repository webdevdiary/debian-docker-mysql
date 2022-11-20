#!/bin/sh

MYSQL_DATABASE=${MYSQL_DATABASE:-"mysql_test"}
MYSQL_USER=${MYSQL_USER:-"mysql_test"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"mysql_test"}

tfile=`mktemp`
if [ ! -f "$tfile" ]; then
    return 1
fi

if [ "$MYSQL_DATABASE" != "" ]; then
  echo "[i] Creating database: $MYSQL_DATABASE"
  echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

  if [ "$MYSQL_USER" != "" ]; then
    echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
    echo "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
    echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'localhost';" >> $tfile
  fi
fi

mysqld --verbose --init-file=$tfile &
