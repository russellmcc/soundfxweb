#!/bin/bash
rm -rf publish/
./build.sh
git clone -b gh-pages git@github.com:russellmcc/soundfxweb.git publish
cd publish/
rm -rf *
cp -R ../build/*
git add *
git commit -m "publishing"
git push
cd ..
rm -rf  publish
