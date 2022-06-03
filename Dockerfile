FROM ubuntu:22.04

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8 
ENV LC_ALL=en_US.UTF-8 

# install packages
RUN apt update && apt upgrade -y
RUN DEBIAN_FRONTEND="noninteractive" apt install -y \
      sudo \
      gawk \
      cmake \
      g++ \
      git \
      vim \
      tar \
      ssh \
      locales \
      libpcre2-dev \
      libssl-dev \
      zlib1g-dev

# update locale
RUN sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=$LANG LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL

# generate RSA1 RSA DSA ECDSA keys
RUN ssh-keygen -A

# permit root ssh login
RUN sed -i "s+#PermitRootLogin prohibit-password+PermitRootLogin prohibit-password+g" /etc/ssh/sshd_config

# set root password to 123456
RUN echo 'root:123456' | chpasswd

# clone libs repositories
WORKDIR /root
RUN git clone --branch devel https://github.com/CESNET/libyang.git
RUN git clone --branch devel https://github.com/sysrepo/sysrepo.git
RUN git clone http://git.libssh.org/projects/libssh.git
RUN git clone --branch devel https://github.com/CESNET/libnetconf2.git
RUN git clone --branch devel https://github.com/CESNET/netopeer2.git

# build libyang
WORKDIR /root/libyang/build
RUN cmake .. ; make ; make install

# build sysrepo
WORKDIR /root/sysrepo/build
RUN cmake .. ; make ; make install

# build libssh (required bu libnetconf2)
WORKDIR /root/libssh/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr .. ; make ; make install

# build libnetconf2
WORKDIR /root/libnetconf2/build
RUN cmake .. ; make ; make install

# build netopeer2
WORKDIR /root/netopeer2/build
RUN cmake .. ; make ; ldconfig ; make install

# configure OVEN example
WORKDIR /usr/local/lib/sysrepo-plugind/plugins
RUN cp /root/sysrepo/build/examples/oven.so .

# copy OVEN XMLs to /root/oven-example
WORKDIR /root/oven-example
COPY oven-example/oven-config.xml .
COPY oven-example/insert-food.xml .

# install OVEN YANG model to sysrepo
RUN sysrepoctl --install /root/sysrepo/examples/plugin/oven.yang

ENTRYPOINT service ssh start > /dev/null 2>&1; \
           echo "NETCONF Stack Compiled"; \
           echo "--------------------------------------------------------------------"; \
           echo " Step 1: run SYSREPO daemon: sysrepo-plugind --verbosity 2 --debug"; \
           echo " Step 2: run NETCONF server: netopeer2-server"; \
           echo " Step 3: use NETCONF CLI client: netopeer2-cli"; \
           echo "--------------------------------------------------------------------\n"; \
           /bin/bash