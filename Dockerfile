FROM alpine:3.9.4

LABEL name="rsyslog" \
	version="0.1.0" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="simple and robust facilities for system loggin" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk update --upgrade \
	&& apk add libestr libfastjson zlib util-linux openssl libcurl \
		librelp liblognorm postgresql-libs \
	&& apk add --no-cache --virtual .build-dependencies \
		libtool gcc make musl-dev curl openssl-dev linux-headers \
		autoconf automake libestr-dev libfastjson-dev zlib-dev \
		postgresql-dev flex bison tree \
		util-linux-dev openssl-dev curl-dev librelp-dev liblognorm-dev \
	&& mkdir /root/rsyslog-src && cd /root/rsyslog-src \
	&& curl https://github.com/rsyslog/rsyslog/archive/v8.1904.0.tar.gz -L \
		| tar xz --strip-components=1 -C . \
	&& autoreconf -i -f \
	&& ./configure --prefix=/usr CFLAGS="-O2 -pipe" --disable-libgcrypt \
		 --enable-openssl --enable-mmkubernetes --enable-omhttp --enable-relp \
		 --enable-elasticsearch --enable-mmaudit --enable-mmnormalize \
		 --enable-psql --enable-mmjsonparse \
	&& make -j4 \
	&& mkdir /root/rsyslog \
	&& make DESTDIR=/root/rsyslog install \
	&& rm /root/rsyslog/usr/lib/rsyslog/*la \
	&& rm -rf /root/rsyslog/usr/share \
	&& find /root/rsyslog -type f | xargs strip \
	&& tree /root/rsyslog \
	&& cp -R /root/rsyslog / \
	&& cd / && rm -rf /root/rsyslog-src && rm -rf /root/rsyslog \
	&& apk del .build-dependencies \
	&& rm -rf /var/cache/apk
