# Use Ubuntu 22.04 so PHP 8.0 is used, for NC
FROM ubuntu:22.04
RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt install -yq \
  apache2 \
  build-essential \
  curl \
  git \
  libxml2 \
  libxml2-dev \
  php \
  php-curl \
  php-gd \
  php-intl \
  php-json \
  php-mbstring \
  php-mysql \
  php-opcache \
  php-sqlite3 \
  php-xml \
  php-xdebug \
  php-zip \
  phpunit \
  vim \
  wget
# Trust all the certificates:
ADD tls /tls
RUN cp /tls/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

RUN a2enmod ssl
COPY site.conf /etc/apache2/sites-enabled/000-default.conf
WORKDIR /var/www
RUN chown www-data:www-data .
EXPOSE 443
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
