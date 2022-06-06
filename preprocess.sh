#!/bin/sh

SRC=en
TRG=ja

# SPM
mkdir -p detok
for MERGE in 32000; do
    mkdir -p /host_disk/corpus/spm/$MERGE/spm_model
    spm_train --input=/corpus/train.en --model_prefix=/host_disk/corpus/spm/$MERGE/spm_model/spm.en.nopretok --vocab_size=$MERGE --character_coverage=1.0 --model_type=unigram --normalization_rule_name=nmt_nfkc --train_extremely_large_corpus=True
    spm_train --input=/corpus/train.ja --model_prefix=/host_disk/corpus/spm/$MERGE/spm_model/spm.ja.nopretok --vocab_size=$MERGE --character_coverage=1.0 --model_type=unigram --normalization_rule_name=nmt_nfkc --train_extremely_large_corpus=True
    wait
    for L in $SRC $TRG; do
        for FILE in /corpus/*.$L; do
            BASE=`basename $FILE`
            spm_encode --model=/host_disk/corpus/spm/$MERGE/spm_model/spm.$L.nopretok.model --output_format=piece < $FILE > /host_disk/corpus/spm/$MERGE/$BASE &
        done
    done
    wait
done
