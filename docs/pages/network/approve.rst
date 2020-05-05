.. _add-a-vendor:

Approve vendor
##############

**Network administrator action**

As a network administrator, it's your job to approve requests from a vendor. Requests will be sent in the form of PEM-encoded *certificate signing requests*.

Check source
************

The first thing to do is to check the medium that has been used to send you the CSR. Can you trust it? Does it have end-2-end encryption? Next: can you trust the person that has sent you the CSR?

Check contents
**************

If all is correct, the applicant used the provided Docker images to generate the request. To be sure, you can use **openssl** to inspect the contents.

Approve the request
*******************

First make sure the discovery service is running with the correct keys! Check :ref:`run-discovery`.

The request can be approved by running the following:



    scripts/approve.sh PATH_TO_PEM [DISCOVERY_BASE_URL]

The ``PATH_TO_PEM`` is the path to the vendor CSR. The ``DISCOVERY_BASE_URL`` is optional and should point to the base URL of the running discovery service. Default: *http://localhost:8080*.

The result of the script is a zip file with:

- the certificate chain
- the latest network-parameters

This file can be given to the vendor which should be able to start their node.

.. warning::

    Before vendors can join, a Notary must have been approved and added, otherwise the networParameters change and have to be redistributed.