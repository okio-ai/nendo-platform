# ------ core ----------
FROM python:3.10-slim-buster as core

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get -y install \
    gcc libsndfile1-dev \
    libpq-dev gnupg2 libportaudio2 ffmpeg \
    git libmpg123-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

# setup user
RUN groupadd -g $GID nendo
RUN useradd nendo --create-home -u $UID -g $GID -m -s /bin/bash 
USER nendo
WORKDIR /home/nendo

# install dependencies
RUN pip install \
    redis \
    rq \
    nendo>=0.2.1 \
    nendo-plugin-library-postgres>=0.1.1

USER root
RUN mkdir /home/nendo/nendo_library
RUN chown -R nendo:nendo /home/nendo/
USER nendo

ENV PATH="/home/nendo/.local/bin:$PATH"

# install pytorch
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
