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

# Edit Apache configuration

RUN mkdir -p /var/lock/apache2 /var/run/apache2 \
    && echo '<FilesMatch "\.(ttf|otf|eot|woff|js|css|woff2)$">' > /var/www/html/.htaccess \
    && echo ' <IfModule mod_headers.c>' >> /var/www/html/.htaccess \
    && echo '  Header set Access-Control-Allow-Origin "*"' >> /var/www/html/.htaccess \
    && echo ' </IfModule>' >> /var/www/html/.htaccess \
    && echo '</FilesMatch>' >> /var/www/html/.htaccess \
    && echo '<Directory /var/www/html/>' >> /etc/apache2/apache2.conf \
    && echo '<FilesMatch "\.(ttf|otf|eot|woff|js|css|woff2)$">' >> /etc/apache2/apache2.conf \
    && echo ' <IfModule mod_headers.c>' >> /etc/apache2/apache2.conf \
    && echo '  Header set Access-Control-Allow-Origin "*"' >> /etc/apache2/apache2.conf \
    && echo ' </IfModule>' >> /etc/apache2/apache2.conf \
    && echo '</FilesMatch>' >> /etc/apache2/apache2.conf \
    && echo '</Directory>' >> /etc/apache2/apache2.conf \
    && echo 'ServerName localhost' > /etc/apache2/sites-enabled/localhost.conf \
    && echo 'AddHandler cgi-script .cgi .pl' >> /etc/apache2/sites-enabled/localhost.conf \
    && echo '<Directory /var/www/html>' >> /etc/apache2/sites-enabled/localhost.conf \
    && echo '  Header set Access-Control-Allow-Origin "*"' >> /etc/apache2/sites-enabled/localhost.conf \
    && echo '  Options All' >> /etc/apache2/sites-enabled/localhost.conf \
    && echo '  AllowOverride All' >> /etc/apache2/sites-enabled/localhost.conf \
    && echo '</Directory>' >> /etc/apache2/sites-enabled/localhost.conf

# Set environment variables for Apache
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
