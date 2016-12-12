#!/bin/bash
#
# ====== How to use this script =====
# Default usage:
#
# ./build_dataset.sh
#
# Custom usage:
#
# ./build_dataset.sh -t output/beatles -m /magenta-data/midi/beatles
#
# -t, --tmpdir: a name of the tmp directory created under the current directory
# -m, --mididir: a path of the midi directory
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
    -m|--mididir)
    MIDI_DIR="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo "Start generating dataset..."

case ${OSTYPE} in
  linux*)
    # Docker
    MAGENTA_DIR=/magenta
    if [ -z "$MIDI_DIR" ]; then
      MIDI_DIR=/magenta-data/midi
    fi
    ;;
  darwin*)
    # Local
    MAGENTA_DIR=$HOME/git/magenta
    if [ -z "$MIDI_DIR" ]; then
      MIDI_DIR=$(dirname `pwd`)/midi
    fi
    ;;
esac

# Create the tmp directory under the current directory
if [ -n "$TMP_DIR" ]; then
  TMP_DIR=$CURR_DIR/$TMP_DIR
else
  TMP_DIR=$CURR_DIR/tmp
fi

mkdir -p $TMP_DIR

# TFRecord file that will contain NoteSequence protocol buffers.
SEQUENCES_TFRECORD=$TMP_DIR/notesequences.tfrecord

convert_midi_dir_to_note_sequences \
    --midi_dir=$MIDI_DIR \
    --output_file=$SEQUENCES_TFRECORD \
    --recursive
