Title: Compilación de un kérnel linux a medida
Date: 2020/11/4
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: compilar, kernel

## Compilación de un kérnel linux a medida

**Al ser linux un kérnel libre, es posible descargar el código fuente, configurarlo y comprimirlo. Además, esta tarea a priori compleja, es más sencilla de lo que parece gracias a las herramientas disponibles.**

**En esta tarea debes tratar de compilar un kérnel completamente funcional que reconozca todo el hardware básico de tu equipo y que sea a la vez lo más pequeño posible, es decir que incluya un vmlinuz lo más pequeño posible y que incorpore sólo los módulos imprescindibles. Para ello utiliza el método explicado en clase y entrega finalmente el fichero `deb` con el kérnel compilado por ti.**

**El hardware básico incluye como mínimo el teclado, la interfaz de red y la consola gráfica (texto).**

### Procedimiento a seguir

**1. Instala el paquete linux-source correspondiente al núcleo que estés usando en tu máquina**

Voy a instalar el paquete `linux-image-4.19.0-12-amd64` que corresponde al kérnel **4.19.0-12**.

Lo he descargado desde la [página oficial de Debian](https://packages.debian.org/buster/linux-source-4.19), desde este [enlace](http://security.debian.org/debian-security/pool/updates/main/l/linux/linux_4.19.152.orig.tar.xz).

**2. Crea un directorio de trabajo (p.ej. mkdir ~/Linux)**

<pre>
mkdir ~/kernelLinux/
</pre>

**3. Descomprime el código fuente del kérnel dentro del directorio de trabajo:**

<pre>
tar xf /usr/src/linux-source-... ~/Linux/
</pre>

Descargo y descomprimo el kérnel:

<pre>
root@buster:/usr/src# wget http://security.debian.org/debian-security/pool/updates/main/l/linux/linux_4.19.152.orig.tar.xz
--2020-11-04 08:23:20--  http://security.debian.org/debian-security/pool/updates/main/l/linux/linux_4.19.152.orig.tar.xz
Resolving security.debian.org (security.debian.org)... 151.101.64.204, 151.101.128.204, 151.101.192.204, ...
Connecting to security.debian.org (security.debian.org)|151.101.64.204|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 107539124 (103M) [application/x-xz]
Saving to: ‘linux_4.19.152.orig.tar.xz’

linux_4.19.152.orig.tar.x 100%[=====================================>] 102.56M  3.95MB/s    in 21s     

2020-11-04 08:23:41 (4.78 MB/s) - ‘linux_4.19.152.orig.tar.xz’ saved [107539124/107539124]

root@buster:/usr/src# ls
linux_4.19.152.orig.tar.xz

root@buster:/usr/src# cd

root@buster:~# tar xf /usr/src/linux_4.19.152.orig.tar.xz --directory ~/kernelLinux/

root@buster:~# cd kernelLinux/

root@buster:~/kernelLinux# ls
linux-4.19.152

root@buster:~/kernelLinux# cd linux-4.19.152/

root@buster:~/kernelLinux/linux-4.19.152# ls
arch   COPYING	Documentation  fs	ipc	 kernel    MAINTAINERS	net	 scripts   tools
block  CREDITS	drivers        include	Kbuild	 lib	   Makefile	README	 security  usr
certs  crypto	firmware       init	Kconfig  LICENSES  mm		samples  sound	   virt
</pre>


**4. Utiliza como punto de partida la configuración actual del núcleo:**

<pre>
make oldconfig
</pre>

**5. Cuenta el número de componentes que se han configurado para incluir en vmlinuz o como módulos.**



**6. Configura el núcleo en función de los módulos que está utilizando tu equipo (para no incluir en la compilación muchos controladores de dispositivos que no utiliza el equipo):**

<pre>
make localmodconfig
</pre>

**7. Vuelve a contar el número de componentes que se han configurado para incluir en vmlinuz o como módulos.**



**8. Realiza la primera compilación:**

<pre>
make -j <número de hilos> bindeb-pkg
</pre>

**9. Instala el núcleo resultando de la compilación, reinicia el equipo y comprueba que funciona adecuadamente.**



**10. Si ha funcionado adecuadamente, utilizamos la configuración del paso anterior como punto de partida y vamos a reducir el tamaño del mismo, para ello vamos a seleccionar elemento a elemento.**

<pre>
cp /boot/config-... .config
make clean
make xconfig
</pre>

**11. Vuelve a contar el número de componentes que se han configurado para incluir en vmlinuz o como módulos.**



**12. Vuelve a compilar:**

<pre>
make -j <número de hilos> bindeb-pkg
</pre>

**13. Si se produce un error en la compilación, vuelve al paso de configuración, si la compilación termina correctamente, instala el nuevo núcleo y comprueba el arranque.**



**14. Continuamos reiterando el proceso poco a poco hasta conseguir el núcleo lo más pequeño posible que pueda arrancar en nuestro equipo.**
