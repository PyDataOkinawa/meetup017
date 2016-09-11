#!/bin/bash
#
# ====== How to use this script =====
# Default usage:
#
# ./train_rnn.sh
#
# Custom usage:
#
# ./train_rnn.sh -t output/beatles -r basic_rnn -p 6007 \
# -h "{'batch_size':32,'rnn_layer_sizes':[128,128]}"
#
# -t, --tmpdir: a name of the tmp directory created under the current directory
#   default: tmp
# -r, --rnntype: a type of recurrent network
#   possible values: {basic_rnn, lookback_rnn, attention_rnn}
#   default: basic_rnn
# -p, --port: a port number for the TensorBoard.
#   default: 6006
# -h, --hparams: hyperparameters
#   default: "{'batch_size':32,'rnn_layer_sizes':[128,128]}"
# ===================================
#
# This script is inspired by  magenta/magenta/models/basic_rnn/run_basic_rnn_train.sh
# https://github.com/tensorflow/magenta/blob/master/magenta/models/basic_rnn/run_basic_rnn_train.sh

CURR_DIR=`pwd`

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

# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -t|--tmpdir)
    TMP_DIR="$2"
    shift # past argument
    ;;
    -r|--rnntype)
    RNN_TYPE="$2"
    shift # past argument
    ;;
    -p|--port)
    TB_PORT="$2"
    shift # past argument
    ;;
    -h|--hparams)
    HPARAMS="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

# Create the tmp directory under the current directory
if [ -z "$TMP_DIR" ]; then
  # Use the default directory name
  TMP_DIR=$CURR_DIR/tmp
else
  # Use the user-specified directory name
  TMP_DIR=$CURR_DIR/$TMP_DIR
fi

if [ -z "$RNN_TYPE" ]; then
  # Use basic_rnn as a default models
  RNN_TYPE=basic_rnn
fi

if [ -z "$TB_PORT" ]; then
  # Use the default port number 6006
  TB_PORT=6006
fi

if [ -z "$HPARAMS" ]; then
  # Use the default value for the hyperparameter
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[128,128]}"
fi

NUM_TRAINING_STEPS=500

CURR_DIR=`pwd`
MODEL_DIR=$TMP_DIR/$RNN_TYPE
LOG_DIR=$MODEL_DIR/logdir

# Get next run directory.
# http://stackoverflow.com/a/23961677
DATE=$(date +"%y%m%d")
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

tensorboard --logdir=$LOG_DIR --port=$TB_PORT &
