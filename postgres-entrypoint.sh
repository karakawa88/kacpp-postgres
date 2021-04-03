#!/bin/bash

PGDATA=${PGDATA:-/home/data/pgdata}
PG_USER=postgres
PG_GROUP=postgres

# PGDATAがないならクラスタ領域を作成する
if [[ ! -d $PGDATA ]]; then
    mkdir $PGDATA && chown -R ${PG_USER}.${PG_GROUP} ${PGDATA}
    su postgres -c "initdb -D ${PGDATA} --locale=C --encoding=UTF-8"
fi

# PostgreSQL起動
su postgres -c "cd /home/postgres;postgres -D ${PGDATA}"

