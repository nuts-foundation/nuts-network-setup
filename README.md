This repo contain info and scripts on how to setup a Nuts network and how to add new participants.
Please consult the online documentation for specific details.

https://nuts-documentation.rtfd.io/ 

This readme will continue with the specific parts of this repo

# Docker
The `docker` directory contains all docker files for the images mentioned in the docs. By encapsulating all scripts in docker images, we can assure it works the same for everyone.

## generate-root-key
The root-key-generation image will generate a new Corda root key for a given password. A path must be mounted otherwise the files remain in the container.

### Building
```shell script
docker build -f docker/generate-root-key -t nutsfoundation/generate-root-key .
```

### Usage
```shell script
docker run -it \
  -v {{local_path}}:/opt/nuts/keys 
  nutsfoundation/generate-root-key:latest NAME, C, L
``` 

## generate-csr
The root-key-generation image will generate a CSR which has to be sent to the Nuts foundation. It requires the `truststore.jks` which can be downloaded from the Nuts website. It also requires the Corda `node.conf` file. A Corda `baseDir` must be mounted (containing the node.conf and certificates/truststore.jks).

### Building

First download corda executable:

```shell script
curl https://repo1.maven.org/maven2/net/corda/corda/4.4/corda-4.4.jar > files/corda.jar
```

```shell script
docker build -f docker/generate-csr -t nutsfoundation/generate-csr .
```

### Usage
```shell script
docker run -it \
  -v {{node-base-dir}}:/opt/nuts/node 
  nutsfoundation/generate-csr:latest
```

## load-certificate

```shell script
docker build -f docker/load-certificate -t nutsfoundation/load-certificate .
```


# scripts

The `scripts` directory contains shell scripts used in the different docker images. The sub-directories mirror the image names.

# conf

The `conf` directory contains config files used by different scripts. The sub-directories mirror the image names.
