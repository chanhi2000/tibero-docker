#Dockerfile
#Requirements on host(Linux): sysctl -w net.ipv4.ip_forward=1
#Check "Testing Tibero on your own" Blog post for sysctl config and limits.

# docker build  . --tag=chan/tibero6:latest
# docker run -d -it chan/tibero6:latest -h dummy

FROM oraclelinux:7-slim

LABEL maintainer="chanhi2000@gmail.com"

ENV TB_SID=tibero
ENV TB_HOME=/home/tibero/tibero6
ENV TB_CONFIG=$TB_HOME/config
ENV PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin
ENV LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib
ENV TB_MAX_SESSION_COUNT=20
ENV TB_MEMORY_TARGET=4G
ENV TB_TOTAL_SHM_SIZE=2G
ENV TB_HOSTNAME=dummy

## tbimport related
ENV TB_IMPORT_ENABLE=false
ENV TB_IMPORT_SID=tibero
ENV TB_IMPORT_PORT=8629
ENV TB_IMPORT_USERNAME=sys
ENV TB_IMPORT_PASSWORD=tibero
ENV TB_IMPORT_SCRIPT=y
ENV TB_IMPORT_IGNORE=y
ENV TB_IMPORT_ROWS=y
ENV TB_IMPORT_CONSTRAINT=y
ENV TB_IMPORT_INDEX=y
ENV TB_IMPORT_TRIGGER=y
ENV TB_IMPORT_SYNONYM=n
ENV TB_IMPORT_SEQUENCE=y
ENV TB_IMPORT_USER=sys



RUN export TB_MAX_SESSION_COUNT=$TB_MAX_SESSION_COUNT \
	&& export TB_MEMORY_TARGET=$TB_MEMORY_TARGET \
	&& export TB_TOTAL_SHM_SIZE=$TB_TOTAL_SHM_SIZE

# Install OS Packages
RUN yum -q -y --nogpgcheck install java-1.8.0-openjdk-devel.x86_64 \
	libibverbs \
	net-tools \
	ntp \
	gcc \
	gcc-c++ \
	libstdc++-devel \
	compat-libstdc++ \
	libaio \
	libaio.x86_64 \
	libaio-devel \
	net-tools \
	kernel-headers \
	kernel-devel \
	perl \
	make \
	systemd \
	tree \
	wget \
	curl \
	supervisor \
	openssh-server \
	&& yum -q clean packages 
# Create Users and Groups (maybe in entrypoint.sh)
RUN echo "--- Creating Users and Groups ---" \
	&& groupadd -g 500 dba \
	&& useradd -g dba tibero 

# Download tibero database software to install 
RUN echo "--- Downloading Tibero Database Software via WGET ---" \
	&& wget -q --load-cookies /tmp/cookies.txt \
	"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
	'https://docs.google.com/uc?export=download&id=1PdRlSnuH2-e3THVQ2G7_NtiWHrN3B46w' -O- | \
	sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1PdRlSnuH2-e3THVQ2G7_NtiWHrN3B46w" \
	-O /tmp/tibero6-bin-FS07_CS_1912-linux64-174424-opt.tar.gz \
	&& rm -rf /tmp/cookies.txt

RUN echo "--- Untar Tibero Software ---" \
	&& tar -xf /tmp/tibero6-bin-FS07_CS_1912-linux64-174424-opt.tar.gz -C /home/tibero \
	&& rm /tmp/tibero6-bin-FS07_CS_1912-linux64-174424-opt.tar.gz 

# Download tibero license file for trial
RUN echo "--- Downloading necessary files to run ---" \
 	&& wget --load-cookies /tmp/cookies.txt \
  	"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1mRUj19dZmrqx6lW91QBZn1H7Jn4gglp4' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1mRUj19dZmrqx6lW91QBZn1H7Jn4gglp4" \
 	-O /home/tibero/tibero6/license/license.xml	\
 	&& chown tibero:dba /home/tibero/tibero6/license/license.xml \
 	&& rm -rf /tmp/cookies.txt

# Setting workspace in /opt/tibero/
RUN echo "--- Setting workspace in /opt/tibero/ ---"
COPY bash_profile_tibero /home/tibero/.bash_profile 


RUN chown tibero:dba /home/tibero/tibero6/license/license.xml  \
 	&& mkdir /opt/tibero/ \
 	&& mkdir /opt/tibero/init \
 	&& mkdir /opt/tibero/dump \
 	&& mkdir /opt/tibero/license 

RUN cp /home/tibero/tibero6/license/license.xml /opt/tibero/license/license.xml
COPY docker-entrypoint.sh /entrypoint.sh
# COPY healthcheck.sh /healthcheck.sh

VOLUME /home/tibero/tibero6/database
VOLUME /opt/tibero

ENTRYPOINT ["/entrypoint.sh"]
# HEALTHCHECK CMD /healthcheck.sh



EXPOSE 8629-8649
CMD ["/bin/sh"]
# CMD ["tbsql"]

