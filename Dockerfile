FROM php:8.0-apache
LABEL maintainer="Maxime Flasquin contact@mflasquin.fr"

# =========================================
# RUN update
# =========================================
RUN apt-get update

# =========================================
# Install dependencies
# =========================================
RUN apt-get install -y libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxslt1-dev \
    libjpeg-dev \
    libzip-dev \
    sudo \
    libmagickwand-dev \
    libmagickcore-dev \
    apt-transport-https \
    libonig-dev

# =========================================
# Install tools
# =========================================
RUN apt-get install -y \
    vim \
    htop \
    openssl

# =========================================
# Configure the GD library
# =========================================
RUN docker-php-ext-configure \
    gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/

# =========================================
# Install php required extensions
# =========================================
RUN docker-php-ext-install \
  dom \
  gd \
  intl \
  mbstring \
  pdo_mysql \
  xsl \
  zip \
  soap \
  bcmath \
  mysqli \
  sockets \
  exif

# =========================================
# Install imagick
# =========================================
RUN pecl install -f imagick

# =========================================
# Create mflasquin user
# =========================================
RUN openssl rand -base64 32 > ./.pass \
	&& useradd -ms /bin/bash --password='$(cat ./.pass)' mflasquin \
	&& echo "$(cat ./.pass)\n$(cat ./.pass)\n" | passwd mflasquin \
	&& mv ./.pass /home/mflasquin/ \
	&& chown -Rf mflasquin:mflasquin /home/mflasquin
ADD ./bashrc.mflasquin /home/mflasquin/.bashrc

# =========================================
# Create generic SSL certificate
# =========================================
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl
RUN a2ensite default-ssl
RUN cd /etc/ssl/certs && openssl req -subj '/CN=mflasquin.local/O=MFlasquin/C=FR' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem

# =========================================
# Set ENV variables
# =========================================
ENV APACHE_RUN_USER mflasquin
ENV APACHE_RUN_GROUP mflasquin
ENV PROJECT_ROOT /var/www/html

# =========================================
# PHP Configuration
# =========================================
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# =========================================
# Expose ports
# =========================================
EXPOSE 80
EXPOSE 443

# =========================================
# Set entrypoint
# =========================================
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR $PROJECT_ROOT

CMD ["apache2-foreground"]