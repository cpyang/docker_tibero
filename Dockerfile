FROM centos:centos7
MAINTAINER Conrad Yang <conrad.yang@tmaxsoft.com>

# Environments
ENV 	HOSTNAME=node
ENV	TB_BASE=/opt/tmaxsoft
ENV	TB_HOME=$TB_BASE/tibero6 \
	TB_SID=tibero \
	TB_USER=tibero \
	LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib \
	JAVA_HOME=/usr/java/latest \
	PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin:$JAVA_HOME/bin

# Install System Packages and Create User
RUN yum install -y gcc.x86_64 gcc-c++.x86_64 compat-libstdc++-33.x86_64 libaio-devel.x86_64
RUN groupadd dba && \
	useradd -g dba $TB_USER && \
	echo $TB_USER soft nproc 2047 >> /etc/security/limits.conf && \
	echo $TB_USER hard nproc 16384 >> /etc/security/limits.conf && \
	echo $TB_USER soft nofile 1024 >> /etc/security/limits.conf && \
	echo $TB_USER hard nofile 65536 >> /etc/security/limits.conf

RUN hostname 
# Listner Port
EXPOSE 8629

# Database Installation
RUN mkdir -p $TB_HOME
ADD Tibero.tar.gz $TB_BASE
COPY license.xml $TB_HOME/license
COPY create_database.sql $TB_HOME/scripts
COPY createDB.sh /home/tibero
RUN chown -R tibero:dba $TB_BASE
RUN chmod +x /home/tibero/createDB.sh

#USER $TB_USER
#RUN /home/tibero/createDB.sh

USER root
COPY bash_profile.add /home/tibero
RUN chown -R tibero:dba /home/tibero && \
	chmod -R 775 /home/tibero && \
	cat /home/tibero/bash_profile.add >> /home/tibero/.bash_profile
COPY jdk.rpm /tmp
RUN rpm -ivh /tmp/jdk.rpm
COPY startDB.sh /home/tibero
RUN chmod +x /home/tibero/startDB.sh

USER $TB_USER
CMD /home/tibero/startDB.sh
