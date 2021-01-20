# Tibero (Docker container)

![Tibero logo](https://www.dimensigon.com/wp-content/uploads/2020/04/Logo-DB-Standard300-Tibero.png)

## Docker Tibero - Ready-to-Go

**Target**: Enable the community to have a lightweight container to program PL/SQL oriented applications and to play with Tibero.

Database is already created. Name: tibero
Default port: 8629

You can configure encrypted communication if you wish, follow Admin Guide, Chapter 12. It is 5-10 min.

Encrypted tablespaces, partitioning (interval is not documented), composite partitioning.
Many very complex features are available.

## Getting the image

### Use the docker repository

> __NOTE__: image currently not available at Docker Hub

```sh
docker pull chanhi2000/tibero6
```

### Run the container

```sh
docker run -it -h dummy -p 8629:8629 chanhi2000/tibero6:latest
```

## Quick set-up

> __NOTE__: image currently not available at Docker Hub

`docker-compose` file (with description):

Use this docker-compose file to get up and running quickly

```yml
version: "3"

services:
  db:
    image: chanhi2000/tibero6:latest
    container_name: db
    hostname: dummy 
    # hostname: <HOSTNMAE_YOU_LIKE>
    stdin_open: true 
    environment:
      - TB_MAX_SESSION_COUNT=100
      - TB_MEMORY_TARGET=4G
      - TB_TOTAL_SHM_SIZE=2G
      # specify all below for triggering tbimport from '/opt/tibero/dump'
      - TB_IMPORT_ENABLE=true # default `false`
      - TB_IMPORT_SID=<target DB SID>
      - TB_IMPORT_PORT=<target DB port>
      - TB_IMPORT_USERNAME=<target DB username>
      - TB_IMPORT_PASSWORD=<target DB user's password>
      - TB_IMPORT_SCRIPT=y
      - TB_IMPORT_IGNORE=y
      - TB_IMPORT_ROWS=y
      - TB_IMPORT_CONSTRAINT=y
      - TB_IMPORT_INDEX=y
      - TB_IMPORT_TRIGGER=y
      - TB_IMPORT_SYNONYM=n
      - TB_IMPORT_SEQUENCE=y
      - TB_IMPORT_USER=<source DB user>
    volumes:
      - ./tibero/database:/home/tibero/tibero6/database
      - ./tibero/init/:/opt/tibero/init
      - ./tibero/license:/opt/tibero/license
      - ./tibero/dump:/opt/tibero/dump
    ports:
      - "8629:8629"
```

> __NOTE__:  You must define `hostname` of the container, because Tibero Database checks and validate hostname value and determines whether to launch or not.

## References

### Tibero Documentation

[Link](https://technet.tmaxsoft.com/upload/download/online/tibero/pver-20150504-000002/index.html)

- Developers: Tibero tbPSM Reference Guide (PSM is the most similar language to PL/SQL
- DBAs: Tibero Administrator's Guide

[Do you need a schema instead of a Docker container?](https://store.dimensigon.com/plsqlaas-sqlaas) Get it here.
It is free forever.


### Client and Interfaces

If you need to use GUIs to program, [here](https://store.dimensigon.com/accessing-you-trial-sqlaas) are the instructions on how to configure them.


### TmaxSoft Official Website

Do you want to create your own machine, register in [support.tmaxsoft.com](https://support.tmaxsoft.com) and claim your own trial license.

It lasts for 6 months for each hostname required. You can require the same hostname multiple times.

The license inside the container is not meant for distribution, sale or resale. All rights are reserved to Dimensigon.

### For Support

This machine is for testing only. Community Support is at [support.tmaxsoft.com](https://support.tmaxsoft.com).

Feel free to reach us at [Dimensigon](https://www.dimensigon.com) for any questions.


### DISCLAIMER

Copyright (c) 2018-, KnowTrade and its affiliates, All rights reserved.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS'
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE."                            
