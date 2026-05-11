#!/bin/bash
# Basic entrypoint for ROS Docker containers

# Source ROS 2
source /opt/ros/humble/setup.bash
echo "Sourced ROS 2 humble"

# Source the base workspace, if built
if [ -f ~/wbk_ur10_ws/install/setup.bash ]
then
  source ~/wbk_ur10_ws/install/setup.bash
  echo "Sourced WBK UR10 base workspace"
fi

# # Source the overlay workspace, if built
# if [ -f ~/overlay_ws/install/setup.bash ]
# then
#   source ~/overlay_ws/install/setup.bash
#   echo "Sourced autonomy overlay workspace"
# fi

# Execute the command passed into this entrypoint
if [ $# -eq 0 ]; then
  exec bash
else
  exec "$@"
fi

