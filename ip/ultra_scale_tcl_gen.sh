#!/bin/bash

# set -x
set -f
for i in $(find . -name '*.tcl'); do 
    echo "$i"
    num_sub_dir=$(echo "$i" | tr -cd '/' | wc -c)

    if [ "$num_sub_dir" -ne 2 ] || [[ "$i" =~ "_ultra_scale.tcl" ]]; then
        echo "skip"
        echo " "
    else
        if grep -q "xilinx.com:zc706:part0:1.4" "$i" && grep -q "xc7z045ffg900-2" "$i" ; then
            # echo $num_sub_dir
            string_len=$(echo "$i" | wc -c)
            filename_core=$(echo "$i" | cut -c1-$[$string_len-5])
            # echo $filename_core
            filename_new_ext="_ultra_scale.tcl"
            filename_new="$filename_core$filename_new_ext"
            cp "$i" $filename_new
            sed -i 's/xc7z045ffg900-2/xczu9eg-ffvb1156-2-e/g' $filename_new
            sed -i 's/"xilinx.com:zc706:part0:1.4"/"xilinx.com:zcu102:part0:3.1"/g' $filename_new
            echo $filename_new "is generated"
            echo " "
        else
            echo "skip1"
            echo " "
        fi
    fi

done