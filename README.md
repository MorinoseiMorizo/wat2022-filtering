# WAT 2022 Parallel Corpus Filtering Task NMT Training Scripts
This repository includes the NMT training scripts for the WAT 2022 parallel corpus filtering task.
We strongly recommend you pull the latest scripts since they may be subject to change.


## Requirements
We use the followings.
- NVIDIA Docker
- NVIDIA GPU with CUDA

ASPEC dev/test sets are also required for training.


### Docker
We prepared the Docker container that was already installed the tools for training.
Use the following commands to run.
You might want to change some variables in `docker_run.sh`.
`~/wat2022-filtering-corpus` should be changed to the corpus directory, which you placed cleaned data and dev/test sets as explained in the next section.
Note that you can change `~/wat2022-filtering` to the path you want to store the experimental results.
This will be connected to the container as `/host_disk`.
``` sh
$ git clone https://github.com/MorinoseiMorizo/wat2022-filtering.git
$ cd wat2022-filtering
$ ./docker_build.sh
$ ./docker_run.sh
```


## Prepare the data
First, you need to prepare the corpus.
Please place and rename your cleaned corpus and ASPEC dev/test as follows:

``` 
▾ wat2022-filtering-corpus/
    aspec-je.dev.en
    aspec-je.dev.ja
    aspec-je.test.en
    aspec-je.test.ja
    train.en
    train.ja
```


## Training the NMT model
`./docker_run.sh` will train the model and evaluate it.

Preprocessing and training details are written in `preprocess.sh` and `train_model_big_*.sh`, respectively.
We expect to train the model on a single A100 GPU.
If you use other GPUs, you may need to reduce GPU memory usage.
In such a case, you can change `--max-tokens` to 5000, and `--update-freq` to 16.


## Contact
Please send an issue on GitHub or contact us by email.  

NTT Communication Science Laboratories  
Makoto Morishita  
jparacrawl-ml -a- hco.ntt.co.jp  
