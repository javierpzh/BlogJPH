Title: Sistema de ficheros "avanzados" Btrfs
Date: 2021/01/18
Category: Cloud Computing
Header_Cover: theme/images/banner-hlc.jpg
Tags: FileSystem, Btrfs

Elige uno de los dos sistemas de ficheros "avanzados".

- Crea un escenario que incluya una máquina y varios discos asociados a ella.

- Instala si es necesario el software de Btrfs

- Gestiona los discos adicionales con Btrfs

- Configura los discos en RAID, haciendo pruebas de fallo de algún disco y sustitución, restauración del RAID. Comenta ventajas e inconvenientes respecto al uso de RAID software con `mdadm`.

- Realiza ejercicios con pruebas de funcionamiento de las principales funcionalidades: compresión, cow, deduplicación, cifrado, etc.

Esta tarea se puede realizar en una instancia de OpenStack y documentarla como habitualmente o bien grabar un vídeo con una demo de las características y hacer la entrega con el enlace del vídeo.

-----------------------------------------------------------------------------------------------------------

En este *post* vamos a ver el sistema de ficheros **Btrfs**.

**Btrfs** *(B-tree FS)* es un sistema de archivos **copy-on-write** *(CoW)* anunciado por *Oracle Corporation* para *GNU/Linux*. *Btrfs* existe porque los desarrolladores querían expandir la funcionalidad de un sistema de archivos para incluir funcionalidades adicionales tales como agrupación, instantáneas y sumas de verificación.

El proyecto comenzó en *Oracle*, pero desde entonces, otras compañías importantes han desempeñado un papel en el desarrollo, como pueden ser *Facebook*, *Intel*, *Netgear*, *Red Hat* y *SUSE*.

Veamos algunas características de este sistema de ficheros:

- 2^64 bytes = 16 EiB *(Exbibyte)* tamaño máximo de archivo

- Empaquetado eficiente en espacio de archivos pequeños y directorios indexados

- Asignación dinámica de inodos (no se fija un número máximo de archivos al crear el sistema de archivos)

- *Snapshots* escribibles y *snapshots* de *snapshots*

- Subvolúmenes

- *Mirroring* y *Striping* a nivel de objeto

- Comprobación de datos y metadatos

- Compresión

- *Copy-on-write* del registro de todos los datos y metadatos

- Gran integración con *device-mapper* para soportar múltiples dispositivos, con varios algoritmos de RAID incluidos

- Comprobación del sistema de archivos sin desmontar y comprobación muy rápida del sistema de archivos desmontado

- Copias de seguridad incrementales eficaces y *mirroring* del sistema de archivos

- Modo optimizado para SSD

- Desfragmentación sin desmontar


Para empezar a trabajar con este sistema de ficheros, he creado un escenario en *OpenStack* que se resume en una instancia con *Debian*, a la que le he añadido tres volúmenes de 1 GB cada uno, como podemos observar aquí:

<pre>
root@btrfs:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    254:0    0   2G  0 disk
└─vda1 254:1    0   2G  0 part /
vdb    254:16   0   1G  0 disk
vdc    254:32   0   1G  0 disk
vdd    254:48   0   1G  0 disk
</pre>

Para instalar *Btrfs* en nuestro sistema *Debian*, tenemos disponible el paquete **btrfs-tools**, que incluye todas las herramientas y características de este sistema de ficheros.

<pre>
apt install btrfs-tools -y
</pre>

En primer lugar, vamos a formatear estos volúmenes y asignarle como sistema de ficheros *Btrfs*. Para ello, hacemos uso de la herramienta `mkfs.()` seguido de los dispositivos:

<pre>
root@btrfs:~# mkfs.btrfs /dev/vdb /dev/vdc /dev/vdd
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               800a0dc3-d7d2-433a-8445-69e0d09d99cd
Node size:          16384
Sector size:        4096
Filesystem size:    3.00GiB
Block group profiles:
  Data:             RAID0           307.12MiB
  Metadata:         RAID1           153.56MiB
  System:           RAID1             8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  3
Devices:
   ID        SIZE  PATH
    1     1.00GiB  /dev/vdb
    2     1.00GiB  /dev/vdc
    3     1.00GiB  /dev/vdd
</pre>

Vemos como efectivamente ahora poseen *Btrfs*:

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.4M    51% /
vdb    btrfs        800a0dc3-d7d2-433a-8445-69e0d09d99cd                
vdc    btrfs        800a0dc3-d7d2-433a-8445-69e0d09d99cd                
vdd    btrfs        800a0dc3-d7d2-433a-8445-69e0d09d99cd
</pre>




























.
