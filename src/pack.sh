#!/bin/bash


pack() {
    f="$1"
    b=`basename "$f" .shp`
    echo "$f -> $b ($FORMAT)"
    case "$FORMAT" in
        xz)
            mkdir -p data/outputs/xz
            tar -cJf "data/outputs/xz/${b}.tar.xz" "data/outputs/shp/${b}"*
            ;;
        *)
            mkdir -p data/outputs/zip
            zip --junk-paths "data/outputs/zip/${b}.zip" "data/outputs/shp/${b}"*
            ;;
    esac
}
export -f pack
export FORMAT="$1"
ls -1 data/outputs/shp/*.shp | parallel pack {}
