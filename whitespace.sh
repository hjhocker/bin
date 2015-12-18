#!/bin/bash

items=
for i in "$@"
do
    items="$items \"$i\""
done

eval set -- $items
for i in "$@"
do
    echo $i
done
