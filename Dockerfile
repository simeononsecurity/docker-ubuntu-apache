#https://hub.docker.com/r/bartekmis/ubuntu-apache/dockerfile

FROM ubuntu:latest
MAINTAINER SimeonOnSecurity

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y full-upgrade && \
    apt-get -y install \
    apache2 \
    php7.0 \
    php7.0-cli \
    libapache2-mod-php7.0 \
    php7.0-gd \
    php7.0-curl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xml \
    php7.0-xsl \
    php7.0-zip


# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80 
EXPOSE 443
EXPOSE 8080
EXPOSE 8443

# Copy this repo into place.
VOLUME ["/var/www", "/etc/apache2/sites-enabled"]

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# add apache2 service to supervisor
ADD supervisor/conf.d/apache2.conf /etc/supervisor/conf.d/

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND
