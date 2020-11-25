Title: Actualización de CentOS 7 a CentOS 8
Category: Administración de Sistemas Operativos
Date: 2020/11/20
Header_Cover: theme/images/banner-sistemas.jpg
Tags: Actualización, CentOS7, CentOS8

Vamos a realizar la actualización de la instancia **Quijote**, que creamos en este [post](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html) la cuál posee **CentOS 7**, a **CentOS 8**, garantizando que todos los servicios previos continúen funcionando.

Para comprobar la versión de *CentOS* que tenemos instalada en este momento:

<pre>
[root@quijote ~]# cat /etc/redhat-release
CentOS Linux release 7.8.2003 (Core)
</pre>

Lo primero que debemos si queremos subir de *CentOS 7* a *CentOS 8*, sería instalar el repositorio **EPEL** (Extra Packages Enterprise Linux). Recordemos que el gestor de paquetes predeterminado es *CentOS 7* es `yum`.

<pre>
yum install epel-release -y
</pre>

Debemos tener instaladas las herramientas para el gestor de paquetes `yum` y la herramienta `rpmconf`, para resolver los posibles conflictos en las configuraciones de paquetes *rpm*. Para instalar ambos paquetes:

<pre>
yum install yum-utils rpmconf -y
</pre>

Ejecutamos el siguiente comando, para comprobar si existen conflictos como acabamos de comentar.

<pre>
rpmconf -a
</pre>

Cuando hemos verificado que no hay ningún problema, vamos a eliminar los paquetes huérfanos y que nos resultan innecesarios:

<pre>
package-cleanup --orphans

package-cleanup --leaves
</pre>

En *CentOS 8*, el gestor de paquetes predeterminado no es `yum`, sino que se utiliza `dnf`, por tanto vamos a instalarlo, aunque realmente podemos seguir utilizando `yum` sin problemas, o conviviendo con los dos:

<pre>
yum install dnf
</pre>

Como ya hemos instalado y tenemos disponible el nuevo gestor de paquetes, podemos prescindir de `yum`. En mi caso ya no me interesa, por eso me deshago de él, pero si lo queremos conservar podemos saltarnos este paso.

<pre>
dnf remove yum yum-metadata-parser

rm -Rf /etc/yum
</pre>

Vamos a llevar a cabo una actualización de todos los paquetes del sistema:

<pre>
dnf update
</pre>

Ha llegado el momento de iniciar la actualización y de instalar los paquetes necesarios para *CentOS 8* que encontramos en los repositorios oficiales. Los instalamos:

<pre>
dnf install http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-repos-8.2-2.2004.0.1.el8.x86_64.rpm http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-release-8.2-2.2004.0.1.el8.x86_64.rpm http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8.2-2.2004.0.1.el8.noarch.rpm
</pre>

Toca actualizar de nuevo el repositorio *EPEL*:

<pre>
dnf upgrade -y epel-release
</pre>

Eliminamos los archivos temporales innecesarios.

<pre>
dnf clean all
</pre>

Ahora es el paso de eliminar el kérnel de *CentOS 7*:

<pre>
rpm -e `rpm -q kernel`
</pre>

Varios paquetes nos harán entrar en conflictos con ellos, por tanto también los removemos:

<pre>
rpm -e --nodeps sysvinit-tools
</pre>

Y por fin, empezamos la actualización a *CentOS 8*:

<pre>
dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
</pre>

Puede que varios paquetes relacionados con **Python**, nos produzcan conflictos, así que para resolverlos utilizamos estos comandos:

<pre>
rpm -e --justdb python36-rpmconf-1.0.22-1.el7.noarch rpmconf-1.0.22-1.el7.noarch
rpm -e --justdb --nodeps python3-setuptools-39.2.0-10.el7.noarch
rpm -e --justdb --nodeps vim-minimal
dnf upgrade --best --allowerasing rpm
</pre>

Para terminar, nos quedaría instalar el kérnel del nuevo *CentOS 8*:

<pre>
dnf install -y kernel-core
</pre>

Y por último, vamos a instalar los paquetes mínimos del sistema:

<pre>
dnf -y groupupdate "Core" "Minimal Install" --allowerasing --skip-broken
</pre>

Reiniciamos el sistema:

<pre>
reboot
</pre>

Si miramos de nuevo la versión de *CentOS*:

<pre>
[root@quijote ~]# cat /etc/redhat-release
CentOS Linux release 8.2.2004 (Core)

[root@quijote ~]#
</pre>

Vemos como hemos actualizado nuestro sistema y ahora está corriendo *CentOS 8*, por tanto la actulización de *Quijote* habría terminado.

Para finalizar, vamos a probar a hacer un ping a `www.google.es`, para asegurarnos que tiene conexión a internet y además hace uso de la resolución de nombres:

<pre>
[root@quijote ~]# ping www.google.es
PING www.google.es (172.217.17.3) 56(84) bytes of data.
64 bytes from mad07s09-in-f3.1e100.net (172.217.17.3): icmp_seq=1 ttl=112 time=43.7 ms
64 bytes from mad07s09-in-f3.1e100.net (172.217.17.3): icmp_seq=2 ttl=112 time=64.5 ms
64 bytes from mad07s09-in-f3.1e100.net (172.217.17.3): icmp_seq=3 ttl=112 time=44.0 ms
^C
--- www.google.es ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 43.773/50.790/64.546/9.727 ms

[root@quijote ~]#
</pre>

Efectivamente, obtenemos la respuesta esperada.
