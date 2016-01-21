#!/bin/bash

set -e
set -o pipefail

fps=24
scale=240

ffmpeg -y -i ${1} -vf fps=$fps,scale=$scale:-1:flags=lanczos,palettegen palette.png
ffmpeg -i ${1} -i palette.png -filter_complex "fps=$fps,scale=$scale:-1:flags=lanczos[x];[x][1:v]paletteuse" out_${scale}_${fps}.gif
