#!/bin/bash
echo "Start generating dataset..."

case ${OSTYPE} in
  linux*)
    # Docker
    MAGENTA_DIR=/magenta
    MIDI_DIR=/magenta-data/midi
    ;;
  darwin*)
    # Local
    MAGENTA_DIR=$HOME/git/magenta
    MIDI_DIR=$(dirname `pwd`)/midi
    ;;
esac

CURR_DIR=`pwd`
TMP_DIR=$CURR_DIR/tmp
mkdir -p $TMP_DIR

cd $MAGENTA_DIR

# TFRecord file that will contain NoteSequence protocol buffers.
SEQUENCES_TFRECORD=$TMP_DIR/notesequences.tfrecord

bazel run //magenta/scripts:convert_midi_dir_to_note_sequences -- \
--midi_dir=$MIDI_DIR \
--output_file=$SEQUENCES_TFRECORD \
--recursive
