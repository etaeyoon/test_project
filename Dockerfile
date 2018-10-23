FROM nvidia/cuda:10.0-devel-ubuntu16.04
ENV DEBIAN_FRONTEND noninteractive

COPY sources.xenial.list /etc/apt/sources.list

ENV http_proxy http://10.112.1.184:8080/
ENV https_proxy https://10.112.1.184:8080/

RUN rm /etc/apt/sources.list.d/cuda.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils software-properties-common
RUN apt-get upgrade -y
RUN apt-get install -y build-essential cmake git python gdb valgrind devscripts apt-utils software-properties-common gcc g++ wget unzip

# Add user
RUN adduser --gecos "ROS User" --disabled-password taeyoon
RUN usermod -a -G dialout taeyoon

WORKDIR /home/taeyoon

# Install GLEW
RUN apt-get install -y libglew-dev

# Install Pangolin
RUN git clone https://github.com/stevenlovegrove/Pangolin.git
WORKDIR /home/taeyoon/Pangolin
RUN /bin/bash -c "mkdir build"
WORKDIR build
RUN cmake ..
RUN cmake --build .

# Install ROS Kinetic
#RUN wget -qO - http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/7fa2af80.pub | apt-key add -
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sh -c 'echo "deb-src http://packages.ros.org/ros/ubuntu xenial main" >> /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 5523BAEEB01FA116
RUN apt-get update && apt-get install -y ros-kinetic-desktop-full

WORKDIR /home/taeyoon
RUN apt-get source ros-kinetic-opencv3
RUN apt-get build-dep -y ros-kinetic-opencv3
WORKDIR /home/taeyoon/ros-kinetic-opencv3-3.3.1
#RUN sh -c 'echo "export DEB_CXXFLAGS_MAINT_APPEND=-DNDEBUG -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D CUDA_GENERATION=Kepler -DARCH=sm_30 -DGENCODE=arch=compute_52,code=sm_52 -DGENCODE=arch=compute_61,code=compute_61 --parallel" >> debian/rules'
RUN sh -c 'echo "export DEB_CXXFLAGS_MAINT_APPEND=-DNDEBUG -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D CUDA_GENERATION=Kepler" >> debian/rules'
RUN dpkg-buildpackage -uc -b -j8
WORKDIR ..
RUN dpkg -i ros-kinetic-opencv3_3.3.1-5xenial_amd64.deb

# Install Eigen
# WORKDIR /home/taeyoon
# RUN wget --no-check-certificate http://bitbucket.org/eigen/eigen/get/3.3-beta2.zip
# RUN unzip 3.3-beta2.zip
# RUN /bin/bash -c 'mv eigen-eigen-69d418c06999 eigen'
# WORKDIR eigen
# RUN /bin/bash -c "mkdir build"
# WORKDIR build
# RUN cmake ..
# RUN make
# RUN make install
# #RUN /bin/bash -c "ln -s /usr/include/eigen3/Eigen /usr/local/include/Eigen"
# RUN /bin/bash -c "ln -s /usr/include/eigen3/Eigen /usr/local/include/"
# WORKDIR /usr/local/include
# RUN ln -s eigen3/unsupported unsupported
RUN apt-get install -y libsuitesparse-dev libeigen3-dev

WORKDIR /home/taeyoon
COPY SRnD+Web+Proxy.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates 
#RUN export GIT_SSL_NO_VERIFY=1
RUN git clone https://github.sec.samsung.net/RS7-AutoDriving/Ext_g2o.git
WORKDIR Ext_g2o
RUN patch -p1 < packaging/0001-Add-G2O_USE_CSPARSE-option.patch
RUN patch -p1 < packaging/0002-DISABLE-BUILD-OPTIONS.patch
RUN patch -p1 < packaging/0003-CHANGE-LIB-PATH.patch
RUN patch -p1 < packaging/0004-ADD-PC-FILE.patch
RUN mkdir build
WORKDIR build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DG2O_USE_CSPARSE=OFF -DG2O_BUILD_EXAMPLES=OFF -DG2O_USE_OPENGL=OFF -DG2O_BUILD_APPS=OFF -DG2O_BUILD_LINKED_APPS=OFF -DCMAKE_INSTALL_BINDIR="/usr/local/bin/" -DCMAKE_INSTALL_LIBDIR="/usr/local/lib/" ..
RUN make install

RUN source /opt/ros/kinetic/setup.bash

ENV DEBIAN_FRONTEND teletype
