# docker_tibero
Scripts to build [Tibero](http://tmaxsoft.com/products/tibero/) docker image

## Usage
### 1. Check that docker is installed 
    $ docker --version
    Docker version 17.05.0-ce, build 89658be
if not, install docker following the [instructions](https://docs.docker.com/engine/installation)
### 2. Register on the [TmaxSoft TechNet site](https://technet.tmaxsoft.com/en/front/main/main.do)
### 3. Download [Tibero for Linux (x86) 64-bit](https://technet.tmaxsoft.com/en/front/download/viewDownload.do?cmProductCode=0301&version_seq=PVER-20170217-000001&doc_type_cd=DN) and rename file to Tibero.tar.gz
### 4. Request Demo License on the [TmaxSoft TechNet site](https://technet.tmaxsoft.com/en/front/main/main.do)
### 5. Download [Java JDK jdk-...-linux-x64.rpm](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) and rename file to jdk.rpm
### 6. Put Tibero.tar.gz, license.xml, jdk.rpm and this script files together in one directory and switch to the directory
### 7. Run "docker-compose build" to build the image
### 8. Run "docker-compose up" to start the container for database creation (on first run)
### 9. Run "docker commit tibero6" to commit changes to the images.
