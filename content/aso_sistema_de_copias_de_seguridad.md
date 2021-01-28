Title: Sistema de copias de seguridad
Date: 2021/01/26
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: OpenStack, Bacula, Backup

--------------------------------------------------------------------------------

- Selecciona una aplicación para realizar el proceso: bacula, amanda, shell script con tar, rsync, dar, afio, etc.
- Utiliza una de las instancias como servidor de copias de seguridad, añadiéndole un volumen y almacenando localmente las copias de seguridad que consideres adecuadas en él.
- El proceso debe realizarse de forma completamente automática
--------------------------------------------------------------------------------
- Selecciona qué información es necesaria guardar (listado de paquetes, ficheros de configuración, documentos, datos, etc.)
- Realiza semanalmente una copia completa
- Realiza diariamente una copia incremental, diferencial o delta diferencial (decidir cual es más adecuada)
- Implementa una planificación del almacenamiento de copias de seguridad para una ejecución prevista de varios años, detallando qué copias completas se almacenarán de forma permanente y cuales se irán borrando.
- Crea un registro de las copias, indicando fecha, tipo de copia, si se realizó correctamente o no y motivo.
- Selecciona un directorio de datos "críticos" que deberá almacenarse cifrado en la copia de seguridad, bien encargándote de hacer la copia manualmente o incluyendo la contraseña de cifrado en el sistema
- Incluye en la copia los datos de las nuevas aplicaciones que se vayan instalando durante el resto del curso
- Utiliza saturno u otra opción que se te facilite como equipo secundario para almacenar las copias de seguridad. Solicita acceso o la instalación de las aplicaciones que sean precisas.

El sistema de copias debe estar operativo para la fecha de entrega, aunque se podrán hacer correcciones menores que se detecten a medida que vayan ejecutándose las copias. La corrección se realizará la última semana de curso y consistirá tanto en la restauración puntual de un fichero en cualquier fecha como la restauración completa de una de las máquinas.

--------------------------------------------------------------------------------

**En este artículo vamos a implementar un sistema de copias de seguridad para las máquinas del escenario de *OpenStack* y la máquina de *OVH*.**

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

