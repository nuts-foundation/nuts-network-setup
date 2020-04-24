.. _loading-keys:

Loading keys
############

You can unzip the file given by the network operator. This should result in the following structure:

- DIST_DIR
    - certs/
    - conf/sslkeystore.conf
    - network-parameters

To load the certificates and generate a key for the TLS connection, you'll need to startup a docker container.
This requires the same directory structure as earlier (when generating the CSR):

- NODE_BASE_DIR
    - node.conf
    - certificates/truststore.jks

It's important to point to the exact same directory since the generated private key exist in ``NODE_BASE_DIR/certificates/nodekeystore.jks``

Then run the following command:

.. code-block:: shell

    docker run -it \
        -v {{NODE_BASE_DIR}}:/opt/nuts/node \
        -v {{DIST_DIR}}:/opt/nuts/dist \
        nutsfoundation/load-certificate:latest

Where ``NODE_BASE_DIR`` points to the directory where the node.conf file exists (and the certificates directory).
The ``DIST_DIR`` points to the root of the files extracted from the zip (see above).
