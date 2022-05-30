#!/bin/bash

echo "Sart time=$(date +"%T")"
IMG_NAME="lmwafer/orb-slam-3-ready"
IMG_TAG="1.1-ubuntu18.04"
CTNR_NAME="orb-3-container"
CTNR_BASE_DIR="/dpds"

while getopts "i:t:br:e" opt
do
  case $opt in
    i)
        if [ "$OPTARG" == "my" ]
        then
            IMG_NAME="my-orb-slam3"
            IMG_TAG="latest"
            CTNR_NAME="my-orb-3-ctnr"
            SLAM_DIR="--mount type=bind,src=$PWD,dst=$CTNR_BASE_DIR/ORB_SLAM3"
        else
            SLAM_DIR=""
        fi
        ;;
    t)
        IMG_TAG="$OPTARG"
        ;;
    b) 
        START="$(TZ=UTC0 printf '%(%s)T\n' '-1')" # `-1`  is the current time
        
        docker rmi $IMG_NAME
        docker build --no-cache -t $IMG_NAME .
        
        # Pring elapsed time
        ELAPSED=$(( $(TZ=UTC0 printf '%(%s)T\n' '-1') - START ))
        TZ=UTC0 printf 'Build duration=%(%H:%M:%S)T\n' "$ELAPSED"
        ;;
    r)
        if [ "$OPTARG" == "m" ]
        then
            RM="--rm"
        else
            RM=""
        fi
        # Enable tracing
        set -x
        # xhost +local:root \
        # -e DISPLAY=$DISPLAY \
        sudo xhost +localhost \
            && docker run --privileged \
                $RM \
                -it \
                --name $CTNR_NAME \
                -p 8087:8087 \
                -e DISPLAY="host.docker.internal:0" \
                -e QT_X11_NO_MITSHM=1 \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v /dev:/dev:ro \
                --mount type=volume,src="vscode-extensions",dst="/root/.vscode-server/extensions" \
                --mount type=volume,src="apt-list",dst="/var/lib/apt/lists/" \
                --mount type=bind,src="/Users/rolf/Documents/Datasets/MH_04_difficult",dst="$CTNR_BASE_DIR/ORB_SLAM3/datasets" \
                $SLAM_DIR \
                "$IMG_NAME:$IMG_TAG"
        # Disable tracing
        set +x        
        ;;
    e)
        docker exec -it --user=root $CTNR_NAME bash
        ;;
    \?) 
        echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    *)
        echo "*"
        ;;
  esac
done