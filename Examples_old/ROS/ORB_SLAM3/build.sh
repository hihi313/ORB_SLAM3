mkdir -p build
cd build
rm -rf *
# echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:/app/ORB_SLAM3/Examples_old/ROS/ORB_SLAM3" >> ~/.bashrc
# source ~/.bashrc
cmake -DROS_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 -DOpenCV_DIR=/usr/local/share -GNinja ..