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

# mistral requirements
RUN pip install transformers==4.37.1 accelerate tiktoken scipy transformers_stream_generator==0.0.4 peft deepspeed

# install auto-gptq for quantized mistral
#RUN pip install auto-gptq --extra-index-url https://huggingface.github.io/autogptq-index/whl/cu122
RUN pip install auto-gptq --extra-index-url https://huggingface.github.io/autogptq-index/whl/cu117

# install flash-attn for speedup on CUDA GPUs
RUN pip install flash-attn --no-build-isolation
