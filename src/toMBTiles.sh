#!/bin/bash

declare -A select

select=(
    ['Suburbs - Localities']="NAME,STATE_PID"
    ['Local Government Areas']="LGA_NAME,ABB_NAME,STATE_PID"
)

mkdir -p data/outputs/mbtiles
find data/outputs/shp -iname "*.shp" | while read f
do
    b=`basename "$f" '.shp'`
    dataset=`echo "$b" | sed -E 's/ [A-Z]* [0-9]*$//'`
    if [[ -v select[$dataset] ]] ; then
        echo "$b"
        ogr2ogr -f 'GeoJSON' -t_srs 'EPSG:4326' -select "${select[$dataset]}" /vsistdout/ "$f" | \
            tippecanoe --force -o "data/outputs/mbtiles/$b.mbtiles" -l "$dataset" -Z0 -z14 --detect-shared-borders --generate-ids
    fi
done
