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
  Password = "contraseña"
  Messages = Daemon
  DirAddress = 127.0.0.1
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
  Storage = File1
  Messages = Standard
  Pool = File
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
  Storage = File1
  Messages = Standard
  Pool = File
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
  Storage = File1
  Messages = Standard
  Pool = File
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
}

Job {
  Name = "Dulcinea-Semanal"
  Client = "dulcinea-fd"
  JobDefs = "BackupSemanal"
}

Job {
  Name = "Dulcinea-Mensual"
  Client = "dulcinea-fd"
  JobDefs = "BackupMensual"
}

# Sancho
Job {
  Name = "Sancho-Diario"
  Client = "sancho-fd"
  JobDefs = "BackupDiario"
}

Job {
  Name = "Sancho-Semanal"
  Client = "sancho-fd"
  JobDefs = "BackupSemanal"
}

Job {
  Name = "Sancho-Mensual"
  Client = "sancho-fd"
  JobDefs = "BackupMensual"
}

# Freston
Job {
  Name = "Freston-Diario"
  Client = "freston-fd"
  JobDefs = "BackupDiario"
}

Job {
  Name = "Freston-Semanal"
  Client = "freston-fd"
  JobDefs = "BackupSemanal"
}

Job {
  Name = "Freston-Mensual"
  Client = "freston-fd"
  JobDefs = "BackupMensual"
}

# Quijote
Job {
  Name = "Quijote-Diario"
  Client = "quijote-fd"
  JobDefs = "BackupDiario"
}

Job {
  Name = "Quijote-Semanal"
  Client = "quijote-fd"
  JobDefs = "BackupSemanal"
}

Job {
  Name = "Quijote-Mensual"
  Client = "quijote-fd"
  JobDefs = "BackupMensual"
}
</pre>

Igualmente que hemos definido en los clientes las tareas de *backups*, debemos definir las tareas de restauración (*restore*), para poder restaurar las copias de seguridad. En esta sección, tendremos bloques con el siguiente aspecto:

- **Name:** nombre de la tarea

- **Type:** tipo que de la tarea (*restore*)

- **Client:** cliente al que le vamos a poder realizar la restauración de la copia

- **FileSet:** tipo de tarea al que hace referencia la copia de la que queremos realizar la restauración

- **Storage:** nombre del cargador virtual automático que cargará el recurso de almacenamiento

- **Pool:** indicaremos el nombre del apartado *Pool* que se configurará mas adelante y en él estamos indicando el volumen de almacenamiento donde se creará y almacenará las copias

- **Messages:** tipo de mensaje, indica como mandará los mensajes de sucesos





















.
