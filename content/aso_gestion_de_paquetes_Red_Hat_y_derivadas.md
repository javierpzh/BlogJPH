Title: Gestión de paquetes - Red Hat y derivadas
Date: 2020/11/16
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: Red Hat, CentOS, gestion, paquetes

## Gestión de paquetes

Todos los ejercicios están realizados en una máquina **CentOS 7**.

**1. Modifica la configuración de red de DHCP a estática.**

Para realizar esta modificación debemos editar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`, y establecer este bloque en él:

<pre>
BOOTPROTO=static
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
IPADDR=X.X.X.X
NETMASK=X.X.X.X
GATEWAY=X.X.X.X
DNS1=X.X.X.X
DNS2=X.X.X.X
DNSX=X.X.X.X
</pre>

Reiniciamos y aplicamos los cambios en las interfaces de red:

<pre>
systemctl restart network.service
</pre>

**2. Actualiza el sistema a las versiones más recientes de los paquetes instalados.**

Para realizar una actualización de todos los paquetes instalados en el sistema, empleamos este comando:

<pre>
yum update
</pre>

Cuando se ejecuta este comando, `yum` comenzará a comprobar en sus repositorios si existe una versión actualizada del software que el sistema tiene instalado actualmente. Una vez que revisa la lista de repositorios y nos informa de que paquetes se pueden actualizar, introducimos `y` y pulsando *intro* se nos actualizarán todos los paquetes.

**3. Instala los repositorios adicionales EPEL y CentOSPlus.**

El siguiente comando nos permite listar todos los repositorios que tenemos activos:

<pre>
[root@quijote ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.airenetworks.es
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
repo id                                         repo name                                         status
base/7/x86_64                                   CentOS-7 - Base                                   10,072
extras/7/x86_64                                 CentOS-7 - Extras                                    448
updates/7/x86_64                                CentOS-7 - Updates                                   293
repolist: 10,813
</pre>

Para instalar el repositorio **EPEL** tenemos que descargar un archivo con extensión *.rpm* y después instalarlo. Para descargar el archivo *.rpm* ejecutamos el siguiente comando:

- Centos 7.0: `wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

Si queréis instalar `wget`:

<pre>
yum install wget
</pre>

Instalamos el paquete descargado:

<pre>
[root@quijote ~]# rpm -ivh epel-release-latest-7.noarch.rpm
warning: epel-release-latest-7.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID 352c64e5: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:epel-release-7-12                ################################# [100%]
</pre>

Listamos de nuevo los repositorios activos:

<pre>
[root@quijote ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
epel/x86_64/metalink                                                             |  14 kB  00:00:00     
 * base: mirror.airenetworks.es
 * epel: mirror.slu.cz
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
epel                                                                             | 4.7 kB  00:00:00     
(1/3): epel/x86_64/group_gz                                                      |  95 kB  00:00:00     
(2/3): epel/x86_64/updateinfo                                                    | 1.0 MB  00:00:01     
(3/3): epel/x86_64/primary_db                                                    | 6.9 MB  00:00:07     
repo id                           repo name                                                       status
base/7/x86_64                     CentOS-7 - Base                                                 10,072
epel/x86_64                       Extra Packages for Enterprise Linux 7 - x86_64                  13,470
extras/7/x86_64                   CentOS-7 - Extras                                                  448
updates/7/x86_64                  CentOS-7 - Updates                                                 293
repolist: 24,283
</pre>



**4. Instala el paquete que proporciona el programa dig, explicando los pasos que has dado para encontrarlo.**



**5. Explica qué comando utilizarías para ver la información del paquete kernel instalado.**



**6. Instala el repositorio adicional "elrepo" e instala el último núcleo disponible del mismo (5.9.X).**



**7. Busca las versiones disponibles para instalar del núcleo linux e instala la más nueva.**



**8. Muestra el contenido del paquete del último núcleo instalado.**
