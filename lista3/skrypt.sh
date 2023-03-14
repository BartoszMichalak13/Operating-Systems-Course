#!bin/sh

for f in *[[:upper:]]*;
do mv -i -- "$f" "${f,,}"
done;