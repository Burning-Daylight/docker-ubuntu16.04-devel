FROM ubuntu:latest
MAINTAINER Mykola Dimura <mykola.dimura@gmail.com> 

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget build-essential cmake git qt5-default \
  libqt5serialport5-dev qtmultimedia5-dev libboost-all-dev libcaf-dev libeigen3-dev \
  python3-dev python3-numpy python3-pytest python3-pip pybind11-dev\
  libspdlog-dev libfmt-dev

RUN pip3 install "pybind11[global]"

#add eigen to include dir to work around the bug in eigen3 package
RUN ln -s /usr/include/eigen3/Eigen /usr/local/include/Eigen

RUN export BUILDDIR=$(mktemp -d -t build-XXXX); 

RUN cd "${BUILDDIR}"; git clone https://github.com/efficient/libcuckoo.git libcuckoo; \
  cd libcuckoo; rm -rf build; mkdir build; cd build; \
  cmake -DBUILD_TESTS=1 -DBUILD_UNIVERSAL_BENCHMARK=1 -DCMAKE_BUILD_TYPE=Release .. ; \
  make all; make install

RUN cd "${BUILDDIR}"; git clone https://github.com/Amanieu/asyncplusplus.git asyncplusplus; \
  cd asyncplusplus; rm -rf build; mkdir build; cd build; \
  cmake -DBUILD_SHARED_LIBS=1 -USE_CXX_EXCEPTIONS=1 -DCMAKE_BUILD_TYPE=Release .. ; \
  make package; dpkg -i Async++-*.deb

RUN cd "${BUILDDIR}"; git clone https://github.com/cameron314/readerwriterqueue.git readerwriterqueue; \
  cd readerwriterqueue; INCLUDE_INSTALL_DIR=/usr/local/include/; INSTALL_PREFIX=/opt/readerwriterqueue/; \
  mkdir -p "${INSTALL_PREFIX}"; cp readerwriterqueue.h atomicops.h "${INSTALL_PREFIX}"; \
  ln -s "${INSTALL_PREFIX}" "${INCLUDE_INSTALL_DIR}/readerwriterqueue"

RUN cd "${BUILDDIR}"; \
  git clone https://github.com/yesint/pteros.git pteros; \
  cd "${BUILDDIR}/pteros"; rm -rf build; mkdir build; cd build; \
  cmake -DEIGEN3_INCLUDE_DIR=/usr/include/eigen3 -DMAKE_PACKAGE=ON -DCMAKE_BUILD_TYPE=Release -DWITH_OPENBABEL=OFF -DWITH_GROMACS=OFF ..; \
  make package; dpkg --force-all -i pteros-*.deb

RUN echo 'deb http://download.opensuse.org/repositories/home:/Luthaf/xUbuntu_20.04/ /' > /etc/apt/sources.list.d/chemfiles.list; \
    wget -qO - https://download.opensuse.org/repositories/home:Luthaf/xUbuntu_20.04/Release.key | gpg --dearmor > /etc/apt/trusted.gpg.d/chemfiles.gpg; \
    apt-get update; \
    apt-get install chemfiles
 
#cleanup the build directory
RUN rm -rf "${BUILDDIR}"; apt-get clean;

RUN mkdir -p /workdir
WORKDIR /workdir
