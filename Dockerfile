FROM osrf/ros:noetic-desktop-full

ENV TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive
ARG ROOT_PWD=root

USER root
# Set root password
RUN echo 'root:${ROOT_PWD}' | chpasswd

# Install things here
WORKDIR /tmp

# Install 
RUN apt update \
    && apt install -y --no-install-recommends \
    nano git ca-certificates \
    # C/C++ toolchains
    cmake make ninja-build gcc g++ gdb \
    # OpenCV dependencies
    libavcodec-dev libavformat-dev libswscale-dev libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev libgtk-3-dev libpng-dev libjpeg-dev libopenexr-dev libtiff-dev \
    libwebp-dev \
    # Eigen
    libeigen3-dev \
    # g2o dependencies
    libsuitesparse-dev qtdeclarative5-dev qt5-qmake libqglviewer-dev-qt5 \
    # Python libpython2.7-dev
    python3 python-is-python3\
    # Pangolin
    libgl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols libegl1-mesa-dev \
    libc++-dev libglew-dev libavutil-dev libavdevice-dev \
    # GUI xeyes
    libcanberra-gtk-module libcanberra-gtk3-module

# Install Pangolin
RUN git clone --recursive --branch v0.8 --single-branch https://github.com/stevenlovegrove/Pangolin.git \
    && cd Pangolin \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -GNinja ../\
    && ninja \
    && ninja install

# Install OpenCV
RUN git clone --branch 4.6.0 --single-branch https://github.com/opencv/opencv.git \
    && cd opencv \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_TIFF=ON \
    -D WITH_CUDA=ON \
    -D ENABLE_AVX=OFF \
    -D WITH_OPENGL=OFF \
    -D WITH_OPENCL=OFF \
    -D WITH_IPP=OFF \
    -D WITH_TBB=ON \
    -D BUILD_TBB=ON \
    -D WITH_EIGEN=ON \
    -D WITH_V4L=OFF \
    -D WITH_VTK=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -GNinja \
    ../ \
    && ninja \
    && ninja install

# Clean up
RUN apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# Set up env
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:$PWD/ORB_SLAM3/Examples_old/ROS/ORB_SLAM3" >> ~/.bashrc

CMD bash 