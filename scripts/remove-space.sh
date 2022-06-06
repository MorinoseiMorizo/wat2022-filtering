#!/bin/sh

cat /dev/stdin | \
  perl -Mutf8 -pe 's/　/ /g; s/ +/ /g; while( s/([^Ａ-Ｚａ-ｚA-Za-z]|^) ([^Ａ-Ｚａ-ｚA-Za-z]|$)/${1}${2}/g ){}'
