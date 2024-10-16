# Copyright (c) 2021, NVIDIA CORPORATION. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# docker pull nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
ARG CUDA_VERSION=11.6.1
ARG CUDNN_VERSION=8
ARG OS_VERSION=20.04

FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu${OS_VERSION}
LABEL maintainer="yepeng"
ARG DEBIAN_FRONTEND=noninteractive

# ENV TRT_VERSION 7.2.3.4
ENV TRT_VERSION 8.4.1.5
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y lsb-release && \
    # 打印系统版本信息
    lsb_release -a && \
    # 打印内核版本等信息
    uname -a
    
# # 将 apt 的升级源切换成 阿里云
# RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
#             apt-get clean && \
#             rm /etc/apt/sources.list.d/*

# 安装必要的库
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    wget \
    zlib1g-dev \
    git \
    pkg-config \
    sudo \
    ssh \
    libssl-dev \
    pbzip2 \
    pv \
    bzip2 \
    unzip \
    devscripts \
    lintian \
    fakeroot \
    dh-make \
    build-essential \
    libgl1-mesa-glx

# 安装 python3 环境
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    python3-wheel &&\
    cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    ln -s /usr/bin/pip3 pip;

# 安装 TensorRT
# https://developer.nvidia.com/compute/machine-learning/tensorrt/secure/8.4.1/local_repos/nv-tensorrt-repo-ubuntu2004-cuda11.6-trt8.4.1.5-ga-20220604_1-1_arm64.deb
# https://developer.nvidia.com/compute/machine-learning/tensorrt/secure/8.4.2/local_repos/nv-tensorrt-repo-ubuntu2004-cuda11.6-trt8.4.2.4-ga-20220720_1-1_arm64.deb
# https://developer.nvidia.com/compute/machine-learning/tensorrt/secure/8.4.3/local_repos/nv-tensorrt-repo-ubuntu2004-cuda11.6-trt8.4.3.1-ga-20220813_1-1_arm64.deb
# https://developer.nvidia.com/compute/machine-learning/tensorrt/secure/8.4.0/local_repos/nv-tensorrt-repo-ubuntu2004-cuda11.6-trt8.4.0.6-ea-20220212_1-1_arm64.deb
# RUN cd /tmp &&\
RUN wget –no-check-certificate -v -O /tmp/nv-tensorrt-repo-ubuntu2004-cuda11.6-trt8.4.1.5-ga-20220604_1-1_arm64.deb https://developer.nvidia.com/compute/machine-learning/tensorrt/secure/8.4.1/local_repos/nv-tensorrt-repo-ubuntu2004-cuda11.6-trt8.4.1.5-ga-20220604_1-1_arm64.deb
RUN cd /tmp &&\
    dpkg -i nv-tensorrt-repo*.deb && apt-get update
RUN v="${TRT_VERSION%.*}-1+cuda${CUDA_VERSION%.*}" &&\
    apt-get install -y libnvinfer7=${v} libnvinfer-plugin7=${v} libnvparsers7=${v} libnvonnxparsers7=${v} libnvinfer-dev=${v} libnvinfer-plugin-dev=${v} libnvparsers-dev=${v} python3-libnvinfer=${v} &&\
    apt-mark hold libnvinfer7 libnvinfer-plugin7 libnvparsers7 libnvonnxparsers7 libnvinfer-dev libnvinfer-plugin-dev libnvparsers-dev python3-libnvinfer

# 升级 pip 并切换成国内豆瓣源
RUN python3 -m pip install -i https://pypi.douban.com/simple/ --upgrade pip
RUN pip3 config set global.index-url https://pypi.douban.com/simple/
RUN pip3 install setuptools>=41.0.0

# 升级 Cmake（可选）
RUN cd /tmp && \
    wget https://github.com/Kitware/CMake/releases/download/v3.14.4/cmake-3.14.4-Linux-x86_64.sh && \
    chmod +x cmake-3.14.4-Linux-x86_64.sh && \
    ./cmake-3.14.4-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir --skip-license && \
    rm ./cmake-3.14.4-Linux-x86_64.sh

# 设置环境变量和工作路径
ENV TRT_LIBPATH /usr/lib/x86_64-linux-gnu
ENV TRT_OSSPATH /workspace/TensorRT
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${TRT_OSSPATH}/build/out:${TRT_LIBPATH}"
WORKDIR /workspace

# 设置语言环境为中文，防止 print 中文报错
ENV LANG C.UTF-8

RUN ["/bin/bash"]
