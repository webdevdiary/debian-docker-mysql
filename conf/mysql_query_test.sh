#!/bin/sh

mysql -umysql_test -pmysql_test mysql_test -e '
CREATE TABLE mysql_test (
  test_field text
);
INSERT INTO mysql_test (test_field) VALUES ("MySQL is working!!!");
SELECT * FROM mysql_test;
'
