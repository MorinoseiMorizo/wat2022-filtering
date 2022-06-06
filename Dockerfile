FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace
RUN chmod -R a+w .

RUN apt-get update && apt-get install -y python3-dev python3-pip wget vim tzdata

RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

# sentencepiece
RUN apt-get -y install git cmake build-essential pkg-config libgoogle-perftools-dev && \
    git clone https://github.com/google/sentencepiece.git && \
    cd sentencepiece && mkdir build && cd build && \
    cmake ..  && make -j $(nproc) && make install && \
    ldconfig -v
WORKDIR /workspace

# fairseq
RUN git clone https://github.com/pytorch/fairseq && cd fairseq && \
    git checkout ce961a9fd26aef5130720cb6a171ddd5b51a8961 && \
    pip3 install --editable . && \
    pip3 install .

WORKDIR /workspace

# sacrebleu
RUN pip3 install 'sacrebleu[ja]'

# mecab for evaluation
RUN apt-get -y install mecab libmecab-dev mecab-ipadic-utf8

# accept Japanese input
RUN apt-get install -y language-pack-ja-base language-pack-ja
ENV LANG=ja_JP.UTF-8

# copy scripts
COPY ./scripts/ /workspace/scripts
COPY ./preprocess.sh ./train_model_big_enja.sh ./train_model_big_jaen.sh ./run_all.sh /workspace/
