#!/bin/sh -e
echo 'building self esteem ...'
rm -f build.tar.gz
./node_modules/.bin/coffee ./src/build/server.coffee --build $@
#./node_modules/.bin/brunch build --minify $@
# copy localStorage fallback
#cp ./node_modules/store/store+json2.min.js ./brunch/build/web/js/store.js
#echo 'packing bits of awesomeness...'
#rm -f build.tar.gz
#( cd brunch/build && tar cpzf ../../build.tar.gz * )
echo 'done.'
