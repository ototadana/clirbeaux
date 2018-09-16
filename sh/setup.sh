#!/bin/sh
set -e

BASE_DIR=$(cd $(dirname $0)/..; pwd)
cd $BASE_DIR

cp ./config/index.html.template ./config/index.html
cp ./config/index.js.template ./config/index.js
cp ./config/file-type.yml.template ./config/file-type.yml
cp ./config/project.yml.template ./config/project.yml
