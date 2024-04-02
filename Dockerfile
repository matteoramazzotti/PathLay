FROM ubuntu:latest
MAINTAINER Von B.
ARG DEBIAN_FRONTEND=noninteractive
RUN \
	apt-get update && \
	apt-get install -y \
		build-essential \
		apt-utils \
		ssl-cert \
		apache2-dev \
		apache2 \ 
		apache2-utils \
		libapache2-mod-perl2 \
        libapache2-mod-perl2-dev \
        libcgi-pm-perl \
        liblocal-lib-perl \
        cpanminus \
        libexpat1-dev \
        libssl-dev \
        #mysql-client \
        #libmysqlclient-dev \
        libapreq2-dev \
        tar \
        r-base \
        libgd-dev \
        libgtk2.0-0 \
        libcanberra-gtk-module \
        packagekit-gtk3-module \
        zip \
		tcl && \
	cpanm --notest ExtUtils::PkgConfig && \
    cpanm --notest Statistics::R && \
    cpanm --notest GD && \
    cpanm install Archive::Zip && \
	a2enmod cgid && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2dissite 000-default && \	
	apt-get clean && \
	mkdir -p /var/lock/apache2 && \
	mkdir -p /var/run/apache2 && \
	#echo '<Directory /var/www/html>' > /var/www/html/.htaccess && \
	echo '<FilesMatch "\.(ttf|otf|eot|woff|js|css|woff2)$">' > /var/www/html/.htaccess && \
	echo '<IfModule mod_headers.c>' >> /var/www/html/.htaccess && \
	echo '    Header set Access-Control-Allow-Origin "*"' >> /var/www/html/.htaccess && \
	echo '</IfModule>' >> /var/www/html/.htaccess && \
	echo '</FilesMatch>' >> /var/www/html/.htaccess && \
	echo '<Directory /var/www/html/>' >> /etc/apache2/apache2.conf && \
	echo '<FilesMatch "\.(ttf|otf|eot|woff|js|css|woff2)$">' >> /etc/apache2/apache2.conf && \
	echo '<IfModule mod_headers.c>' >> /etc/apache2/apache2.conf && \
	echo 'Header set Access-Control-Allow-Origin "*"' >> /etc/apache2/apache2.conf && \
	echo '</IfModule>' >> /etc/apache2/apache2.conf && \
	echo '</FilesMatch>' >> /etc/apache2/apache2.conf && \
	echo '</Directory>' >> /etc/apache2/apache2.conf
	#echo '</Directory>' >> /var/www/html/.htaccess
	
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C
COPY ./localhost.conf /etc/apache2/sites-enabled/
ADD pathlay /var/www/html/pathlay
#RUN chmod -R 777 /var/www/
RUN chgrp -R www-data /var/www/html/pathlay/
RUN chmod -R 750 /var/www/html/pathlay/
RUN chmod g+s /var/www/html/pathlay/
#VOLUME ["/var/www/html"]
CMD ["/usr/sbin/apache2", "-D","FOREGROUND"]
EXPOSE 80 143
#ENTRYPOINT ["apache2ctl"]


