#!/bin/sh

pack() {
    f="$1"
    b=`basename "$f" .shp`
    echo "$f -> $b"
    #zip "data/outputs/shp/${b}.zip" "data/outputs/shp/${b}"*
    tar -cJf "data/outputs/shp/${b}.tar.xz" "data/outputs/shp/${b}"*
}
export -f pack
ls -1 data/outputs/shp/*.shp | parallel pack {}
