#!/usr/local/bin/bash

echo "Sart time=$(date +"%T")"
IMG_NAME="lmwafer/orb-slam-3-ready"
IMG_TAG="1.1-ubuntu18.04"
CTNR_NAME="orb-3-container"
CTNR_BASE_DIR="/app"

while getopts "t:r:e" opt
do
  case $opt in
    t)
        IMG_TAG="$OPTARG"
        ;;
    r)
        if [ "$OPTARG" == "m" ]
        then
            OPTARG="--rm"
        else
            OPTARG=""
        fi
        # Enable tracing
        set -x
        sudo xhost +local:root \
            && docker run --privileged \
                $OPTARG \
                -it \
                --gpus all \
                --name $CTNR_NAME \
                -p 8087:8087 \
                -e DISPLAY=$DISPLAY \
                -e QT_X11_NO_MITSHM=1 \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v /dev:/dev:ro \
                --mount type=volume,src="vscode-extensions",dst="/home/user/.vscode-server/extensions" \
                --mount type=bind,src="$PWD/datasets",dst="/dpds/ORB_SLAM3/datasets" \
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
        #--user="$(id -u):$(id -g)" --gpus=all\
        # docker run --rm -it --init \
        #     --ipc=host \
        #     --mount type=volume,src="vscode-extensions",dst="/home/user/.vscode-server/extensions" \
        #     --mount type=volume,src="apt-list",dst="/var/lib/apt/lists/" \
        #     --mount type=bind,src="$PWD",dst="$CTNR_BASE_DIR" \
        #     --workdir "$CTNR_BASE_DIR" \
        #     $IMG_NAME bash
        ;;
  esac
done