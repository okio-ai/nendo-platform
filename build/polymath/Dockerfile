# ------ polymath bundle ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    && rm -rf /var/lib/apt/lists/*

USER nendo

RUN pip install git+https://github.com/CPJKU/madmom.git@0551aa8

# install tensorflow version required for essentia-tensorflow
# RUN pip uninstall -y tensorflow
# RUN pip install tensorflow-gpu==1.15

RUN pip install \
    nendo-plugin-quantize-core \
    nendo-plugin-classify-core \
    nendo-plugin-stemify-demucs \
    nendo-plugin-loopify \
    nendo-plugin-embed-clap

# Run once to ensure demucs works and trigger the default model download
RUN python3 -m demucs -d cpu ./test.mp3 
RUN rm -r separated

RUN pip uninstall -y soundfile
RUN pip install soundfile
RUN pip install soundfile==0.12.1
RUN pip install numpy==1.22.4
# RUN pip install torch==1.12.0+cu116 torchvision==0.13.0+cu116 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu116

# fix for the essentia vs. essentia-tensorflow conflict
RUN pip uninstall -y essentia essentia-tensorflow
RUN pip install essentia-tensorflow
