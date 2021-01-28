#!/bin/bash

if [ -z "$1" ]
then
    echo "Please input post md name!"
    exit
fi

post="post/"$(date +"%Y/%m")"/"$1
echo $post
echo `hugo new ${post}`
