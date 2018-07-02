#!/bin/bash

for mode in disabled 2d viewport; do
  for aspect in ignore keep keep_width keep_height expand; do
    output_file=${mode}_${aspect}.gif
    echo $output_file
    convert -repage 440x274+10+10 -background '#008080' -dispose Previous -delay 25 -loop 0 -layers Optimize ${mode}_${aspect}_??.png $output_file
  done
done
