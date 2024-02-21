# ------ quantizer plugin ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    && rm -rf /var/lib/apt/lists/*

USER nendo

RUN pip install nendo-plugin-quantize-core

RUN pip uninstall -y soundfile
RUN pip install soundfile
