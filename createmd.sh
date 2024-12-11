#!/bin/bash

if [ -z "$1" ]
then
  echo "EX: $0 input-post-name.md"
  exit 1
fi

post="post/"$(date +"%Y/%m")"/"$1
echo $post
echo `hugo new ${post}`
