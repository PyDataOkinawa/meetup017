#!/bin/bash
#
# ====== How to use this script =====
# ./train_rnn basic_rnn 6007
#
# `basic_rnn` can be replaced by `lookback_rnn` or `attention_rnn`.
# `6007` is a port number for the TensorBoard. If the port number is omitted,
# this value is automatically set to `6006`.
# ===================================
#
# This script is inspired by  magenta/magenta/models/basic_rnn/run_basic_rnn_train.sh
# https://github.com/tensorflow/magenta/blob/master/magenta/models/basic_rnn/run_basic_rnn_train.sh

case ${OSTYPE} in
  linux*)
    # Docker
    MAGENTA_DIR=/magenta
    ;;
  darwin*)
    # Local
    MAGENTA_DIR=$HOME/git/magenta
    ;;
esac

RNN_TYPE=$1
if [ -n "$2" ]; then
  TB_PORT=$2
else
  TB_PORT=6006
fi

if [ $RNN_TYPE = basic_rnn ]; then
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[128,128]}"
elif [ $RNN_TYPE = lookback_rnn ]; then
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[128,128]}"
elif [ $RNN_TYPE = attention_rnn ]; then
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[128,128]}"
else
  echo "$RNN_TYPE is an invalid parameter. Use basic_rnn, lookback_rnn, or attention_rnn."
  exit 1
fi

NUM_TRAINING_STEPS=500

CURR_DIR=`pwd`
TMP_DIR=$CURR_DIR/tmp
MODEL_DIR=$TMP_DIR/$RNN_TYPE
LOG_DIR=$MODEL_DIR/logdir

# Get next run directory.
# http://stackoverflow.com/a/23961677
DATE=$(date +"%y%d%m")
N=1
# Increment $N as long as a directory with that name exists
while [[ -d "$LOG_DIR/$DATE-$N" ]] ; do
    N=$(($N+1))
done
RUN_DIR="$LOG_DIR/$DATE-$N"

# mkdir -p TMP_DIR

# TFRecord file containing NoteSequence protocol buffers from convert_midi_dir_to_note_sequences.py.
SEQUENCES_TFRECORD=$TMP_DIR/notesequences.tfrecord

# Where training and evaluation datasets will be written.
DATASET_DIR=$TMP_DIR/$RNN_TYPE/sequence_examples

# TFRecord file that TensorFlow's SequenceExample protos will be written to. This is the training dataset.
TRAIN_DATA=$DATASET_DIR/training_melodies.tfrecord

# Optional evaluation dataset. Also, a TFRecord file containing SequenceExample protos.
EVAL_DATA=$DATASET_DIR/eval_melodies.tfrecord

# Fraction of input data that will be written to the eval dataset (if eval_output flag is set).
EVAL_RATIO=0.10

cd $MAGENTA_DIR

if [ -d $DATASET_DIR ]; then
  echo "Using pre-existing datasets for training and evaluation..."
else
  echo "Creating datasets for training and evaluation..."

  bazel run //magenta/models/$RNN_TYPE:${RNN_TYPE}_create_dataset -- \
  --input=$SEQUENCES_TFRECORD \
  --output_dir=$DATASET_DIR \
  --eval_ratio=$EVAL_RATIO
fi

bazel build //magenta/models/${RNN_TYPE}:${RNN_TYPE}_train

echo "Start training the model..."

./bazel-bin/magenta/models/$RNN_TYPE/${RNN_TYPE}_train --run_dir=$RUN_DIR --sequence_example_file=$TRAIN_DATA --hparams=$HPARAMS --num_training_steps=$NUM_TRAINING_STEPS --eval=false &

./bazel-bin/magenta/models/$RNN_TYPE/${RNN_TYPE}_train --run_dir=$RUN_DIR --sequence_example_file=$EVAL_DATA --hparams=$HPARAMS --num_training_steps=$NUM_TRAINING_STEPS --eval=true &

tensorboard --logdir=$LOG_DIR --port $TB_PORT &
