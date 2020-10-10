#! /bin/bash

#Script que actualiza los cambios en mis repositorios, y actualiza el contenido de mi página web.

make html

git add .
git commit -am "cambios"
git push

cd output/
git add .
git commit -am "cambiosweb"
git push
cd ..
