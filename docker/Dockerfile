###########################################
# Base Image for ROS2 #
###########################################

# FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 as base
# FROM nvcr.io/nvidia/pytorch:r36.2.0-pth2.2-py3 as base
FROM dustynv/pytorch:2.7-r36.4.0 AS base
ARG USERNAME=jetson
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG ROS_DISTRO=humble
ENV HOME=/home/${USERNAME}

# prevent any interactive prompts during package operations
ENV DEBIAN_FRONTEND=noninteractive

# Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi


# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN apt-get update && apt-get upgrade -y
ENV SHELL=/bin/bash


# Ref: https://roboticseabass.com/2021/04/21/docker-and-ros/
 
# Following the ROS2 Humble official setup guide: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html

# Locale Setup
RUN locale  # check for UTF-8

RUN apt update --fix-missing && apt install -y --no-install-recommends locales 
RUN locale-gen en_US en_US.UTF-8 
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 
RUN export LANG=en_US.UTF-8 
RUN locale  # verify settings

# Update and install necessary packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    locales \
    build-essential \
    lsb-release \
    software-properties-common \
    curl \
    python3-pip \
    # python3-distutils \
    # python3-setuptools \
    # python3-wheel \
    # python3-opencv \
    git \
    gdb \
    gdbserver \
    gedit \
    xtermcontrol \
    nano \
    terminator \
    && rm -rf /var/lib/apt/lists/*

# Install ssh if not already installed
RUN if [ ! -x "$(command -v ssh)" ]; then \
      apt-get update -qq \
      && apt-get install -y --no-install-recommends \
        openssh-client \
      && rm -rf /var/lib/apt/lists/*; \
    fi

RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# Set shell to bash
ENV SHELL=/bin/bash
# SHELL [ "/bin/bash" , "-c" ]

# Add repository for ROS2 packages
RUN apt install software-properties-common -y --no-install-recommends \
    && add-apt-repository universe

# Use the official ROS2 apt key and repository directly.  This avoids
# downloading a .deb file that can be truncated during image builds and
# eliminates the dpkg error seen earlier.
# RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - \
#  && echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
#       > /etc/apt/sources.list.d/ros2.list

# If you still prefer the ros2-apt-source package, it can be fetched with
# retries to guard against corruption:
RUN export ROS_APT_SOURCE_VERSION=$(curl -sSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb


# Install ROS2 Humble
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-dev-tools \
    python3-rosdep \
    ros-${ROS_DISTRO}-tf-transformations \
    ros-${ROS_DISTRO}-rqt \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-moveit \
    # ros-${ROS_DISTRO}-moveit-visual-tools \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers \
    ros-${ROS_DISTRO}-tf2-tools \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Initialize rosdep
RUN rosdep init \
    && rosdep fix-permissions \
    && rosdep update

# Setup
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> $HOME/.bashrc

###########################################
# Overlay Image for Workspace and packages #
###########################################
FROM base AS overlay_1

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

# Create a workspace and clone relevant repos
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && mkdir -p $HOME/wbk_ur10_ws/src

WORKDIR $HOME/wbk_ur10_ws/src

RUN apt-get update && apt-get install -y \
    # Install any build dependencies here.
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install ninja
# RUN python3 -m pip install --upgrade "setuptools<70" "wheel" "Cython"

COPY ./vmf/requirements.txt ./
RUN pip3 install --index-url https://pypi.org/simple -r requirements.txt \
    && pip3 install --index-url https://pypi.org/simple --ignore-installed open3d \
    && pip3 install --index-url https://pypi.org/simple numpy==1.26.4

# WORKDIR $HOME/wbk_ur10_ws/src
# RUN mkdir -p vmf/vmf_contact_main/openpoints/
# COPY ./vmf_contact_main/openpoints/ ./vmf/vmf_contact_main/openpoints/
# # RUN chmod +x ./vmf/openpoints/install.sh
# RUN cd ./vmf/vmf_contact_main/openpoints/cpp/chamfer_dist && python3 setup.py install
# RUN cd ./vmf/vmf_contact_main/openpoints/cpp/emd && MAX_JOBS=4 python3 setup.py install
# RUN cd ./vmf/vmf_contact_main/openpoints/cpp/pointnet2_batch && MAX_JOBS=4 python3 setup.py install
# RUN cd ./vmf/vmf_contact_main/openpoints/cpp/pointops && MAX_JOBS=4 python3 setup.py install

COPY ./arm_api2/ ./arm_api2/
COPY ./arm_api2_msgs/ ./arm_api2_msgs/
COPY ./arm_api2_py/ ./arm_api2_py/

# COPY dependencies.repos .
# RUN vcs import < dependencies.repos
# RUN git clone main git@gitlab.kit.edu:unvug/arm_api2_py.git \
#     && git clone git@gitlab.kit.edu:kit/ifl/gruppen/air/ros2/arm_api2.git \
#     && git clone git@gitlab.kit.edu:kit/ifl/gruppen/air/ros2/arm_api2_msgs.git \
#     && apt-get install python3-colcon-common-extensions -y

WORKDIR $HOME/wbk_ur10_ws
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-moveit-visual-tools \
    ros-${ROS_DISTRO}-moveit-servo \
    && rm -rf /var/lib/apt/lists/*    
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
    && colcon build

# RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/$USERNAME/.bashrc 

COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

# # Set the working folder at startup
# WORKDIR $HOME/wbk_ur10_ws

###########################################
# Overlay Image for Workspace and packages #
###########################################
FROM overlay_1 AS overlay_2

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

# Run the install.sh script
WORKDIR $HOME/wbk_ur10_ws/src
RUN mkdir /vmf
COPY ./vmf/ ./vmf/
# RUN chmod +x ./vmf/install.sh
RUN cd ./vmf/vmf_contact_main/openpoints/cpp/chamfer_dist && python3 setup.py install
RUN cd ./vmf/vmf_contact_main/openpoints/cpp/emd && MAX_JOBS=4 python3 setup.py install
RUN cd ./vmf/vmf_contact_main/openpoints/cpp/pointnet2_batch && MAX_JOBS=4 python3 setup.py install
RUN cd ./vmf/vmf_contact_main/openpoints/cpp/pointops && MAX_JOBS=4 python3 setup.py install
# KEEPS FAILING
# RUN cd ./vmf/vmf_contact_main/openpoints/cpp/subsampling && python3 setup.py build_ext --inplace

WORKDIR $HOME/wbk_ur10_ws/src
COPY ./vmf/ ./vmf/

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
# ARG UID=10001
# RUN adduser \
#     --disabled-password \
#     --gecos "" \
#     --home "/nonexistent" \
#     --shell "/sbin/nologin" \
#     --no-create-home \
#     --uid "${UID}" \
#     appuser
# USER appuser

WORKDIR $HOME/wbk_ur10_ws

# Add a HEALTHCHECK instruction to ensure the container's health is monitored.
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1
