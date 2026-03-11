#!/bin/bash
USERNAME=${USERNAME:-$(id -un)}
# Sample script to run a command in a Docker container
#
# Usage Example:
# ./run_docker.sh turtlebot_behavior:overlay "ros2 launch tb_worlds tb_demo_world.launch.py"

# Define Docker volumes and environment variables
DOCKER_VOLUMES="
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume="${XAUTHORITY:-$HOME/.Xauthority}:/root/.Xauthority" \
--volume="${PWD}/tb3_autonomy":"/home/${USERNAME}/overlay_ws/src/tb3_autonomy":rw \
--volume="${PWD}/tb3_worlds":"/home/${USERNAME}/overlay_ws/src/tb3_worlds":rw \
"
DOCKER_ENV_VARS="
--env="TURTLEBOT_MODEL=3" \
--env="DISPLAY" \
--env="QT_X11_NO_MITSHM=1" \
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
"
DOCKER_ARGS=${DOCKER_VOLUMES}" "${DOCKER_ENV_VARS}

# Run the command
docker run -it --net=host --ipc=host --privileged ${DOCKER_ARGS} "$1" bash -c "$2"
# docker run -it --net=host --ipc=host --privileged ${DOCKER_ARGS} "$1" bash