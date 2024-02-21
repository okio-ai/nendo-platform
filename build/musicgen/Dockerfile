# ------ polymath bundle ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    && rm -rf /var/lib/apt/lists/*

USER nendo

RUN pip install git+https://github.com/facebookresearch/audiocraft
# make sure we have the correct cuda version
RUN pip install --force-reinstall torch==2.1 torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu118
RUN pip install nendo-plugin-musicgen
