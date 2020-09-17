FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y full-upgrade
RUN apt-get -y install apache2 apache2-utils php7.4 libapache2-mod-php7.4 php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-fpm libapache2-mod-security2 git htop clamav clamav-daemon 
RUN a2enmod proxy_fcgi setenvif
RUN systemctl enable apache2
RUN freshclam
RUN mv /etc/modsecurity/modsecurity.conf-recommended  /etc/modsecurity/modsecurity.conf
RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git 
#RUN mv ./owasp-modsecurity-crs/crs-setup.conf.example /etc/modsecurity/crs-setup.conf
RUN mv ./owasp-modsecurity-crs/rules/ /etc/modsecurity/

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
#RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php7/apache2/php.ini
#RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php7/apache2/php.ini

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
#ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# add apache2 service to supervisor
#ADD supervisor/conf.d/apache2.conf /etc/supervisor/conf.d/

# By default, simply start apache.
#CMD /usr/sbin/apache2ctl -D FOREGROUND