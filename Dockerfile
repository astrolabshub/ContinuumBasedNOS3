# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04 AS nos1

# Set environment variables to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Enable i386 architecture
RUN dpkg --add-architecture i386

# Install necessary packages for GUI and a simple x11 application
RUN apt-get update && \
    apt-get install -y --no-install-recommends x11-apps && \
    apt-get clean

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    cmake \
    cmake-qt-gui \
    g++-multilib \
    gcc-multilib \
    gedit \
    git \
    gnome-terminal \
    google-mock \
    googletest \
    nautilus \
    python-apt \
    python3-dev \
    python3-pip \
    dwarves \
    freeglut3-dev:i386 \
    lib32z1 \
    libboost-dev:i386 \
    libboost-system-dev:i386 \
    libboost-program-options-dev:i386 \
    libboost-filesystem-dev:i386 \
    libboost-thread-dev:i386 \
    libboost-regex-dev:i386 \
    libgtest-dev \
    libicu-dev:i386 \
    libncurses5-dev \
    libreadline-dev:i386 \
    libsocketcan-dev \
    libxerces-c-dev \
    minicom \
    firefox \
    bash-completion \
    dos2unix \
    gdb \
    gitk \
    gnome-shell-extension-desktop-icons \
    gnome-shell-extensions \
    gnome-tweaks \
    htop \
    libncurses5 \
    libncurses5-dev \
    libncursesw5-dev \
    libtinfo5 \
    lrzsz \
    vim \
    dropbear-bin \
    docker \
    docker.io \
    docker-compose \
    python3-docker && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a script to start the X server
RUN echo "#!/bin/bash\nXvfb :1 -screen 0 1024x768x16 &\nx11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever &\nexport DISPLAY=:1" > /usr/bin/startx.sh \
    && chmod +x /usr/bin/startx.sh

# Set environment variable for the display
ENV DISPLAY host.docker.internal:0.0

# Install Xerces-C required for NOS Engine
FROM nos1 AS nos2
RUN cd /tmp \
    && wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/xerces-c/3.2.0+debian-2/xerces-c_3.2.0+debian.orig.tar.gz \
    && tar -xf /tmp/xerces-c_3.2.0+debian.orig.tar.gz \
    && cd /tmp/xerces-c-3.2.0 \
    && /tmp/xerces-c-3.2.0/configure --prefix=/usr CFLAGS=-m32 CXXFLAGS=-m32 \
    && make \
    && make install

# Configure environment
FROM nos2 AS nos3
ADD ./nos3_filestore /nos3_filestore/
RUN sed 's/fs.mqueue.msg_max/fs.mqueue.msg_max=500/' /etc/sysctl.conf \
    && apt-get install -y \
        /nos3_filestore/packages/ubuntu/itc-common-Release_1.10.1_i386.deb \
        /nos3_filestore/packages/ubuntu/nos-engine-Release_1.6.1_i386.deb

RUN mkdir -p /opt/nos3 \
    && cd /opt/nos3 \
    && git clone https://github.com/ericstoneking/42.git \
    && cd /opt/nos3/42 \
    && git checkout f20d8d517b352b868d2f45ee3bffdb7deeedb218

RUN cd /opt/nos3/42 \
    && sed 's/ARCHFLAG =/ARCHFLAG=-m32 /; s/LFLAGS = -L/LFLAGS = -m32 -L/; s/#GLUT_OR_GLFW = _USE_GLUT_/GLUT_OR_GLFW = _USE_GLUT_/' -i /opt/nos3/42/Makefile \
    && make \
    && ln -s /usr/lib/libnos_engine_client.so /usr/lib/libnos_engine_client_cxx11.so

# Set working directory
WORKDIR /home/nos3

# Clone the NOS3 repository
RUN git clone https://github.com/nasa/nos3.git Desktop/github-nos3

# Check the contents of the directory to make sure the clone was successful
RUN ls -al /home/nos3/Desktop/github-nos3 || exit 1
WORKDIR /home/nos3/Desktop/github-nos3

# Update the submodules
RUN git submodule init
RUN git submodule update

# Give execute permissions to the script
RUN chmod +x /home/nos3/Desktop/github-nos3/gsw/scripts/create_cosmos_gem.sh
RUN chmod +x /home/nos3/Desktop/github-nos3/gsw/scripts/fsw_respawn.sh

# Build NOS3
#RUN make
#RUN make launch