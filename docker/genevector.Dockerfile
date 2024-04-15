# Use a specific version of Ubuntu as the base image
FROM --platform=linux/x86_64 rocker/verse:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y software-properties-common gcc gfortran && \
    add-apt-repository -y ppa:deadsnakes/ppa

RUN apt-get install git

RUN apt-get update && apt-get install -y python3.9 python3-distutils python3-pip python3-apt
RUN python3 -m pip install numpy==1.25.2
RUN python3 -m pip install PyYAML==6.0.1
RUN python3 -m pip install torch --index-url https://download.pytorch.org/whl/cpu

WORKDIR /opt

RUN git clone https://github.com/nceglia/genevector.git

RUN cd genevector && \
    python3 -m pip install -r requirements.txt && \
    python3 setup.py install
