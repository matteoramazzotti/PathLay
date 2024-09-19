.. _installation_apache:

^^^^^^^^^^^^^^^^^^^^^^^^^^
Apache Server Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Copy pathlay folder to your apache directory of choice, default is /var/www/html/:

	.. code-block::

		cp -r pathlay /var/www/html/


#. Enable apache modules:
	
	.. code-block::

		a2enmod cgid
		a2enmod rewrite
		a2enmod headers
		a2dissite 000-default
		systemctl reload apache2


#. Add the following configuration to the /etc/apache2/apache2.conf file:
	
	.. code-block::

	  <FilesMatch "\.(ttf|otf|eot|woff|js|css|woff2)$">
	    <IfModule mod_headers.c>
	      Header set Access-Control-Allow-Origin "*"
	    </IfModule>
	  </FilesMatch>


#. Add the following configuration to the /etc/apache2/sites-enabled/localhost.conf file:

	.. code-block::

		ServerName localhost
		AddHandler cgi-script .cgi .pl

		<Directory '"$chosenPath"'>
		  Header set Access-Control-Allow-Origin "*"
		  Options All
		  AllowOverride All
		</Directory>

	If the file doesn't exist, create it. Be sure to replace "$chosenPath" with the location of the pathlay directory.


#. Setup environment variables:

	.. code-block::

		export APACHE_RUN_USER="www-data"
		export APACHE_RUN_GROUP="www-data"
		export APACHE_PID_FILE="/var/run/apache2.pid"
		export APACHE_RUN_DIR="/var/run/apache2"
		export APACHE_LOCK_DIR="/var/lock/apache2"
		export APACHE_LOG_DIR="/var/log/apache2"

#. Setup permissions and ownership:

	.. code-block::

		chgrp -R www-data "$chosenPath"
		chmod -R 774 "$chosenPath"
		chmod g+s "$chosenPath"

	Be sure to replace "$chosenPath" with the location of the pathlay directory.
