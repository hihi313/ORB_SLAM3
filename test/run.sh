##!/bin/bash

BINARY_NAME="test_output"

while getopts "mr" opt
do
  case $opt in
    m)
        make
        ;;
    r)
        ./$BINARY_NAME
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