#!/bin/bash
echo "Start iniitalizing MIDI Interface"

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

CURR_DIR=`pwd`
TMP_DIR=$CURR_DIR/tmp

RNN_TYPE=$1

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

cd $MAGENTA_DIR

# List all available ports
bazel-bin/magenta/interfaces/midi/midi --list

bazel-bin/magenta/interfaces/midi/midi \
--input_port="VMPK Output" \
--output_port="VMPK Input" \
--generator_name=$RNN_TYPE \
--checkpoint=$TMP_DIR/$RNN_TYPE/logdir/run1/train \
--hparams=$HPARAMS
