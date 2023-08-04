FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ARG PYTHON_VERSION=3.9.16
ARG POETRY_VERSION=1.5.1

# install apt dependencies
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
RUN apt-get -y update \
    && apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libdb-dev \
        libffi-dev \
        libgdbm-dev \
        libgl1-mesa-dev \
        libgtk2.0-dev \
        liblzma-dev \
        libncursesw5-dev \
        libomp-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        pkg-config \
        tk-dev \
        uuid-dev \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# install python
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz \
    && tar xJf Python-${PYTHON_VERSION}.tar.xz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd ../ \
    && rm -r Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tar.xz

# install poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry POETRY_VERSION=${POETRY_VERSION} python3 - \
    && ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry \
    && poetry config virtualenvs.create false

WORKDIR /opt
# install python packages
COPY pyproject.toml poetry.lock /opt/FaceVerse/
RUN cd FaceVerse/ \
    && poetry install --no-root

# download the 3D model
RUN wget "https://drive.google.com/uc?export=download&id=1WrQ1UNMY30YAl8WxAbqVb6ZsPEQ_FHW4" -O faceverse_v3_6_s.npy

# copy sources
COPY faceversev3_jittor /opt/FaceVerse/faceversev3_jittor
RUN mv faceverse_v3_6_s.npy /opt/FaceVerse/faceversev3_jittor/data/
