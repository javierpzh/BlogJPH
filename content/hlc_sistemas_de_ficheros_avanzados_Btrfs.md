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

--------------------------------------------------------------------------------

En este *post* vamos a ver el sistema de ficheros **Btrfs**.

#### Características

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


#### Escenario de trabajo

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

Pasemos con la instalación.

#### Instalación

Para instalar *Btrfs* en nuestro sistema *Debian*, tenemos disponible el paquete **btrfs-tools**, que incluye todas las herramientas y características de este sistema de ficheros.

<pre>
apt install btrfs-tools -y
</pre>

Ya habremos instalado las herramientas.

#### Gestión de los discos

En primer lugar, vamos a formatear uno de estos volúmenes y asignarle como sistema de ficheros *Btrfs*. Para ello, hacemos uso de la herramienta `mkfs.()` seguido del dispositivo:

<pre>
root@btrfs:~# mkfs.btrfs /dev/vdb
</pre>

Comprobamos que hemos asignado este *filesystem* correctamente:

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.4M    51% /
vdb    btrfs        800a0dc3-d7d2-433a-8445-69e0d09d99cd                
vdc
vdd
</pre>

Efectivamente ya estaríamos gestionando el dispositivo `vdb` con *Btrfs*.

#### RAID

¿Y qué pasa si quisiéramos crear un sistema **RAID** con los 3 nuevos volúmenes? Bien, pues para llevar a cabo esto, nos valdría con introducir el mismo comando que hemos utilizado para formatear un dispositivo, pero indicando los tres discos en este caso.

Esto ocurre ya que *Btrfs* lo interpreta como un RAID para su gestión aunque no lo estemos indicando. Si queremos indicar el tipo de RAID que debe crear, podemos utilizar los parámetros `-d` y `-m` para especificar el perfil de redundancia para los datos y metadatos. En mi caso, voy a crear un RAID 1, que recordemos que se caracteriza por duplicar el almacenamiento de los datos en todos los dispositivos:

<pre>
root@btrfs:~# mkfs.btrfs -d raid1 -m raid1 /dev/vdb /dev/vdc /dev/vdd
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

/dev/vdb appears to contain an existing filesystem (btrfs).
ERROR: use the -f option to force overwrite of /dev/vdb
</pre>

Al haber utilizado anteriormente el disco `vdb` nos avisa que ya tiene un sistema de ficheros y que si queremos asignarle nuevamente este *filesystem*, tendremos que indicar el parámetro `-f` y de esta manera forzarlo.

<pre>
root@btrfs:~# mkfs.btrfs -f -d raid1 -m raid1 /dev/vdb /dev/vdc /dev/vdd
btrfs-progs v4.20.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               1675b6b0-4741-4341-bb5b-403e1e7c2932
Node size:          16384
Sector size:        4096
Filesystem size:    3.00GiB
Block group profiles:
  Data:             RAID1           153.56MiB
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
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932
</pre>

Además de poseer este sistema de ficheros, apreciamos como los identificadores de los tres dispositivos son idénticos, esto se debe a que el sistema lo identifica como tan sólo uno.

Os preguntaréis como haríamos para añadir un nuevo disco a este RAID ya existente, antes de verlo, vamos a montar el sistema RAID en nuestro sistema:

<pre>
root@btrfs:~# mount /dev/vdb /mnt/

root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932  734.9M     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                

root@btrfs:~# btrfs scrub start /mnt/
scrub started on /mnt/, fsid 1675b6b0-4741-4341-bb5b-403e1e7c2932 (pid=640)

root@btrfs:~# btrfs scrub status /mnt/
scrub status for 1675b6b0-4741-4341-bb5b-403e1e7c2932
	scrub started at Mon Jan 18 18:10:43 2021 and finished after 00:00:00
	total bytes scrubbed: 512.00KiB with 0 errors
</pre>

Una vez montado nuestro RAID, vamos a añadir un nuevo dispositivo, en este caso el llamado `vde`:

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932  581.3M     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vde
</pre>

Vemos que no posee el sistema *Btrfs*, y es una unidad nueva, lo añadimos:

<pre>
root@btrfs:~# btrfs device add /dev/vde /mnt/

root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932    1.1G     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdd    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vde    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 320.00KiB
	devid    1 size 1.00GiB used 595.12MiB path /dev/vdb
	devid    2 size 1.00GiB used 665.56MiB path /dev/vdc
	devid    3 size 1.00GiB used 441.56MiB path /dev/vdd
	devid    4 size 1.00GiB used 0.00B path /dev/vde
