# WAT 2022 Parallel Corpus Filtering Task NMT Training Scripts
This repository includes the NMT training scripts for the WAT 2022 parallel corpus filtering task.


## Requirements
We use the followings.
- Docker
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
▾ corpus/
    aspec-je.dev.en
    aspec-je.dev.ja
    aspec-je.test.en
    aspec-je.test.ja
    train.en
    train.ja
```

## Training the NMT model
TODO


## Decoding with the trained model
TODO

Before fine-tuning experiments, let's try to decode (translate) a file with the pre-trained model to see how the current model works.
We prepared `decode.sh` that decodes the KFTT test set with the pre-trained NMT model.
``` sh
$ ./decode.sh
```

### Evaluation
We can automatically evaluate the translation results by comparing reference translations.
Here, we use [BLEU](https://www.aclweb.org/anthology/P02-1040/) scores, which is the most used evaluation matrix in the MT community.
The script automatically calculates the BLEU score and save it to `decode/test.log`.
BLEU scores ranges 0 to 100, so this result is somewhat low.
``` sh
$ cat decode/test.log
BLEU+case.mixed+numrefs.1+smooth.exp+tok.intl+version.1.4.2 = 14.2 50.4/22.0/11.2/5.9 (BP = 0.868 ratio = 0.876 hyp_len = 24351 ref_len = 27790)
```

It is also important to check outputs as well as BLEU scores.
Input and output files are located on `./corpus/kftt-data-1.0/data/orig/kyoto-test.ja` and `./decode/kyoto-test.ja.true.detok`.
```
$ head -n4 ./corpus/kftt-data-1.0/data/orig/kyoto-test.ja
InfoboxBuddhist
道元（どうげん）は、鎌倉時代初期の禅僧。
曹洞宗の開祖。
晩年に希玄という異称も用いた。。

$ head -n4 ./decode/kyoto-test.ja.true.detok
InfoboxBuddhist
Dogen is a Zen monk from the early Kamakura period.
The founder of the Soto sect.
In his later years, he also used the heterogeneous name "Legend".
```
This is just an example so the result may vary.

You can also find the reference translations at `./corpus/kftt-data-1.0/data/orig/kyoto-test.en`.
```
$ head -n4 ./corpus/kftt-data-1.0/data/orig/kyoto-test.en
Infobox Buddhist
Dogen was a Zen monk in the early Kamakura period.
The founder of Soto Zen
Later in his life he also went by the name Kigen.
```

The current model mistranslated the name "Kigen" to "Legend" at line 4.
Also, "heterogeneous" is not an appropriate translation.
Let's see how this could be improved by fine-tuning.



## Contact
Please send an issue on GitHub or contact us by email.  

NTT Communication Science Laboratories  
Makoto Morishita  
jparacrawl-ml -a- hco.ntt.co.jp  