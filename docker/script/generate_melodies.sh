#!/bin/bash
echo "Start generating melodies..."

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

# Provide a MIDI file to use as a primer for the generation.
# The MIDI should just contain a short monophonic melody.
# primer.mid is provided as an example.
PRIMER_PATH=$MAGENTA_DIR/magenta/models/shared/primer.mid

RNN_TYPE=$1

if [ $RNN_TYPE = basic_rnn ]; then
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[32,32]}"
elif [ $RNN_TYPE = lookback_rnn ]; then
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[32,32]}"
elif [ $RNN_TYPE = attention_rnn ]; then
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[32,32]}"
else
  echo "$RNN_TYPE is an invalid parameter. Use basic_rnn, lookback_rnn, or attention_rnn."
  exit 1
fi

CURR_DIR=`pwd`
TMP_DIR=$CURR_DIR/tmp
MODEL_DIR=$TMP_DIR/$RNN_TYPE
LOG_DIR=$MODEL_DIR/logdir
RUN_DIR=$LOG_DIR/run1
OUTPUT_DIR=$MODEL_DIR/generated

cd $MAGENTA_DIR

bazel run //magenta/models/$RNN_TYPE:${RNN_TYPE}_generate -- \
--run_dir=$RUN_DIR \
--hparams=$HPARAMS \
--output_dir=$OUTPUT_DIR \
--num_outputs=5 \
--num_steps=512 \
--primer_midi=$PRIMER_PATH
#--primer_melody="[60]"
