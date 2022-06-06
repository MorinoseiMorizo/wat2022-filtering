# WAT 2022 Parallel Corpus Filtering Task NMT Training Scripts
This repository includes the NMT training scripts for the WAT 2022 parallel corpus filtering task.


## Requirements
We use the followings.
- NVIDIA Docker
- NVIDIA GPU with CUDA


### Docker
We prepared the Docker container that was already installed the tools for training.
Use the following commands to run.
`~/wat2022-filtering-corpus` should be changed to the corpus directory, which you placed cleaned data and dev/test sets as explained in the next section.
Note that you can change `~/wat2022-filtering` to the path you want to store the experimental results.
This will be connected to the container as `/host_disk`.
``` sh
$ docker pull morinoseimorizo/wat2022-filtering
$ docker run -it --gpus 1 -v ~/wat2022-filtering:/host_disk -v ~/wat2022-filtering-corpus:/corpus wat2022-filtering-train bash
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
TODO


## Contact
Please send an issue on GitHub or contact us by email.  

NTT Communication Science Laboratories  
Makoto Morishita  
jparacrawl-ml -a- hco.ntt.co.jp  