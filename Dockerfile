FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies

RUN apt-get update && apt-get install -y \
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
        libapreq2-dev \
        libgd-dev \
        libgtk2.0-0 \
        libcanberra-gtk-module \
        packagekit-gtk3-module \
        zip \
        tcl \
        librsvg2-bin \
    && cpanm --notest CGI \
    && cpanm --notest CGI::Session \
    && cpanm --notest JSON \
    && cpanm --notest File::MimeInfo::Simple \
    && cpanm --notest List::Uniq \
    && cpanm --notest XML::Simple \
    && cpanm --notest ExtUtils::PkgConfig \
    && cpanm --notest Statistics::Distributions \
    && cpanm --notest Bio::FdrFet \
    && cpanm --notest GD \
    && cpanm --notest Archive::Zip \
    && a2enmod cgid rewrite headers \
    && a2dissite 000-default \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


	
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C

ADD pathlay /var/www/html/pathlay

RUN chgrp -R www-data /var/www/html/pathlay/
RUN chmod -R 774 /var/www/html/pathlay/
RUN chmod g+s /var/www/html/pathlay/

CMD ["/usr/sbin/apache2", "-D","FOREGROUND"]
EXPOSE 80 143
