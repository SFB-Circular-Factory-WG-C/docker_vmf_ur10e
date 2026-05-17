# docker_vmf_ur10e
Multi-stage container Dockerfile and its compose yaml for deployment of vMF-Contact algorithm on a UR10e.

Reference: [sea-bass/turtlebot3-behavior-demos](https://github.com/sea-bass/turtlebot3_behavior_demos) and this [article](https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/).

## How does it work?
One of the great things about Docker is the ability to create multi-stage builds, where one image stacks on top of the other.
![docker_stages](docker_stages.png)
- A "source image" which is compatible to our Jetson Orin Nano.
- A "base image" on top of it which installs ROS and other dependencies we need.
- A "overlay_1 image" which mounts arm_api packages to the container.
- A "overlay_2 image" which mounts the vmf package and installs all dependencies of it.

## How to use it?
- Clone this repo
``` bash
git clone https://github.com/SFB-Circular-Factory-WG-C/docker_vmf_ur10e.git
```
- Clone arm_api and vmf repos under the root folder of the above repo
```bash
cd docker_vmf_ur10e
git clone -b jetson https://github.com/YiminHu26/vMF-Contact.git
git clone git@gitlab.kit.edu:unvug/arm_api2_py.git
git clone git@gitlab.kit.edu:kit/ifl/gruppen/air/ros2/arm_api2_msgs.git
git clone git@gitlab.kit.edu:kit/ifl/gruppen/air/ros2/arm_api2.git
```
- **Notice there needs to be a backbone .ckpt file for the vmf algorithm. It is too big to be uploaded to Github.**
    - It can be found under /vmf/logs/ on the already running machine. Otherwise please contact IFL for this file.
- Build the image
    - **NEVER** use ``docker compose build`` directly, otherwise it would run up the memory of a 8GB Jetson Orin Nano very soon and it would stuck.
```bash
# Run the next image build command only after the previous image is built.
docker compose build ros2_base
# ros2_base build takes about 500s

docker compose build overlay_1
# overlay_1 build takes about 300s

docker compose build overlay_2
# overlay2 build takes about 1400s
```
- Start up the ``overlay2`` container.
    - It's not necessary to start the other two containers.
```bash
docker compose up overlay_2 -d
```
- Get graphics to work inside the docker container
```bash
xhost +
```
- Open an interactive shell to a running container
```
docker exec -it overlay_2 bash
```
- Now we are in the container, make sure to source every time when we start the interactive shell
```shell
source install/setup.bash
```
- And finally it's time to start the vMF and arm_api
```shell
# Terminal1
# Start the vmf client before starting the vmf inference
ros2 run arm_api_py vmf_client

# Terminal2
python3 src/vmf/vmf_contact_main/test_9_min_th_dist_cog.py
```