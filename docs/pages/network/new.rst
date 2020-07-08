.. _generate-root-keys:

Creating a new network
######################

**Network administrator action**

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

Where ``LOCAL_PATH`` is the path where you want your keys to be stored, ``NETWORK_NAME`` is the desired name of your network, ``COUNTRY`` is the two-letter country code and ``LOCALITY`` is the city of registration. During the process, you'll be asked for a password. This password will be the password for the ``truststore.jks`` and will have to be provided to the network participants next to the ``truststore.jks`` file. Reply with ``yes`` when asked if you want to trust the specific certificate.

Storing the output
******************

The container will generate a bunch of files. The ``root.key`` has to be kept securely offline. The ``truststore.jks`` file should be published on a website somewhere along with the password for it. The remainder of the files will have to be loaded into the ``nuts-discovery`` app https://github.com/nuts-foundation/nuts-discovery

Vault docker image
==================

An option to securely store the keys and distribute them is to let Hashicorp's Vault do the heavy lifting.
The main idea is to mount the config/log/file dirs and then use the Vault command line tool to interact with Vault.
When the container is offline, files from the `file` directory can be securely exchanged and the unseal keys can use a different medium for transfer.

To run the container:

.. code-block:: shell

    docker run -it --cap-add=IPC_LOCK -v `pwd`/file:/vault/file -v `pwd`/log:/vault/log -v `pwd`/config:/vault/config --name vault-nuts vault server


where `pwd` is the root of the structure used to exchange the vault store.

To interact with the container:

.. code-block:: shell

    docker exec -it -e VAULT_ADDR=http://127.0.0.1:8200 vault-nuts /bin/sh


Initial setup
^^^^^^^^^^^^^

The initial setup for a new vault store:

.. code-block:: shell

    vault operator init


This will generate an output like:

.. code-block:: shell

    Unseal Key 1: 77EPX49RBoo2a8aN4+34XikzeqIhjvRVtHEQCCe6d7/l
    Unseal Key 2: x4gJ52TgVHor6uA8ARuVZRyX228/8hAVLtzaVZnmpK9A
    Unseal Key 3: z7lpYcr6So/tXCP2VEXPM88dIrxfPao0WUnYSmg9Hcl7
    Unseal Key 4: whfbcUXM5ozcdB+21VwkhnSWvhui9eXF2ipefaYlrPRj
    Unseal Key 5: O4EYtJOmgyiLY7g7gyp3Jq/QQ/DN99rUdnS8kkuLtlfv

    Initial Root Token: s.4GhOLbGX0D3PsVxVV0p40Lea


The unseal keys have to be distributed amongst network operators.

Then we have to enable a key-value store, first unseal the store (3 times) using the unseal keys from above:

.. code-block:: shell

    vault operator unseal


then:

.. code-block:: shell

    export VAULT_TOKEN=s.4GhOLbGX0D3PsVxVV0p40Lea
    vault secrets enable -path=nuts kv-v2


Storing/retrieving keys
^^^^^^^^^^^^^^^^^^^^^^^

With a root token (https://learn.hashicorp.com/vault/operations/ops-generate-root):

Enable the policy for accessing `nuts/`:

.. code-block:: shell

    vault policy write secret /vault/config/secret-policy.hcl


Then create an access token:

.. code-block:: shell

    vault token create -policy=secret


Use that token to store or get secrets:

.. code-block:: shell

    export VAULT_TOKEN=s.zF801If9KeKnBYqBEP3vSTR1
    vault kv put nuts/keys/root pem=s3cr3t
    vault kv put nuts/keys/doorman pem=s3cr3t
    vault kv put nuts/keys/network pem=s3cr3t


And read:

.. code-block:: shell

    vault kv get nuts/keys/root


Closing
^^^^^^^

First destroy the root token:

.. code-block:: shell

    export VAULT_TOKEN=s.4GhOLbGX0D3PsVxVV0p40Lea
    vault token revoke s.4GhOLbGX0D3PsVxVV0p40Lea

Then close the docker container


Distribution
============

When using vault and after generating and storing the keys. The following file structure has to be distributed/backed-up:

- root
    - keys
        - doorman.crt
        - network_map.crt
        - root.crt
        - root.srl
        - truststore.jks
    - vault
        - config
            - default.hcl
            - secret-policy.hcl
        - file/\*\*/\*
