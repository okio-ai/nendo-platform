# ------ core ----------
FROM nvcr.io/nvidia/pytorch:22.08-py3

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get -y install \
    gcc libsndfile1-dev \
    libpq-dev gnupg2 libportaudio2 ffmpeg \
    git libmpg123-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

# uninstall older version of torch
RUN pip uninstall -y torch torchvision torchaudio

# setup user
RUN groupadd -g $GID nendo
RUN useradd nendo --create-home -u $UID -g $GID -m -s /bin/bash 
USER nendo
WORKDIR /home/nendo

# install dependencies
RUN pip install \
    redis \
    rq \
    wrapt-timeout-decorator>=1.5.1 \
    nendo>=0.2.0 \
    nendo-plugin-library-postgres>=0.1.2

USER root
RUN mkdir /home/nendo/nendo_library
RUN mkdir -p /home/nendo/.cache/huggingface
RUN chown -R nendo:nendo /home/nendo/
USER nendo

ENV PATH="/home/nendo/.local/bin:$PATH"
ENV LIBRARY_PATH="/home/nendo/nendo_library"

# fix for protobuf bug
RUN pip install protobuf==3.20.*

# install tensorflow for cuda 11.7
RUN pip install tensorflow[and-cuda]==2.11

# install pytorch
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117

# for A10 lambda machines
#RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu122
