FROM lmwafer/orb-slam-3-ready:1.1-ubuntu18.04

# Defualt user of anibali/pytorch
ARG ROOT_PWD=root

USER root
# Set root password
RUN echo 'root:${ROOT_PWD}' | chpasswd

# Replace to latest ORB_SLAM3 code by mount host volume
RUN rm -rf /dpds/ORB_SLAM3

# Install 
RUN apt update \
    && apt install -y --no-install-recommends \
    nano g++ cmake make ninja-build git gcc ca-certificates gdb

# Clean up
RUN apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD bash 