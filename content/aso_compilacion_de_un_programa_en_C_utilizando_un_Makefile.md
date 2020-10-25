Title: Compilación de un programa en C utilizando un Makefile
Date: 2020/10/24
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: compilar, gcc, C, Makefile

## Descripción

**Elige el programa escrito en C que prefieras y comprueba en las fuentes que exista un fichero Makefile para compilarlo.**

**Realiza los pasos necesarios para compilarlo e instálalo en tu equipo en un directorio que no interfiera con tu sistema de paquetes (/opt, /usr/local, etc.)**

**La corrección se hará en clase y deberás ser capaz de explicar qué son todos los ficheros que se hayan instalado y realizar una desinstalación limpia.**

Como introducción, veo necesario explicar que significa la palabra *compilar* y en qué consiste el proceso que voy a realizar.

Cuando nos referimos en términos informáticos a compilar un programa, a lo que nos estamos refiriendo, es a realizar una traducción del código fuente del programa, a un código ejecutable por un sistema. Esta traducción la lleva a cabo una herramienta de software llamada **compilador**.

**¿Qué es el código fuente del programa?** Pues son las líneas de código que forman el programa y están escritas en un lenguaje de programación. Este código escrito en un lenguaje de programación, no puede ser ejecutado por un sistema, ya que el sistema solo entiende su lenguaje binario.

**¿Qué es un compilador?** Es el programa encargado de hacer la traducción del código fuente de un programa, creado a través de un lenguaje de programación, a lenguaje de máquina o binario, que es el tipo de lenguaje que entienden los procesadores.

He decidido elegir el programa **wget**, escrito en **C**, para compilarlo e instalarlo en mi equipo.

El primer paso sería descargarlo. Para ello nos dirigimos a la [página de Debian](https://www.debian.org/distrib/packages) y lo buscamos por su nombre. Si entramos en la [información del paquete](https://packages.debian.org/buster/wget), podemos ver en qué lenguaje está escrito, paquetes similares, paquetes relacionados, bugs, ...

Para descargar el paquete, nos dirigimos al apartado de la [fuente del paquete](https://packages.debian.org/source/buster/wget), y aquí nos descargamos el archivo que prefiramos, en mi caso voy a descargar [este](http://deb.debian.org/debian/pool/main/w/wget/wget_1.20.1.orig.tar.gz).

Es importante, descargarlo en la ruta `/usr/local` para que no interfiera con el sistema de paquetes. Lo descomprimimos:

<pre>
tar -xf wget_1.20.1.orig.tar.gz
</pre>

Vemos que nos ha generado una serie de ficheros y directorios, entre los cuáles se encuentran los archivos ***README*** y ***INSTALL***. Es bastante recomendable leerlos antes de saltar al siguiente paso, ya que contienen información e instrucciones que nos resultarán bastantes útiles. Si no me equivoco, pero digo desde ya que no estoy seguro, hay algunos paquetes que no contienen estos archivos, pero son una gran minoría.

Es necesario revisar que tenemos instalado el paquete `build-essential` y todas sus dependencias. Este paquete incluye todo lo necesario a la hora de compilar. Se trata de un paquete que contiene una lista informativa de los paquetes que se consideran esenciales para la creación de paquetes Debian. Para instalarlo:

<pre>
apt install build-essential -y
</pre>

Voy a instalar el paquete `pkg-config` que es un sistema para gestionar las opciones de compilación y enlazado de las bibliotecas, funciona con automake y autoconf. Su funcionamiento consiste en llamar a bibliotecas instaladas cuando se está compilando un programa a partir del código fuente.

<pre>
apt install pkg-config -y
</pre>

Por último vamos a instalar el paquete `libgnutls28-dev`. GnuTLS es una biblioteca portátil que implementa los protocolos *Transport Layer Security* y *Datagram Transport Layer Security*.

<pre>
apt install libgnutls28-dev -y
</pre>

En este punto, ya lo tenemos todo listo para empezar la compilación del paquete `wget` que queremos instalar. Ahora solo nos queda

<pre>
./configure
make
make install
whereis wget
</pre>

<pre>
make uninstall
</pre>
