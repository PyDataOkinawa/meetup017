#!/bin/bash
MIDI_DIR=$HOME/dataset/midi/beatles

case ${OSTYPE} in
  linux*)
    # Docker
    MIDI_DIR=/magenta-data/midi/beatles
    ;;
  darwin*)
    # Local
    MIDI_DIR=$(dirname `pwd`)/midi/beatles
    ;;
esac

TMP_DIR=output/beatles

# ----- basic_rnn -----
RNN_TYPE=basic_rnn
TB_PORT=6007
# ----- lookback_rnn -----
#RNN_TYPE=lookback_rnn
#TB_PORT=6008
# ----- attention_rnn -----
#RNN_TYPE=attention_rnn
#TB_PORT=6009

HPARAMS="{'batch_size':32,'rnn_layer_sizes':[128,128]}"

if [ -d ./${TMP_DIR} ]; then
  echo "Use pre-existing NoteSequences."
else
  ./build_dataset.sh \
  --tmpdir ${TMP_DIR} \
  --mididir ${MIDI_DIR}
fi

./train_rnn.sh \
--tmpdir ${TMP_DIR} \
--rnntype ${RNN_TYPE} \
--port ${TB_PORT} \
--hparams ${HPARAMS}

#./generate_melodies.sh -t output/beatles -r basic_rnn -n 160909-1

#tensorboard --logdir=output/beatles/basic_rnn/logdir --port=6007
