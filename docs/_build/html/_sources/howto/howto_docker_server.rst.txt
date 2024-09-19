.. _howto_docker_server:

-----------------------------
Run PathLay as network server
-----------------------------

.. code-block::

	sudo docker run --name pathlay_server_0.1.0-alpha -d -p 80:80 -p 143:143 -v $(pwd)/pathlay_data/:/var/www/html/pathlay/pathlay_data/ --mount type=bind,source=$(pwd)/pathlay_users/,target=/var/www/html/pathlay/pathlay_users/ --network host  pathlay_server_0.1.0-alpha


You can check that the container is running on your host machine with the following:

.. code-block::
 
	docker ps -a

Check the IP address of your host machine:

.. code-block::

	hostname -I


To access PathLay from your host machine simply connect to http://localhost/pathlay_2/pathlay_home.html

To access PathLay from a client machine in the same network simply connect to http://host_ip_address/pathlay_2/pathlay_home.html


