# ------ voiceanalysis bundle ----------
FROM nendo/core:3.8

USER root

RUN apt-get update \
    && apt-get -y install rubberband-cli \
    libasound-dev portaudio19-dev \
    libportaudio2 libportaudiocpp0 \
    && rm -rf /var/lib/apt/lists/*

USER nendo

# install dependencies
RUN pip install \
    einops \
    nendo-plugin-embed-clap \
    nendo-plugin-textgen \
    nendo-plugin-transcribe-whisper

# QWen requirements
RUN pip install transformers==4.37.1 accelerate tiktoken einops scipy transformers_stream_generator peft deepspeed
USER root
