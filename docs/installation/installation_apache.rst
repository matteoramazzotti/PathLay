.. _installation_apache:

--------------------------
Apache Server Installation
--------------------------

.. code-block::
	:caption: Navigate to the directory with the downloaded DockerFile

	cd directory
	sudo docker run --name pathlay_server_0.1.0-alpha -d -p 80:80 -p 143:143 -v $(pwd)/pathlay_data/:/var/www/html/pathlay/pathlay_data/ --mount type=bind,source=$(pwd)/pathlay_users/,target=/var/www/html/pathlay/pathlay_users/ --network host  pathlay_server_0.1.0-alpha