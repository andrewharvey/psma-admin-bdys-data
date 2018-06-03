#!/bin/sh

find data/outputs/shp -iname "*.shp" | while read f
do
    b=`basename "$f" '.shp'`
    TABLE_NAME=`echo $b | sed -E 's/[ -]+/_/g' | tr 'A-Z' 'a-z'`
    echo "$TABLE_NAME"
    shp2pgsql -dI "$f" "psma_$TABLE_NAME" | psql
done
