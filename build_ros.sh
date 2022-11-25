clear
echo "Building ROS nodes"

cd Examples_old/ROS/ORB_SLAM3
mkdir build
cd build
rm -rf *
cmake .. -DROS_BUILD_TYPE=Release -DCMAKE_BUILD_TYPE=Release -GNinja
# make VERBOSE=1
ninja
