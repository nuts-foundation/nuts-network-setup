.. _run-discovery:

Running the network discovery service
#####################################

**Network administrator action**

In order to be able to support the network by signing new requests and generating the *networkParameters*, the **discovery** service is needed. https://github.com/nuts-foundation/nuts-discovery

The easiest way to run the service is to use a docker image and mount the keys and configuration files. The docker image is hosted on https://hub.docker.com/repository/docker/nutsfoundation/nuts-discovery

Configuration
*************

Below is an example application.properties file that can be used with docker. The ``db``, ``keys`` and ``conf`` dirs need to be mounted. (assuming application.properties is placed in the conf dir)

.. code-block:: properties

    server.port=8080
    spring.jackson.serialization.FAIL_ON_EMPTY_BEANS=false

    # JPA
    spring.datasource.url=jdbc:h2:file:/opt/nuts/discovery/db/discovery_db
    spring.datasource.driverClassName=org.h2.Driver
    spring.datasource.username=sa
    spring.datasource.password=password
    spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

    # migrations
    spring.flyway.locations=classpath:db/migration/{vendor},classpath:db/migration/common

    # app specific
    nuts.discovery.CordaRootCertPath = /opt/nuts/discovery/keys/root.crt
    nuts.discovery.intermediateKeyPath = /opt/nuts/discovery/keys/doorman.key
    nuts.discovery.intermediateCertPath = /opt/nuts/discovery/keys/doorman.crt
    nuts.discovery.networkMapCertPath = /opt/nuts/discovery/keys/network_map.crt
    nuts.discovery.networkMapKeyPath = /opt/nuts/discovery/keys/network_map.key

    nuts.discovery.autoAck = false

The docker command would then be:

.. code-block:: shell

    docker run -it \
        -v {{KEYS_DIR}}:/opt/nuts/discovery/keys \
        -v {{DB_DIR}}:/opt/nuts/discovery/db \
        -v {{CONF_DIR}}:/opt/nuts/discovery/conf \
        -p 8080:8080 \
        nutsfoundation/nuts-discovery:latest java -jar /opt/nuts/discovery/bin/nuts-discovery.jar --spring.config.location=file:/opt/nuts/discovery/conf/application.properties

.. warning::

    wherever ``/opt/nuts/discovery/keys`` and ``/opt/nuts/discovery/db`` point to. Make a backup and don't lose the contents. Getting everything restored is a royal pain in the ass.