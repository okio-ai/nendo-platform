# ------ polymath bundle ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    espeak-ng \
    && rm -rf /var/lib/apt/lists/*

USER nendo
RUN pip install git+https://github.com/resemble-ai/monotonic_align.git
RUN pip install nendo-plugin-voicegen-styletts2
