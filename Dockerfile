FROM ubuntu:16.04
MAINTAINER Mykola Dimura <mykola.dimura@gmail.com> 
RUN apt-get update && apt-get install -y build-essential cmake git qt5-default libqt5serialport5-dev qtmultimedia5-dev libboost-all-dev libcaf-dev libeigen3-dev
