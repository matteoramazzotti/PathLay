.. _howto_docker_local:

---------------------------------------
Run PathLay as local server (localhost)
---------------------------------------

.. code-block::

	docker run --name pathlay_local -d -p 80:80 pathlay


You can check that the container is running with the following:

.. code-block::

	docker ps -a


To access PathLay simply connect to http://localhost/pathlay_2/pathlay_home.html 
