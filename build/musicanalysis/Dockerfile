# ------ musicanalysis bundle ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    && rm -rf /var/lib/apt/lists/*

USER nendo

# install dependencies
RUN git clone https://github.com/okio-ai/lp-music-caps.git
RUN pip install -e ./lp-music-caps

# install nendo plugins
RUN pip install \
    nendo-plugin-classify-core \
    nendo-plugin-embed-clap \
    nendo-plugin-caption-lpmusiccaps
