# ------ core ----------
FROM nvcr.io/nvidia/pytorch:22.04-py3

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

# setup user
RUN groupadd -g $GID nendo
RUN useradd nendo --create-home -u $UID -g $GID -m -s /bin/bash 
USER nendo
WORKDIR /home/nendo

# install dependencies
RUN pip install \
    redis \
    rq \
    nendo>=0.2.0 \
    nendo-plugin-library-postgres

USER root
RUN mkdir /home/nendo/nendo_library
RUN chown -R nendo:nendo /home/nendo/
USER nendo

ENV PATH="/home/nendo/.local/bin:$PATH"

# install pytorch
# RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
