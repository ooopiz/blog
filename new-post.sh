#!/bin/bash

if [ -z "$1" ]
then
    echo "EX: ./new-post input-post-name.md"
    exit
fi

post="post/"$(date +"%Y/%m")"/"$1
echo $post
echo `hugo new ${post}`
