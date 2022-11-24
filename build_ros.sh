clear
echo "Building ROS nodes"

cd Examples_old/ROS/ORB_SLAM3
mkdir build
cd build
rm -rf *
cmake .. -DROS_BUILD_TYPE=Debug -DCMAKE_BUILD_TYPE=Debug -GNinja
# make VERBOSE=1
ninja
