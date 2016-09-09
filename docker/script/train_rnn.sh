#!/bin/bash
echo "Start training the model..."

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
RUN_DIR=$LOG_DIR/run1

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

bazel run //magenta/models/$RNN_TYPE:${RNN_TYPE}_create_dataset -- \
--input=$SEQUENCES_TFRECORD \
--output_dir=$DATASET_DIR \
--eval_ratio=$EVAL_RATIO

./bazel-bin/magenta/models/$RNN_TYPE/${RNN_TYPE}_train --run_dir=$RUN_DIR --sequence_example_file=$TRAIN_DATA --hparams=$HPARAMS --num_training_steps=$NUM_TRAINING_STEPS &

./bazel-bin/magenta/models/$RNN_TYPE/${RNN_TYPE}_train --run_dir=$RUN_DIR --sequence_example_file=$EVAL_DATA --hparams=$HPARAMS --num_training_steps=$NUM_TRAINING_STEPS --eval &

tensorboard --logdir=$LOG_DIR --port $TB_PORT &
