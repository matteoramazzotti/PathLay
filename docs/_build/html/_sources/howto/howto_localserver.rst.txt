.. _howto_docker_local:


Run PathLay as local server with Docker (localhost)
***************************************************

.. code-block::

	docker run --name pathlay_local_0.1.0-alpha4 -d -p 80:80 -v $(pwd)/pathlay_data/:/var/www/html/pathlay/pathlay_data/ --mount type=bind,source=$(pwd)/pathlay_users/,target=/var/www/html/pathlay/pathlay_users/ vonb/pathlay


You can check that the container is running with the following:

.. code-block::

	docker ps -a


To access PathLay simply connect to http://localhost/pathlay/login.html 
