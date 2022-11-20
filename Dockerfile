FROM debian AS with-mysql

SHELL ["/bin/bash", "-c"]

RUN apt-get update
RUN apt-get purge mysql-server mysql-common
RUN apt-get purge mysql-client
RUN apt-get install -y wget lsb-release gnupg

# RUN wget http://repo.mysql.com/mysql-apt-config_0.8.22-1_all.deb
# It's just a copy of the file above for caching purposes:
ADD ./mysql-apt-config_0.8.22-1_all.deb .

RUN printf "1\n1\n4\n" | dpkg -i mysql-apt-config_0.8.22-1_all.deb

RUN apt-get update

RUN debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password mysql_test"
RUN debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password mysql_test"
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

RUN mkdir -p /var/run/mysqld && \
    chown mysql /var/run/mysqld/

COPY --chmod=644 conf/mysql_startup.sh /mysql_startup.sh

USER mysql

CMD sh /mysql_startup.sh


FROM with-mysql AS testing

COPY --chmod=644 conf/mysql_connection_test.sh /mysql_connection_test.sh
COPY --chmod=644 conf/mysql_query_test.sh /mysql_query_test.sh

CMD sh /mysql_startup.sh && \
    until sh /mysql_connection_test.sh; do \
        sleep 10; \
    done; \
    sh /mysql_query_test.sh
