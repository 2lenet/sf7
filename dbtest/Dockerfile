FROM mariadb:10.4 AS builder

# That file does the DB initialization but also runs mysql daemon, by removing the last line it will only init
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

# needed for intialization
ENV MARIADB_DATABASE=[PROJECT]
ENV MARIADB_ROOT_PASSWORD=pass
ENV MARIADB_ROOT_HOST=%

COPY db.sql.gz /docker-entrypoint-initdb.d/db.sql.gz

# Need to change the datadir to something else that /var/lib/mysql because the parent docker file defines it as a volume.
# https://docs.docker.com/engine/reference/builder/#volume :
#       Changing the volume from within the Dockerfile: If any build steps change the data within the volume after
#       it has been declared, those changes will be discarded.
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db"]

FROM mariadb:10.4

ENV MARIADB_DATABASE=[PROJECT]
ENV MARIADB_ROOT_PASSWORD=pass
ENV MARIADB_ROOT_HOST=%

COPY --from=builder /initialized-db /var/lib/mysql2
COPY mysqld.cnf /etc/mysql/mariadb.conf.d/
RUN chmod -R 644 /etc/mysql/mariadb.conf.d/mysqld.cnf

CMD ["mysqld"]
