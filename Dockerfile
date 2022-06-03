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

WORKDIR /root

# install libyang
RUN git clone --branch devel https://github.com/CESNET/libyang.git
RUN mkdir -p /root/libyang/build
RUN cd /root/libyang/build  ; cmake ..
RUN cd /root/libyang/build/ ; make
RUN cd /root/libyang/build/ ; make install

# install sysrepo
RUN git clone --branch devel https://github.com/sysrepo/sysrepo.git
RUN mkdir -p /root/sysrepo/build
RUN cd /root/sysrepo/build/ ; cmake ..
RUN cd /root/sysrepo/build/ ; make
RUN cd /root/sysrepo/build/ ; make install

# install libssh (required bu libnetconf2)
RUN git clone http://git.libssh.org/projects/libssh.git
RUN mkdir -p /root/libssh/build
RUN cd /root/libssh/build ; cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN cd /root/libssh/build ; make
RUN cd /root/libssh/build ; make install

# install libnetconf2
RUN git clone --branch devel https://github.com/CESNET/libnetconf2.git
RUN mkdir -p /root/libnetconf2/build
RUN cd /root/libnetconf2/build ; cmake ..
RUN cd /root/libnetconf2/build ; make
RUN cd /root/libnetconf2/build ; make install

# install netopeer2
RUN git clone --branch devel https://github.com/CESNET/netopeer2.git
RUN mkdir -p /root/netopeer2/build
RUN cd /root/netopeer2/build ; cmake ..
RUN cd /root/netopeer2/build ; make
RUN cd /root/netopeer2/build ; ldconfig
RUN cd /root/netopeer2/build ; make install

# configure OVEN example
RUN mkdir -p /usr/local/lib/sysrepo-plugind/plugins
RUN cp /root/sysrepo/build/examples/oven.so /usr/local/lib/sysrepo-plugind/plugins/

# copy OVEN XMLs to /root/oven-example
RUN mkdir -p /root/oven-example
COPY oven-example/oven-config.xml /root/oven-example/
COPY oven-example/insert-food.xml /root/oven-example/

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