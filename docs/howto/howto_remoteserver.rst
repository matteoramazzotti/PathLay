.. _howto_docker_server:

-----------------------------
Run PathLay as network server
-----------------------------

.. code-block::

	docker run --name pathlay_server -d -p 80:80 -p 143:143 --network network pathlay


You can check that the container is running on your host machine with the following:

.. code-block::
 
	docker ps -a

Check the IP address of your host machine:

.. code-block::

	hostname -I


To access PathLay from your host machine simply connect to http://localhost/pathlay_2/pathlay_home.html

To access PathLay from a client machine in the same network simply connect to http://host_ip_address/pathlay_2/pathlay_home.html


