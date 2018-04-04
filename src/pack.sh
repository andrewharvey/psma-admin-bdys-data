#!/bin/bash

pack() {
    f="$1"
    b=`basename "$f" .shp`
    echo "$f -> $b ($FORMAT)"
    case "$FORMAT" in
        xz)
            tar -cJf "data/outputs/shp/${b}.tar.xz" "data/outputs/shp/${b}"*
            ;;
        *)
            zip --junk-paths "data/outputs/shp/${b}.zip" "data/outputs/shp/${b}"*
            ;;
    esac
}
export -f pack
export FORMAT="$1"
ls -1 data/outputs/shp/*.shp | parallel pack {}
