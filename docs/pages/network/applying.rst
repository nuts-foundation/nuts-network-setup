.. _join-a-network:

Join a network
##############

**Vendor action**

To join a network, a CSR will have to be sent. A Corda node can generate this for you. To do this, you'll need the following directory structure:

- NODE_BASE_DIR
    - node.conf
    - certificates/truststore.jks

A basic node.conf looks like this:

.. code-block:: yaml

    myLegalName="O=Nuts,C=NL,L=IJbergen,CN=node"
    emailAddress="info@nuts.nl"
    devMode=false
    networkServices {
        doormanURL = "http://discovery:8080/doorman"
        networkMapURL = "http://discovery:8080"
    }
    p2pAddress="your_p2p_address:7886"
    trustStorePassword="changeit"
    keyStorePassword="cordacadevpass"


It's important to change ``myLegalName``. Enter the correct password for the trustStore under ``trustStorePassword``, this should have been published next to the ``truststore.jks`` file. ``keyStorePassword`` should not be changed. The ``networkServices`` will not resolve but this is not an issue for now. All extra settings are not important for now.

The ``truststore.jks`` file has to be downloaded and placed in the certificates directory.

When you're happy with your config run:

.. code-block:: shell

    docker run -it \
        -v {{NODE_BASE_DIR}}/node.conf:/opt/nuts/node.conf \
        -v {{NODE_BASE_DIR}}/certificates:/opt/nuts/certificates \
        nutsfoundation/generate-csr:latest

where ``NODE_BASE_DIR`` points to the directory where the former files live.

.. note::

    After the creation of the CSR and before you run the node. The ``networkService`` part of the config has to be removed (while running without the discovery service). Also ``devMode`` should be set to true.

Submit CSR
**********

When the docker container finishes running a ``csr.pem`` file will have been placed in the ``NODE_BASE_DIR`` directory. Send this file to the Nuts foundation.

When you receive a zip package, you can continue with :ref:`loading-keys`.

