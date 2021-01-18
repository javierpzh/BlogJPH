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


Para instalar *Btrfs* en nuestro sistema *Debian*, tenemos disponible el paquete **btrfs-tools**, que incluye todas las herramientas y características de este sistema de ficheros.

<pre>
apt install btrfs-tools -y
</pre>









.
