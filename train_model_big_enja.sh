#!/bin/bash
export PYTHONWARNINGS='ignore:semaphore_tracker:UserWarning'

FAIRSEQ=/workspace/fairseq

SEED=1

EXP_NAME=big_baseline_seed$SEED

SRC=en
TRG=ja

TRAIN_SRC=/host_disk/corpus/spm/32000/train.$SRC
TRAIN_TRG=/host_disk/corpus/spm/32000/train.$TRG
DEV_SRC=/host_disk/corpus/spm/32000/aspec-je.dev.$SRC
DEV_TRG=/host_disk/corpus/spm/32000/aspec-je.dev.$TRG
TEST_SRC=/host_disk/corpus/spm/32000/aspec-je.test.$SRC
TEST_TRG=/host_disk/corpus/spm/32000/aspec-je.test.$TRG
TEST_TRG_RAW=/corpus/aspec-je.test.$TRG

SPM_MODEL=/host_disk/corpus/spm/32000/spm_model/spm.$TRG.nopretok.model

CORPUS_DIR=/host_disk/train/$SRC-$TRG/corpus
MODEL_DIR=/host_disk/train/$SRC-$TRG/models/$EXP_NAME
DATA_DIR=/host_disk/train/$SRC-$TRG/data-bin/$EXP_NAME

TRAIN_PREFIX=$CORPUS_DIR/$EXP_NAME/train
DEV_PREFIX=$CORPUS_DIR/$EXP_NAME/dev
TEST_PREFIX=$CORPUS_DIR/$EXP_NAME/test

mkdir -p $CORPUS_DIR
mkdir -p $MODEL_DIR
mkdir -p $DATA_DIR

# make links to corpus
mkdir -p $CORPUS_DIR/$EXP_NAME
ln -s $TRAIN_SRC $TRAIN_PREFIX.$SRC
ln -s $TRAIN_TRG $TRAIN_PREFIX.$TRG
ln -s $DEV_SRC $DEV_PREFIX.$SRC
ln -s $DEV_TRG $DEV_PREFIX.$TRG
ln -s $TEST_SRC $TEST_PREFIX.$SRC
ln -s $TEST_TRG $TEST_PREFIX.$TRG

######################################
# Preprocessing
######################################
python3 $FAIRSEQ/fairseq_cli/preprocess.py \
    --source-lang $SRC \
    --target-lang $TRG \
    --trainpref $TRAIN_PREFIX \
    --validpref $DEV_PREFIX \
    --testpref $TEST_PREFIX \
    --destdir $DATA_DIR \
    --nwordssrc -1 \
    --nwordstgt -1 \
    --workers `nproc` \


######################################
# Training
######################################
python3 $FAIRSEQ/train.py $DATA_DIR \
    --arch transformer_wmt_en_de_big \
    --optimizer adam \
    --adam-betas '(0.9, 0.98)' \
    --clip-norm 1.0 \
    --lr-scheduler inverse_sqrt \
    --warmup-init-lr 1e-07 \
    --warmup-updates 4000 \
    --lr 0.001 \
    --dropout 0.3 \
    --weight-decay 0.0 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-tokens 4000 \
    --max-update 100000 \
    --save-dir $MODEL_DIR \
    --no-epoch-checkpoints \
    --save-interval 10000000000 \
    --validate-interval 1000000000 \
    --save-interval-updates 200 \
    --keep-interval-updates 8 \
    --log-format simple \
    --log-interval 5 \
    --ddp-backend no_c10d \
    --update-freq 4 \
    --fp16 \
    --seed $SEED \


######################################
# Generate
######################################
# decode
B=`basename $TEST_SRC`

python3 $FAIRSEQ/fairseq_cli/generate.py $DATA_DIR \
    --gen-subset test \
    --path $MODEL_DIR/checkpoint_best.pt \
    --max-tokens 1000 \
    --beam 6 \
    --lenpen 1.0 \
    --log-format simple \
    --remove-bpe \
    | tee $MODEL_DIR/$B.hyp

grep "^H" $MODEL_DIR/$B.hyp | sed 's/^H-//g' | sort -n | cut -f3 > $MODEL_DIR/$B.true
cat $MODEL_DIR/$B.true | spm_decode --model=$SPM_MODEL --input_format=piece > $MODEL_DIR/$B.true.detok

# evaluation
cat $MODEL_DIR/$B.true.detok | \
    perl -Mutf8 -pe 's/(.)［[０-９．]+］$/${1}/;' | \
    sh /workspace/scripts/remove-space.sh | \
    perl /workspace/scripts/h2z-utf8-without-space.pl | \
    perl -Mutf8 -pe 'while(s/([０-９]) ([０-９])/$1$2/g){} s/([０-９]) (．) ([０-９])/$1$2$3/g; while(s/([Ａ-Ｚ]) ([Ａ-Ｚａ-ｚ])/$1$2/g){} while(s/([ａ-ｚ]) ([ａ-ｚ])/$1$2/g){} s/ $//;' \
    > $MODEL_DIR/$B.true.detok.normalized
cat $MODEL_DIR/$B.true.detok.normalized | sacrebleu -l $SRC-$TRG $TEST_TRG_RAW | tee -a $MODEL_DIR/test.log
