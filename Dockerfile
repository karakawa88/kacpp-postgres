# PstgreSQL環境を持つdebianイメージ
# 日本語化も設定済み
FROM        kagalpandh/kacpp-gccdev AS builder
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
ENV         DEBIAN_FORONTEND=noninteractive
ENV         POSTGRES_VERSION=13.2
ENV         POSTGRES_SRC=postgresql-${POSTGRES_VERSION}
ENV         POSTGRES_SRC_FILE=${POSTGRES_SRC}.tar.bz2
ENV         POSTGRES_URL= https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/${POSTGRES_SRC_FILE}
ENV         POSTGRES_DEST=${POSTGRES_SRC}
ENV         PGHOME=/usr/local/${PYTHON_DEST}
ENV         PATH=${PYTHON_HOME}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV         LD_LIBRARY_PATH=${PYTHON_HOME}/lib
COPY        python-source-install.txt  /usr/local/sh/apt-install
# 開発環境インストール
RUN         apt update \
            && /usr/local/sh/system/apt-install.sh install gccdev.txt \
            && wget ${POSTGRES_URL} && tar -jxvf ${POSTGRES_SRC_FILE} && cd ${POSTGRES_SRC} \
                &&  ./configure --prefix=/usr/local/${POSTGRES_DEST} --enable-shared --with-openssl \
                && make && make install  \
                && cd contrib/pgcrypto && make && make install \
            && /usr/local/sh/system/apt-install.sh uninstall gccdev.txt \
                && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* \
                && cd ../ && rm -rf ${POSTGRES_DEST}*
FROM        kagalpandh/kacpp-pydev
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
EXPOSE      5432
VOLUME      ["/home/data"]
ENV         POSTGRES_VERSION=13.2
ENV         POSTGRES_DEST=postgresql-${POSTGRES_VERSION}
ENV         PGHOME=/usr/local/${POSTGRES_DEST}
ENV         PGDATA=/home/data/pgdata
ENV         PATH=${PGHOME}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV         LD_LIBRARY_PATH=${PGHOME}/lib
RUN         mkdir /root/${POSTGRES_DEST}
COPY        --from=builder /usr/local/${POSTGRES_DEST}/ /root/${$POSTGRES_DEST}
COPY        rcprofile /etc/rc.d
RUN         apt update && \
#   porgでPythonをパッケージ管理
#             chown -R root.root /usr/local && \
#             find ${PYTHON_HOME} -type f -print | xargs porg -l -p ${PYTHON_DEST} && \
            cd ${POSTGRES_DEST} && porg -lD "cp -r /root/${POSTGRES_DEST} /usr/local/${POSTGRES_DEST}" && \
            echo "${PGHOME}/lib" >>/etc/ld.so.conf && ldconfig && \
            cd ~/ && apt clean && rm -rf /var/lib/apt/lists/* && rm -rf ${POSTGRES_DEST}