He hecho más tareas sobre este escenario, las puedes encontrar todas [aquí](https://javierpzh.github.io/tag/openstack.html).

Respecto al equipo de **OVH**, se trata de un *VPS* con un sistema *Debian*.

Explicado esto, vamos a pasar con el contenido del *post* en cuestión, no sin antes explicar un poco la aplicación que vamos a utilizar y sus componentes.

## Bacula

He decidido escoger **Bacula** como aplicación para llevar a cabo este sistema de *backups*.

*Bacula* es una colección de herramientas de respaldo capaz de cubrir las necesidades de respaldo de equipos bajo redes IP. Se basa en una arquitectura cliente-servidor que resulta eficaz y fácil de manejar, dada la amplia gama de funciones y características que brinda. Además, debido a su desarrollo y estructura modular, *Bacula* se adapta tanto al uso personal como profesional, desde un equipo hasta grandes parques de servidores. Todo el conjunto de elementos que forman *Bacula* trabajan en sincronía y son totalmente compatibles con bases de datos como **MySQL**, **SQLite** y **PostgreSQL**.

#### Componentes de *Bacula*

- **Director *(DIR, bacula-director)*:** es el programa servidor que supervisa todas las funciones necesarias para las operaciones de copia de seguridad y restauración. Es el eje central de *Bacula* y en él se declaran todos los parámetros necesarios. Se ejecuta como un *demonio* en el servidor.

- **Storage *(SD, bacula-sd)*:** es el programa que gestiona las unidades de almacenamiento donde se almacenarán los datos. Es el responsable de escribir y leer en los medios que utilizaremos para nuestras copias de seguridad. Se ejecuta como un *demonio* en la máquina propietaria de los medios utilizados. En muchos casos será en el propio servidor, pero también puede ser otro equipo independiente.

- **Catalog**: es la base de datos (*MySQL* en mi caso) que almacena la información necesaria para localizar donde se encuentran los datos salvaguardados de cada archivo, de cada cliente, ... En muchos casos será en el propio servidor, pero también puede ser otro equipo independiente.

- **Console *(bconsole)*:** es el programa que permite la interacción con el *Director* para todas las funciones del servidor. La versión original es una aplicación en modo texto *(bconsole)*. Existen igualmente aplicaciones GUI para Windows y Linux *(Webmin, Bacula Admin Tool, Bacuview, Webacula, Reportula, Bacula-Web, ...)*.

- **File *(FD)*:** este servicio, conocido como *cliente* o servidor de ficheros está instalado en cada máquina a salvaguardar y es específico al sistema operativo donde se ejecuta. Responsable para enviar al *Director* los datos cuando este lo requiera.

#### Conceptos importantes

Para manejar mejor *Bacula* es importante conocer ciertos conceptos:

- Un **backup** consiste en una tarea *(JOB)*, un conjunto de directorios/archivos *(FILESET)*, un cliente *(CLIENT)*, un horario *(SCHEDULE)* y unos recursos *(POOL)*.

- El **FILESET** es lo que vamos a guardar, el *CLIENT* es la proveniencia de los datos, el *SCHEDULE* determina cuando lo vamos a ejecutar y el *POOL* es el destino de la copia de seguridad.

- Normalmente, una combinación **CLIENT/FILESET** generará un determinado *JOB*. Además de los *JOB* de *backup*, existirán también *JOB* de *restore* y otros de control y administración.

- Los medios de almacenamiento se definen como **POOL**. El *POOL* es un conjunto de volúmenes, son ficheros que actúan como un disco duro, y dentro de ellos están las copias de seguridad.


## Sistema de copias de seguridad

En mi caso, he decidido escoger como servidor (también conocido como **director**) de copias de seguridad a *Dulcinea*. Le he añadido un nuevo volumen de 10 GB de espacio, donde se irán almacenando las copias de las distintas máquinas.

Empezaremos por instalar el *software* de *Bacula* y *MySQL*.

<pre>
apt install mariadb-server mariadb-client bacula bacula-common-mysql bacula-director-mysql -y
</pre>

Durante la instalación de *Bacula*, nos saldrá este mensaje emergente, en el que seleccionaremos **Yes**, para especificarle a la aplicación que deseamos configurarla con la base de datos *MySQL*:

<pre>
┌───────────────────────────────┤ Configuring bacula-director-mysql ├───────────────────────────────┐
│                                                                                                   │
│ The bacula-director-mysql package must have a database installed and configured before it can be  │
│ used. This can be optionally handled with dbconfig-common.                                        │
│                                                                                                   │
│ If you are an advanced database administrator and know that you want to perform this              │
│ configuration manually, or if your database has already been installed and configured, you        │
│ should refuse this option. Details on what needs to be done should most likely be provided in     │
│ /usr/share/doc/bacula-director-mysql.                                                             │
│                                                                                                   │
│ Otherwise, you should probably choose this option.                                                │
│                                                                                                   │
│ Configure database for bacula-director-mysql with dbconfig-common?                                │
│                                                                                                   │
│                            <\Yes\>                               <\No\>                           │
│                                                                                                   │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

A continuación, nos pedirá que introduzcamos una contraseña y habremos finalizado el proceso de instalación.

Vamos a pasar directamente con el fichero de configuración del director *Bacula*, que se encuentra en `/etc/bacula/bacula-dir.conf`. En este archivo nos encontraremos diferentes secciones, que tenemos que diferenciar, veamos la primera, que se trata de la configuración del **director** de copias de seguridad:

<pre>
Director {
  Name = dulcinea-dir
  DIRport = 9101
  QueryFile = "/etc/bacula/scripts/query.sql"
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/run/bacula"
  Maximum Concurrent Jobs = 20
  Password = "bacula"
  Messages = Daemon
  DirAddress = 10.0.1.11
}
</pre>

La siguiente sección trata de las tareas que se van a realizar, es decir, los procesos encargados de hacer las copias de seguridad.

En este apartado tendremos bloques como el siguiente:

<pre>
JobDefs {
  Name =
  Type =
  Level =
  Client =
  FileSet =
  Schedule =
  Storage =
  Messages =
  Pool =
  SpoolAttributes =
  Priority =
  Write Bootstrap =
}
</pre>

Os preguntaréis qué es cada apartado, pues vamos a verlos uno a uno:

- **Name:** nombre de la tarea

- **Type:** tipo de tarea (*backup*)

- **Level:** nivel de la tarea

- **Client:** nombre del cliente en el que se va a ejecutar esta tarea

- **FileSet:** información que va a copiar. Será definida más adelante en el apartado *FileSet*

- **Schedule:** programación que tendrá dicha tarea

- **Storage:** nombre del cargador virtual automático que cargará el recurso de almacenamiento

- **Messages:** tipo de mensaje, indica como mandará los mensajes de sucesos

- **Pool:** indicaremos el nombre del apartado *Pool* que se configurará mas adelante y en él estamos indicando el volumen de almacenamiento donde se creará y almacenará las copias

- **SpoolAttributes:** esta opción permite trabajar con los atributos del *Spool* en un fichero temporal

- **Priority:** indica el nivel de prioridad

- **Write Bootstrap:** este apartado indica donde esta el fichero *bacula*

En mi caso, introduciré tres tipos de tareas distintas, una para las copias diarias, otra para las copias semanales y otra para las copias mensuales, de manera que me queda un bloque como el siguiente:

<pre>
JobDefs {
  Name = "BackupDiario"
  Type = Backup
  Level = Incremental
  Client = dulcinea-fd
  FileSet = "Full Set"
  Schedule = "Daily"
  Storage = volcopias
  Messages = Standard
  Pool = Daily
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

JobDefs {
  Name = "BackupSemanal"
  Type = Backup
  Level = Incremental
  Client = dulcinea-fd
  FileSet = "Full Set"
  Schedule = "Weekly"
  Storage = volcopias
  Messages = Standard
  Pool = Weekly
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

JobDefs {
  Name = "BackupMensual"
  Type = Backup
  Level = Incremental
  Client = dulcinea-fd
  FileSet = "Full Set"
  Schedule = "Monthly"
  Storage = volcopias
  Messages = Standard
  Pool = Monthly
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}
</pre>

A continuación nos encontramos con la sección donde definiremos las tareas de los clientes a los que vamos a realizar las copias de seguridad. Dentro de los siguientes bloques, indicamos el nombre de la tarea con la que va a ir relacionado y el nombre del cliente (se definirá más adelante). Introduciremos tantos bloques **Job** como tareas tengamos que asignar a los clientes. En mi caso:

<pre>
# Dulcinea
Job {
  Name = "Dulcinea-Diario"
  Client = "dulcinea-fd"
  JobDefs = "BackupDiario"
  FileSet= "Dulcinea-Datos"
}

Job {
  Name = "Dulcinea-Semanal"
  Client = "dulcinea-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Dulcinea-Datos"
}

Job {
  Name = "Dulcinea-Mensual"
  Client = "dulcinea-fd"
  JobDefs = "BackupMensual"
  FileSet= "Dulcinea-Datos"
}

# Sancho
Job {
  Name = "Sancho-Diario"
  Client = "sancho-fd"
  JobDefs = "BackupDiario"
  FileSet= "Sancho-Datos"
}

Job {
  Name = "Sancho-Semanal"
  Client = "sancho-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Sancho-Datos"
}

Job {
  Name = "Sancho-Mensual"
  Client = "sancho-fd"
  JobDefs = "BackupMensual"
  FileSet= "Sancho-Datos"
}

# Freston
Job {
  Name = "Freston-Diario"
  Client = "freston-fd"
  JobDefs = "BackupDiario"
  FileSet= "Freston-Datos"
}

Job {
  Name = "Freston-Semanal"
  Client = "freston-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Freston-Datos"
}

Job {
  Name = "Freston-Mensual"
  Client = "freston-fd"
  JobDefs = "BackupMensual"
  FileSet= "Freston-Datos"
}

# Quijote
Job {
  Name = "Quijote-Diario"
  Client = "quijote-fd"
  JobDefs = "BackupDiario"
  FileSet= "Quijote-Datos"
}

Job {
  Name = "Quijote-Semanal"
  Client = "quijote-fd"
  JobDefs = "BackupSemanal"
  FileSet= "Quijote-Datos"
}

Job {
  Name = "Quijote-Mensual"
  Client = "quijote-fd"
  JobDefs = "BackupMensual"
  FileSet= "Quijote-Datos"
}
</pre>

Igualmente que hemos definido en los clientes las tareas de *backups*, debemos definir las tareas de restauración (*restore*), para poder restaurar las copias de seguridad. En esta sección, tendremos bloques con el siguiente aspecto:

- **Name:** nombre de la tarea

- **Type:** tipo que de la tarea (*restore*)

- **Client:** cliente al que le vamos a poder realizar la restauración de la copia

- **Storage:** nombre del cargador virtual automático que cargará el recurso de almacenamiento

- **FileSet:** tipo de tarea al que hace referencia la copia de la que queremos realizar la restauración

- **Pool:** indicaremos el nombre del apartado *Pool* que se configurará mas adelante y en él estamos indicando el volumen de almacenamiento donde se creará y almacenará las copias

- **Messages:** tipo de mensaje, indica como mandará los mensajes de sucesos

En mi caso, introduzco los siguientes bloques:

<pre>
# Dulcinea
Job {
  Name = "DulcineaRestore"
  Type = Restore
  Client=dulcinea-fd
  Storage = volcopias
  FileSet="Dulcinea-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Sancho
Job {
  Name = "SanchoRestore"
  Type = Restore
  Client=sancho-fd
  Storage = volcopias
  FileSet="Sancho-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Freston
Job {
  Name = "FrestonRestore"
  Type = Restore
  Client=freston-fd
  Storage = volcopias
  FileSet="Freston-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Quijote
Job {
  Name = "QuijoteRestore"
  Type = Restore
  Client=quijote-fd
  Storage = volcopias
  FileSet="Quijote-Datos"
  Pool = Backup-Restore
  Messages = Standard
}
</pre>

Seguimos con la sección donde indicaremos, que tipo de información se almacenarán en los *backups*, indicando que directorios se copiarán y cuáles no, y el tipo de almacenamiento, que en mi caso se tratará de un almacenamiento comprimido para así ahorrar espacio.

<pre>
# Full Set
FileSet {
 Name = "Full Set"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Dulcinea
FileSet {
 Name = "Dulcinea-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
   File = /bacula
 }
 Exclude {
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Sancho
FileSet {
 Name = "Sancho-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Freston
FileSet {
 Name = "Freston-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Quijote
FileSet {
 Name = "Quijote-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}
</pre>

Llegamos a la sección de los bloques de tipo **SCHEDULE**, en éstos definiremos la programación de estas tareas, es decir, cuando se llevarán a cabo cada una. En mi caso:

<pre>
Schedule {
 Name = "Daily"
 Run = Level=Incremental Pool=Daily daily at 02:00
}

Schedule {
 Name = "Weekly"
 Run = Level=Full Pool=Weekly sun at 02:00
}

Schedule {
 Name = "Monthly"
 Run = Level=Full Pool=Monthly 1st sun at 02:00
}
</pre>

Estamos llegando al final de la configuración de este fichero, en este caso nos encontramos con los equipos clientes, cuyos bloques incluirán las siguientes opciones:

- **Name:** Nombre distintivo del cliente

- **Address:** Direccion ip del cliente

- **FDPort:** el puerto, dejamos el valor por defecto

- **Catalog:** dejamos el valor por defecto

- **Password:** contraseña del cliente

- **File Retention:** dejamos el valor por defecto

- **Job Retention:** dejamos el valor por defecto

- **AutoPrune:** dejamos el valor por defecto

Añado mis clientes:

<pre>
# Dulcinea
Client {
 Name = dulcinea-fd
 Address = 10.0.1.11
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Sancho
Client {
 Name = sancho-fd
 Address = 10.0.1.8
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Freston
Client {
 Name = freston-fd
 Address = 10.0.1.6
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Quijote
Client {
 Name = quijote-fd
 Address = 10.0.2.6
 FDPort = 9102
 Catalog = MyCatalog
 Password = "bacula"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}
</pre>

Una vez definidos los clientes, lo que tendremos que definir es que tipo de almacenamiento vamos a tener, en mi caso, los parámetros a modificar son:

- **Name:** para que concuerde con el que hacemos referencia al principio del fichero en el segundo apartado

- **Address:** dirección IP, indicaremos la de nuestro propio servidor para así indicar donde almacenar la información

- **SDPort:** el puerto, dejamos el valor por defecto

- **Password:** para que sea la misma que hemos indicado anteriormente

- **Device:** tipo de dispositivo que en nuestro caso es *File*

- **Media Type:** dejamos el valor por defecto

- **Maximum Concurrent Jobs:** dejamos el valor por defecto

Nos quedaría un bloque como este:

<pre>
Storage {
 Name = volcopias
 Address = 10.0.1.11
 SDPort = 9103
 Password = "bacula"
 Device = FileChgr1
 Media Type = File
 Maximum Concurrent Jobs = 10
}
</pre>

En la sección **Catalog**, nos encontraremos con la configuración relativa a la base de datos:

<pre>
Catalog {
  Name = MyCatalog
  dbname = "bacula"; DB Address = "localhost"; DB Port= "3306"; dbuser = "bacula"; dbpassword = "bacula"
}
</pre>

Nos encontramos frente a la última sección a editar, que no es otra que dónde se encuentran los bloques **Pool**. En ellos nos encontramos con estos parámetros:

- **Name:** nombre del *pool*

- **Pool type:** tipo de *pool*

- **Recycle:** reciclado automático de los volúmenes, está activado por defecto

- **AutoPrune:** expirador automáticos de los volúmenes, está activado por defecto

- **Volume Retention:** tiempo de retención que deseamos almacenar los *backups* realizados

- **Maximum Volume Bytes:** dejamos el valor por defecto

- **Maximum Volumes:** dejamos el valor por defecto

- **Label Format:** dejamos el valor por defecto

Introduzco los siguientes bloques:

<pre>
Pool {
 Name = Daily
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 VolumeRetention = 8d
}

Pool {
 Name = Weekly
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 VolumeRetention = 32d
}

Pool {
 Name = Monthly
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 VolumeRetention = 365d
}

Pool {
 Name = Backup-Restore
 Pool Type = Backup
 Recycle = yes
 AutoPrune = yes
 Volume Retention = 366 days
 Maximum Volume Bytes = 50G
 Maximum Volumes = 100
 Label Format = "Remoto"
}
</pre>

En este punto, ya habríamos terminado de modificar el fichero `/etc/bacula/bacula-dir.conf`, ya que los apartados siguientes los dejaríamos como vienen por defecto.

Para comprobar que no hay ningún error en nuestra configuración anterior, podemos emplear el siguiente comando:

<pre>
bacula-dir -tc /etc/bacula/bacula-dir.conf
</pre>

¿No nos reporta ningún error? Perfecto, podemos seguir con el siguiente punto.

Al principio comenté que había añadido un nuevo volumen en el que iría almacenando las distintas copias, pero ese nuevo disco aún no se encuentra montado en el sistema, por tanto vamos a proceder a prepararlo para su correcto funcionamiento.

Vamos a crear en él una partición nueva:

<pre>
root@dulcinea:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    254:0    0  10G  0 disk
└─vda1 254:1    0  10G  0 part /
vdb    254:16   0  10G  0 disk

root@dulcinea:~# gdisk /dev/vdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): n
Partition number (1-128, default 1):
First sector (34-20971486, default = 2048) or {+-}size{KMGTP}:
Last sector (2048-20971486, default = 20971486) or {+-}size{KMGTP}:
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300):
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/vdb.
The operation has completed successfully.

root@dulcinea:~# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    254:0    0  10G  0 disk
└─vda1 254:1    0  10G  0 part /
vdb    254:16   0  10G  0 disk
└─vdb1 254:17   0  10G  0 part
</pre>

Bien, ahora nos quedaría montarlo en nuestro sistema, pero además me interesa que se monte automáticamente en cada arranque del sistema, por tanto, también lo añadiré al fichero `/etc/fstab`:

<pre>

</pre>























.
