FROM ubuntu:16.04
MAINTAINER Mykola Dimura <mykola.dimura@gmail.com> 

RUN apt-get update && apt-get install -y build-essential cmake git qt5-default \
  libqt5serialport5-dev qtmultimedia5-dev libboost-all-dev libcaf-dev libeigen3-dev \
  python-numpy

#install libraries from github/sourceforge
RUN export BUILDDIR=$(mktemp -d -t build-XXXX); cd "${BUILDDIR}"; \
  git clone -b experimental https://git.code.sf.net/p/pteros/code pteros; \
  cd "${BUILDDIR}/pteros"; rm -rf build; mkdir build; cd build; \
  cmake -DSTANDALONE_PLUGINS=OFF -DUSE_OPENMP=OFF -DPYTHON_BINDINGS=OFF \
  -DPOWERSASA=OFF -DMAKE_PACKAGE=ON -DCMAKE_BUILD_TYPE=Release ..; \
  make package; dpkg -i pteros-*.deb

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

#cleanup the build directory
RUN rm -rf "${BUILDDIR}"
