#!/bin/bash


echo "JOIN DBF WITH SHP"
joinDbfShp() {
    f="$1"

    declare -A profile_lookup
    profile_lookup=( [STATE_ELECTORAL]="SE" \
                     [COMM_ELECTORAL]="CE" \
                     [LGA]="LGA" \
                     [WARD]="WARD" \
                     [STATE]="STATE" \
                     [LOCALITY]="LOC" \
                     [TOWN]="TOWN" )

    declare -A attr
    attr=( [SE]="DT_CREATE DT_RETIRE NAME DT_GAZETD EFF_START EFF_END STATE_PID SECL_CODE" \
           [CE]="DT_CREATE DT_RETIRE NAME DT_GAZETD STATE_PID REDISTYEAR" \
           [LGA]="DT_CREATE DT_RETIRE LGA_NAME ABB_NAME DT_GAZETD STATE_PID" \
           [WARD]="DT_CREATE DT_RETIRE NAME DT_GAZETD LGA_PID STATE_PID" \
           [STATE]="DT_CREATE DT_RETIRE STATE_NAME ST_ABBREV" \
           [LOC]="DT_CREATE DT_RETIRE NAME POSTCODE PRIM_PCODE LOCCL_CODE DT_GAZETD STATE_PID" \
           [TOWN]="DATE_CREAT DATE_RETIR TOWN_CLASS TOWN_NAME POPULATION STATE_PID" )

    declare -A geom_type
    geom_type=( [SE]="POLYGON" \
                [CE]="POLYGON" \
                [LGA]="POLYGON" \
                [WARD]="POLYGON" \
                [STATE]="POLYGON" \
                [LOC]="POLYGON" \
                [TOWN]="POINT" )

    b=`basename "$f" _shp.dbf`
    if [ `echo "$b" | grep --count -E '^(ACT|NSW|NT|OT|QLD|SA|TAS|VIC|WA)_(COMM_ELECTORAL|LGA|LOCALITY|STATE|STATE_ELECTORAL|TOWN|WARD)$' -` -gt 0 ] ; then
        profile_name=`echo "$b" | cut -d'_' -f2-`
        profile=${profile_lookup[$profile_name]}
        d=`dirname "$f"`
        if [ -e "${d}/${b}.tab" ] ; then
            echo "Skipping $f as ${d}/${b}.tab exists"
        else
            echo "$f"
            attr_selects=""
            for a in ${attr[$profile]}; do
                attr_selects="$attr_selects, attr.$a AS $a"
            done
            query="SELECT attr.${profile}_PID AS ${profile}_PID ${attr_selects}, ST_Collect(poly.geometry) AS geometry FROM ${b}_${geom_type[$profile]}_shp poly LEFT JOIN \"${f}\".${b}_shp attr ON poly.${profile}_PID = attr.${profile}_PID GROUP BY attr.${profile}_PID"
            ogr2ogr -f 'MapInfo File' -dialect 'sqlite' -sql "$query" "${d}/${b}.tab" "${d}/${b}_${geom_type[$profile]}_shp.shp"
        fi
    fi
}
export -f joinDbfShp
ls -1 data/resources_unzip/*/Standard/*_shp.dbf | parallel joinDbfShp {}

echo "COMBINE STATES"
rm -f data/resources_unzip/*/Standard/AUST.shp
for f in data/resources_unzip/*/Standard/*.tab ; do
    b=`basename "${f}" .tab`
    d=`dirname "${f}"`
    echo "$d -> $b"

    if [ ! -e "${d}/AUST.shp" ] ; then
        ogr2ogr "${d}/AUST.shp" "${f}"
    else
        ogr2ogr -update -append "${d}/AUST.shp" "${f}" -nln AUST
    fi
    rm -f "${d}/${b}.tab" "${d}/${b}.dat" "${d}/${b}.id" "${d}/${b}.map"
done

echo "OUTPUTTING"
mkdir -p data/outputs/shp
for f in data/resources_unzip/*/Standard/AUST\.* ; do
    ext=`echo "${f}" | grep -o '\.[^\.]*$'`
    d=`dirname "${f}" | cut -d'/' -f3`
    mv "${f}" "data/outputs/shp/${d}${ext}"
done
echo "data/outputs/shp"
