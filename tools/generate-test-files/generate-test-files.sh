#!/bin/sh

NUMBER_OF_FILES=${1:-10}
for i in $(seq 1 $NUMBER_OF_FILES);
do
    cp -r "reference" "file-$i"
    XML_FILE=`ls "file-$i" | grep "^[0-9A-F].*"`
    sed -i "s/<sanco-xmlgate:cpnpReference>.*<\/sanco-xmlgate:cpnpReference>/<sanco-xmlgate:cpnpReference>100000$i<\/sanco-xmlgate:cpnpReference>/" "file-$i/$XML_FILE"
    grep -o "<sanco-xmlgate:cpnpReference>.*</sanco-xmlgate:cpnpReference>" "file-$i/$XML_FILE"
    zip -r "file-$i.zip" "file-$i"
    rm -rf "file-$i"
done
