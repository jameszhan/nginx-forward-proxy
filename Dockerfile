FROM debian:bullseye-slim

LABEL maintainer="James Zhan <zhiqiangzhan@gmail.com>"

ARG https_proxy

RUN set -x \
    && addgroup --system --gid 101 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg1 ca-certificates \
    && apt-get remove --purge --auto-remove -y gnupg1 && rm -rf /var/lib/apt/lists/* \
    && apt-get -o Acquire::GzipIndexes=false update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        build-essential \
                        libpcre3-dev \
                        zlib1g-dev \
                        libssl-dev \
                        libxslt1-dev \
                        libgd-dev \
                        libgeoip-dev \
                        patch \
                        gettext-base \
                        unzip \
                        curl \
                        wget \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tmp/nginx \
    && cd /tmp/nginx \
    && wget -e "${https_proxy:-use_proxy=off}" https://github.com/nginx/nginx/archive/refs/tags/release-1.21.6.tar.gz \
    && wget -e "${https_proxy:-use_proxy=off}" https://raw.githubusercontent.com/chobits/ngx_http_proxy_connect_module/master/patch/proxy_connect_rewrite_102101.patch \
    && wget -e "${https_proxy:-use_proxy=off}" https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/heads/master.zip \
    && tar -xf release-1.21.6.tar.gz \
    && unzip master.zip \
    && cd /tmp/nginx/nginx-release-1.21.6 \
    && patch -p1 < ../proxy_connect_rewrite_102101.patch \
    && ./auto/configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
      --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --user=nginx --group=nginx --with-compat --with-file-aio --with-threads \
      --with-http_addition_module \
      --with-http_auth_request_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_mp4_module \
      --with-http_random_index_module \
      --with-http_realip_module \
      --with-http_secure_link_module \
      --with-http_slice_module \
      --with-http_ssl_module \
      --with-http_stub_status_module \
      --with-http_sub_module \
      --with-http_v2_module \
      --with-mail \
      --with-mail_ssl_module \
      --with-stream \
      --with-stream_realip_module \
      --with-stream_ssl_module \
      --with-stream_ssl_preread_module \
      --add-module=/tmp/nginx/ngx_http_proxy_connect_module-master \
      --with-http_xslt_module=dynamic \
      --with-http_image_filter_module=dynamic \
      --with-http_geoip_module=dynamic \
      --with-stream_geoip_module=dynamic \
    && make && make install \
    && cd /tmp && rm -fr /tmp/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/cache/nginx \
    && mkdir /docker-entrypoint.d \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3128/tcp

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
