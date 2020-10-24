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
