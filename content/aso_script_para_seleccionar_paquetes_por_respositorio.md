Title: Script para seleccionar paquetes por repositorio
Date: 2020/10/16
Category: Administración de Sistemas Operativos

## Descripción

**Realiza un script que introduciéndolo como parámetro el nombre de un repositorio, muestre como salida los paquetes de ese repositorio que están instalados en la máquina. Por ejemplo:**

**./script.sh security.debian.org**

**O también debe aceptar:**

**./script.sh http://security.debian.org**

**Se valorará:**

- **La rapidez de ejecución**
- **La simpleza del código**
- **La legibilidad**
- **La portabilidad**

He realizado este script:

<pre>
#! /bin/bash

# Script que introduciéndole como parámetro el nombre de un repositorio, muestra como salida los paquetes de ese repositorio que están instalados en la máquina.

repositorio=$1

for paquete in $(dpkg --get-selections | awk '{ print $1  }')
do
 salida=`apt-cache policy $paquete | grep -A 1 '[***]' | grep 'http:' | awk '{ print $2 }'`
 if [[ $salida == *$1* ]]
 then
        echo $paquete;
 fi
done
</pre>