</pre>

Ya habríamos añadido este nuevo dispositivo pero aún nos faltaría activar el balanceo de carga para que se reparta la información entre los discos, incluyendo el nuevo que hemos añadido.

<pre>
root@btrfs:~# btrfs balance start --full-balance /mnt/
Done, had to relocate 5 out of 5 chunks

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 320.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 416.00MiB path /dev/vdc
	devid    3 size 1.00GiB used 256.00MiB path /dev/vdd
	devid    4 size 1.00GiB used 448.00MiB path /dev/vde
</pre>

En este punto, sí se habría añadido completamente el disco y su funcionamiento sería el correcto.

Para seguir, vamos a probar a ver que pasaría en caso de que uno de los discos fallara, por ejemplo el `vdd`, por tanto, el sistema ya no lo reconoce e identifica un fallo en el sistema RAID, y he añadido el nuevo disco `vdf` para que sustituya al anterior y así se pueda restaurar el RAID correctamente.

<pre>
root@btrfs:~# lsblk -f
NAME   FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
vda                                                                     
└─vda1 ext4         9659e5d4-dd87-42af-bf70-0bb6f7b2e31b  846.1M    51% /
vdb    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932    1.5G     1% /mnt
vdc    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vde    btrfs        1675b6b0-4741-4341-bb5b-403e1e7c2932                
vdf

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 256.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 32.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 416.00MiB path /dev/vde
	*** Some devices missing
</pre>

Vemos como nos detecta el fallo debido a que falta un dispositivo, y procedemos a sustituirlo:

<pre>
root@btrfs:~# btrfs device add /dev/vdf /mnt/ && btrfs device delete /dev/vdd /mnt/

root@btrfs:~# btrfs filesystem show
Label: none  uuid: 1675b6b0-4741-4341-bb5b-403e1e7c2932
	Total devices 4 FS bytes used 320.00KiB
	devid    1 size 1.00GiB used 288.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 448.00MiB path /dev/vdc
	devid    4 size 1.00GiB used 256.00MiB path /dev/vde
	devid    6 size 1.00GiB used 416.00MiB path /dev/vdf
</pre>

Hecho esto, habríamos resuelto este problema y habríamos sustituido el disco estropeado.

Bien, ¿y si tuviéramos dudas entre elegir RAID mediante *Btrfs* o mediante la herramienta `mdadm`, qué diferencia tendríamos entre ellas? Pues para responder esta pregunta es necesario conocer las ventajas y los inconvenientes de cada una de las opciones, así que pasaremos a analizarlas.

Una ventaja de RAID software mediante `mdadm` es que sencillo de realizar, forma un sistema estable y tiene un mayor rendimiento. Por otro lado, con *Btrfs* los datos se encuentran protegidos con un mayor sistema de seguridad. Pero sobre todo, la principal diferencia, es que haciendo uso de *Btrfs*, podemos crear un RAID 1 con discos de diferentes tamaños, incluso con la posibilidad de ampliarlos, mientras que con `mdadm` es necesario el mismo tamaño en los discos. Por último, una cosa que no he comentado anteriormente y es bastante interesante, es que por ejemplo, hemos montado un RAID 1, que consta de 4 discos de 1 GB cada uno, y conociendo las características de este tipo de RAID, el espacio total sería de 1 GB, como el menor de sus discos, pues vamos a comprobar el tamaño de este RAID:

<pre>
root@btrfs:~# df -h
Filesystem      Size  Used Avail Use% Mounted on

...

/dev/vdb        2.0G   17M  1.7G   1% /mnt
</pre>

¡Anda! Resulta que duplica el tamaño esperado, y esto es porque *Btrfs* gestiona el almacenamiento de una manera distinta, ya que reparte la información entre los diferentes dispositivos, aprovechando el máximo espacio posible, al mismo tiempo que asegura que la información se encuentra lo más segura posible. Así que imaginemos que creamos un RAID 1 con discos de distintos tamaños, ya no tendríamos el inconveniente de que el tamaño será igual al menor de sus discos.

Lógicamente la elección de uno u otro es algo subjetivo y dependerá de gustos, costumbres y necesidades, pero en resumen, poseemos más flexibilidad y muchas más características útiles en el RAID con *Btrfs* respecto al RAID con `mdadm`.

#### Compresión




































#### CoW


#### Deduplicación


#### Cifrado


.
