##!/bin/bash



BINARY_NAME="test_output"
R=53
SNR=5200
IMG="../datasets/mav0/cam0/data/1403638130995097088.png"

while getopts "R:S:I:mr" opt
do
  case $opt in
    R)
        R=$OPTARG
        ;;
    S)
        SNR=$OPTARG
        ;;
    I)
        IMG=$OPTARG
        ;;
    m)
        make
        ;;
    r)
        # Enable tracing
        set -x        
        ./$BINARY_NAME $R $SNR "$IMG"
        set +x
        ;;
    \?) 
        echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
  esac
done