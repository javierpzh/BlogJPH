#! /bin/bash

make html

git add .
git commit -am "cambios"
git push

cd output/
git add .
git commit -am "cambiosweb"
git push
cd ..
