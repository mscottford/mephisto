FROM pblaszczyk/debian-etch

# prevent apt-get errors about `dialog` and `readline` not being available
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install postgresql-7.4 postgresql-client-7.4 postgresql-contrib-7.4

USER postgres

RUN /etc/init.d/postgresql-7.4 start && psql template1 --command "ALTER USER postgres WITH CREATEDB CREATEUSER PASSWORD 'postgres';" && createdb -O postgres postgres

EXPOSE 5432

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/7.4/main/pg_hba.conf

CMD ["/usr/lib/postgresql/7.4/bin/postmaster", "-D", "/var/lib/postgresql/7.4/main", "-i"]
