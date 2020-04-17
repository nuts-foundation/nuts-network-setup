.. _generate-root-keys:

Create a new network
####################

Creating a new network begins with generating the root keys. These are needed to enable the Corda part of the network.

Requirements
************

The only thing needed is docker. A docker image is provided that will generate all the needed keys. Once the keys are generated, the root key will have to be kept safe and offline. You can print it or put in on a portable storage device and put this in a safe at a bank, poor it in concrete or shoot it to outer space depending on your requirements.

Docker image creation
*********************

Before generating the keys, it's wise to validate the docker image first. The best way to do this is to generate the image yourself using the dockerfile. The Github repo at https://github.com/nuts-foundation/nuts-network-setup contains all needed info. If you do not tag your image with `nutsfoundation/generate-root-key`, replace that name with your name when needed.

.. note::

    If you want to do everything offline, you'll have to pull the repo and create the image first and then go offline.

Generating keys
***************

Once an image is on the desired machine and you've gone offline. Run the following docker command:

.. code-block:: shell

    docker run -it \
        -v LOCAL_PATH:/opt/nuts/keys
        nutsfoundation/generate-root-key:latest NETWORK_NAME COUNTRY LOCALITY

Where ``LOCAL_PATH`` is the path where you want your keys to be stored, ``NETWORK_NAME`` is the desired name of your network, COUNTRY is the two-letter country code and LOCALITY is the city of registration. During the process, you'll be asked for a password. This password will be the password for the ``truststore.jks`` and will have to be provided to the network participants next to the ``truststore.jks`` file. Reply with ``yes`` when asked if you want to trust the specific certificate.

Storing the output
******************

The container will generate a bunch of files. The ``root.key`` has to be kept securely offline. The ``truststore.jks`` file should be published on a website somewhere along with the password for it. The remainder of the files will have to be loaded into the ``nuts-discovery`` app (https://github.com/nuts-foundation/nuts-discovery.