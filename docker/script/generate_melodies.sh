#!/bin/bash
#
# ====== How to use this script =====
# ./generate_melodies.sh basic_rnn 160909-1
#
# `basic_rnn` can be replaced by `lookback_rnn` or `attention_rnn`.
# `160909-1` is a name of the log director with your trained model.
# ===================================

CURR_DIR=`pwd`

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
    -n|--runname)
    RUN_NAME="$2"
    shift # past argument
    ;;
    -h|--hparams)
    HPARAMS="$2"
    shift # past argument
    ;;
    --default)
    DEFAULT=YES
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

if [ -z "$RUN_NAME" ]; then
  echo "RUN_NAME should be specified."
  exit 1
fi

if [ -z "$TB_PORT" ]; then
  # Use the default port number 6006
  TB_PORT=6006
fi

if [ -z "$HPARAMS" ]; then
  # Use the default value for the hyperparameter
  HPARAMS="{'batch_size':32,'rnn_layer_sizes':[128,128]}"
fi

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

MODEL_DIR=$TMP_DIR/$RNN_TYPE
LOG_DIR=$MODEL_DIR/logdir
RUN_DIR=$LOG_DIR/$RUN_NAME
OUTPUT_DIR=$MODEL_DIR/generated/$RUN_NAME


echo "TMP_DIR = " $TMP_DIR

cd $MAGENTA_DIR

bazel run //magenta/models/${RNN_TYPE}:${RNN_TYPE}_generate -- \
--run_dir=$RUN_DIR \
--hparams=$HPARAMS \
--output_dir=$OUTPUT_DIR \
--num_outputs=5 \
--num_steps=512
#--primer_midi=${PRIMER_PATH}
#--primer_melody="[60]"
