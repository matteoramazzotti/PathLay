.. _installation_docker:


Installation using Docker (Recommended)
=======================================
	
#. Obtain the Docker image by pulling it from `Docker Hub <https://hub.docker.com/repository/docker/vonb/pathlay/general>`_ :
	
	.. code-block::

		docker pull vonb/pathlay:latest



#. Download the `docker-compose.yml <https://github.com/matteoramazzotti/PathLay/blob/main/docker-compose.yml>`_ 



#. Navigate to the directory with the downloaded docker-compose.yml files:
	
	.. code-block::

		cd directory

#. Create the "pathlay_users" directory:

	.. code-block::

		mkdir pathlay_users

#. Create the "pathlay_data" directory:

	.. code-block::

		mkdir pathlay_data


#. Build the image from docker-compose.yml:
	
	.. code-block::
	
		docker compose build 

To run the container from this image check :ref:`How to run<howto>`.