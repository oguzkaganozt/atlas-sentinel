#!/usr/bin/env bash
set -e

# Function to print help message
print_help() {
    echo "Usage: build.sh [OPTIONS]"
    echo "Options:"
    echo "  --help          Display this help message"
    echo "  -h              Display this help message"
    echo "  --map           Specify the full map path for pointcloud and vector map"
    echo "  --test          Test mode with sample map and rosbag"
    echo ""
    echo "Note: Either --map or --test option should be specified."
}

# Parse arguments
while [ "$1" != "" ]; do
    case "$1" in
    --help | -h)
        print_help
        exit 1
        ;;
    --test)
        option_test=true
        ;;
    --map)
        map_path="$2"
        shift
        ;;
    *)
        echo "Unknown option: $1"
        print_help
        exit 1
        ;;
    esac
    shift
done

# Parse arguments
if [ -z "$option_test" ] && [ -z "$map_path" ]; then
    echo "!! Either --map or --test option should be specified !!"
    print_help
    exit 1
fi

if [ "$option_test" = true ]; then
    # set sample map path
    map_path="~/autoware_artifacts/sample-map-rosbag"
    
    # download sample map from google drive
    if [ ! -d ~/autoware_artifacts/sample-map-rosbag ]; then
        echo "Downloading sample map from google drive..."
        gdown -O ~/autoware_artifacts/ 'https://docs.google.com/uc?export=download&id=1A-8BvYRX3DhSzkAnOcGWFw5T30xTlwZI'
        unzip -d ~/autoware_artifacts/ ~/autoware_artifacts/sample-map-rosbag.zip
        rm ~/autoware_artifacts/sample-map-rosbag.zip
    else
        echo "Sample map are already downloaded."
    fi

    # download sample rosbag from google drive
    if [ ! -d ~/autoware_artifacts/sample-rosbag ]; then
        echo "Downloading sample rosbag from google drive..."
        gdown -O ~/autoware_artifacts/ 'https://docs.google.com/uc?export=download&id=1VnwJx9tI3kI_cTLzP61ktuAJ1ChgygpG'
        unzip -d ~/autoware_artifacts/ ~/autoware_artifacts/sample-rosbag.zip
        rm ~/autoware_artifacts/sample-rosbag.zip
    else
        echo "Sample rosbag are already downloaded."
    fi
else
    echo "Map path: $map_path"
fi

# enable xhost
xhost +

# start containers
echo "Starting containers..."
MAP_PATH=$map_path docker compose -f modules/autoware.docker-compose.yaml up
