# Tibero image for OpenShift.
#
# Volumes:
#  * /opt/tmaxsoft/database - Datastore for Tibero
# Environment:
#  * $TB_SID (Optional) - Database name
#  * $TB_MEMORY_TARGET (Optional) - Database memory target
#  * $TB_SYS_PASSWORD (Optional) - SYS user password
#  * $TB_CHARSET (Optional) - Database character set
#FROM centos/s2i-core-centos7
#FROM centos:centos7
FROM tmaxdata/t6:single
MAINTAINER Conrad Yang <conrad.yang@tmaxsoft.com>

ENV SUMMARY="Tibero 6 database server" \
    DESCRIPTION="Tibero is a multi-user, multi-threaded relational database management system. \
The container image provides a containerized packaging of the Tibero database server."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Tibero 6" \
      io.openshift.expose-services="8629:tibero" \
      io.openshift.tags="database,tibero,tibero6,rdbms" \
      io.openshift.non-scalable=true \
      io.openshift.min-memory=4Gi \
      io.openshift.min-cpu=2 \
      com.redhat.component="tibero6-container" \
      name="tmaxsoft/tibero6" \
      version="6.0" \
      usage="docker run -d -e TB_SID=tibero -e MEMORY_TARGET=4G -p 8629:8629 tmaxsoft/tibero6" \
      maintainer="Conrad Yang <conrad.yang@tmaxsoft.com>"

# Environments
ENV HOSTNAME=node
ENV TB_BASE=/
ENV TB_HOME=$TB_BASE/tibero \
    TB_USER=tibero \
    LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib \
    JAVA_HOME=/usr/java/latest \
    PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin:$JAVA_HOME/bin

# Install System Packages and Create User
#RUN yum install -y gcc.x86_64 gcc-c++.x86_64 compat-libstdc++-33.x86_64 libaio-devel.x86_64
#RUN yum clean all -y

# User group and limits settings
RUN groupadd dba && \
	useradd -g dba $TB_USER && \
	echo $TB_USER soft nproc 2047 >> /etc/security/limits.conf && \
	echo $TB_USER hard nproc 16384 >> /etc/security/limits.conf && \
	echo $TB_USER soft nofile 1024 >> /etc/security/limits.conf && \
	echo $TB_USER hard nofile 65536 >> /etc/security/limits.conf
RUN mkdir -p /home/$TB_USER
RUN chown -R tibero:dba /home/$TB_USER

# Show current hostname
RUN hostname 

# Listner Port
EXPOSE 8629

# Database binary installation
#RUN mkdir -p $TB_HOME
#ADD Tibero.tar.gz $TB_BASE
RUN chown -R tibero:dba $TB_HOME

# License file
#COPY license.xml $TB_HOME/license

# User profile settings
USER root
COPY bash_profile.add /home/tibero
RUN chown -R tibero:dba /home/tibero && \
	chmod -R 775 /home/tibero && \
	cat /home/tibero/bash_profile.add >> /home/tibero/.bash_profile
RUN rm -f $TB_HOME/client/config/tbdsn.tbr

# JDK
#COPY jdk.rpm /tmp
#RUN rpm -ivh /tmp/jdk.rpm

# Database creation and startup scripts
COPY create_database.sql $TB_HOME/scripts
COPY createDB.sh /home/tibero
COPY startDB.sh /home/tibero
RUN chown -R tibero:dba $TB_HOME
RUN chown tibero:dba /home/tibero/createDB.sh /home/tibero/startDB.sh
RUN chmod +x /home/tibero/createDB.sh /home/tibero/startDB.sh

# XXX - Workaround - fix privilege
RUN chown -R root:root $TB_HOME
RUN chmod -R g+w $TB_HOME

# Start or Create Database
USER $TB_USER
CMD /home/tibero/startDB.sh
