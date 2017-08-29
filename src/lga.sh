#!/bin/bash

echo "JOIN DBF WITH SHP"
for f in data/resources_unzip/Local\ Government\ Areas\ */Standard/*LGA_shp.dbf ; do
    b=`basename "$f" _shp.dbf`
    d=`dirname "$f"`
    if [ -e "${d}/${b}.tab" ] ; then
        echo "Skipping $f as ${d}/${b}.tab exists"
    else
        echo "$f"
        query="SELECT attr.LGA_PID AS LGA_PID, attr.DT_CREATE AS DT_CREATE, attr.DT_RETIRE AS DT_RETIRE, attr.LGA_NAME AS LGA_NAME, attr.ABB_NAME AS ABB_NAME, attr.DT_GAZETD AS DT_GAZETD, attr.STATE_PID AS STATE_PID, ST_Collect(poly.geometry) AS geometry FROM ${b}_POLYGON_shp poly LEFT JOIN \"${f}\".${b}_shp attr ON poly.LGA_PID = attr.LGA_PID GROUP BY attr.LGA_PID"
        ogr2ogr -f 'MapInfo File' -dialect 'sqlite' -sql "$query" "${d}/${b}.tab" "${d}/${b}_POLYGON_shp.shp"
    fi
done

echo "COMBINE STATES"
rm -f data/resources_unzip/Local\ Government\ Areas\ */Standard/LGA.shp
for f in data/resources_unzip/Local\ Government\ Areas\ */Standard/*.tab ; do
    b=`basename "${f}" .tab`
    d=`dirname "${f}"`
    echo "$d -> $b"

    if [ ! -e "${d}/LGA.shp" ] ; then
        ogr2ogr "${d}/LGA.shp" "${f}"
    else
        ogr2ogr -update -append "${d}/LGA.shp" "${f}" -nln LGA
    fi
done

echo "OUTPUTTING"
mkdir -p data/outputs/shp
for f in data/resources_unzip/Local\ Government\ Areas\ */Standard/LGA\.* ; do
    ext=`echo "${f}" | grep -o '\.[^\.]*$'`
    d=`dirname "${f}" | grep -o 'Local Government Areas [^/]*'`
    mv "${f}" "data/outputs/shp/${d}${ext}"
done
echo "data/outputs/shp"
