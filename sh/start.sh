#!/bin/sh
set -e

BASE_DIR=$(cd $(dirname $0)/..; pwd)
cd $BASE_DIR

./node_modules/.bin/gulp
node config/index.js
