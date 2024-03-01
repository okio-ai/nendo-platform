# ------ webimport tool ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    && rm -rf /var/lib/apt/lists/*

USER nendo

RUN pip install nendo_plugin_import_core
