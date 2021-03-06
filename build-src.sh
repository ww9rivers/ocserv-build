#!/bin/bash

apt-get install -y build-essential autogen pkg-config texinfo libgmp3-dev gettext
apt-get install -y libxml2-dev libgeos++-dev libpq-dev libbz2-dev libreadline-dev libtool automake
apt-get install -y unbound-anchor libunbound-dev libev4 libev-dev
mkdir /etc/unbound
unbound-anchor -a "/etc/unbound/root.key"

mkdir -p /opt/src

cd /opt/src
NETTLE=nettle-3.4
wget ftp://ftp.gnu.org/gnu/nettle/${NETTLE}.tar.gz
tar xvzf ${NETTLE}.tar.gz
cd /opt/src/${NETTLE}
./configure --enable-shared --prefix=/opt/local --disable-assembler
make
make install

cd /opt/src
LIBTASN1=libtasn1-4.13
wget http://ftp.gnu.org/gnu/libtasn1/${LIBTASN1}.tar.gz
tar xvzf ${LIBTASN1}.tar.gz
cd /opt/src/${LIBTASN1}
./configure --prefix=/opt/local
make
make install

cd /opt/src
LIBFFI=libffi-3.2.1
wget ftp://sourceware.org/pub/libffi/${LIBFFI}.tar.gz
tar xvzf ${LIBFFI}.tar.gz
cd /opt/src/${LIBFFI}
./configure --prefix=/opt/local
make
make install

cd /opt/src
P11KITVER=0.23.2
P11KIT=p11-kit-$P11KITVER
wget -O "$P11KIT".tar.gz https://github.com/p11-glue/p11-kit/archive/${P11KITVER}.tar.gz
tar xvzf ${P11KIT}.tar.gz
cd /opt/src/${P11KIT}
PKG_CONFIG_PATH=/opt/local/lib/pkgconfig ./autogen.sh --prefix=/opt/local
make
make install

cd /opt/src
GNUTLS=gnutls-3.6.2
wget ftp://ftp.gnutls.org/gcrypt/gnutls/v3.6/${GNUTLS}.tar.xz
tar xvfJ ${GNUTLS}.tar.xz
cd /opt/src/${GNUTLS}
PKG_CONFIG_PATH=/opt/local/lib/pkgconfig ./configure --enable-shared --prefix=/opt/local --with-included-unistring
cp -f /opt/local/include/libtasn1.h /usr/local/include/
make
make install

cd /opt/src
mkdir lz4
LZ4_GIT='https://github.com/lz4/lz4'
LZ4_VERSION=`curl -s "${LZ4_GIT}/releases/latest" | sed -n 's/^.*tag\/\(.*\)".*/\1/p'` 
curl -SL "${LZ4_GIT}/archive/$LZ4_VERSION.tar.gz" -o lz4.tar.gz
tar -xf lz4.tar.gz -C lz4 --strip-components=1 
cd /opt/src/lz4 
make -j"$(nproc)" && make install
cd ..
cp -f /usr/local/lib/liblz4.* /usr/lib/

cd /opt/src
OPENSSL='openssl-1.1.0g'
wget https://www.openssl.org/source/${OPENSSL}.tar.gz
tar xvzf ${OPENSSL}.tar.gz
cd /opt/src/${OPENSSL}
./config
make depend
make
make install

cd /opt/src
PROTOBUF_GIT='https://github.com/google/protobuf'
PROTOBUF_VERSION=`curl -s "${PROTOBUF_GIT}/releases/latest" | sed -n 's/^.*tag\/v\(.*\)".*/\1/p'`
PROTOBUF="protobuf-${PROTOBUF_VERSION}"
curl -SL "$PROTOBUF_GIT/archive/v${PROTOBUF_VERSION}.tar.gz" -o ${PROTOBUF}.tar.gz
tar xzfv "${PROTOBUF}".tar.gz
PROTOBUF_GIT='https://github.com/google/protobuf'
cd /opt/src/"${PROTOBUF}"
./autogen.sh
./configure --prefix=/opt/local
make
# make check && make install -- "make check" fails
#	protobuf_CFLAGS
#	protobuf_LIBS
make install
ldconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/local/lib/pkgconfig

cd /opt/src
PROTOBUF_C_VERSION=1.3.0
curl -SL "https://github.com/protobuf-c/protobuf-c/archive/v${PROTOBUF_C_VERSION}.tar.gz" -o protobuf-c.tar.gz
mkdir protobuf-c
cd protobuf-c
tar -xf ../protobuf-c.tar.gz --strip-components=1
./autogen.sh && ./configure --prefix=/opt/local && make && make install

#
# Extra dependencies:
#
#	libev-dev
#
cd /opt/src
OCSERV=ocserv-0.11.11
wget ftp://ftp.infradead.org/pub/ocserv/${OCSERV}.tar.xz
tar xvf ${OCSERV}.tar.xz
cd /opt/src/${OCSERV}
PKG_CONFIG_PATH=/opt/local/lib/pkgconfig ./configure --prefix=/opt/ocserv --with-libev-prefix=/usr
LD_LIBRARY_PATH=/opt/local/lib make
make install
