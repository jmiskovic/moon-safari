#!/usr/bin/sh
rm -f ./game.lovr
zip --no-dir-entries game.lovr ./*
mv game.lovr docs/
