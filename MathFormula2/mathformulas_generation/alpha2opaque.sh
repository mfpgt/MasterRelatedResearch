#! /bin/sh
find -name '*.png' -exec  mogrify -alpha opaque '{}' ';'
