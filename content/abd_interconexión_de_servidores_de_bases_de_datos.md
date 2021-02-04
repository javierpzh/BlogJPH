Title: Interconexiones de Servidores de bases de datos
Date: 2018/02/03
Category: Administración de Bases de Datos
Header_Cover: theme/images/banner-basededatos.png
Tags: Base de Datos, Oracle, MySQL, MariaDB, PostgreSQL

**Las interconexiones de servidores de bases de datos son operaciones que pueden ser muy útiles en diferentes contextos. Básicamente, se trata de acceder a datos que no están almacenados en nuestra base de datos, pudiendo combinarlos con los que ya tenemos.**

**En este artículo veremos varias formas de crear un enlace entre distintos servidores de bases de datos. Los servidores enlazados siempre estarán instalados en máquinas diferentes.**

**Hay que decir que trabajaré sobre los escenarios creados en el *post* anterior, que trataba sobre [Instalación de Servidores y Clientes de bases de datos](https://javierpzh.github.io/instalacion-de-servidores-y-clientes-de-bases-de-datos.html), por lo que ya dispongo de los servidores instalados y con las configuraciones básicas.**

#### Enlace entre dos servidores de bases de datos ORACLE

En este primer caso, vamos a ver que configuraciones son necesarias para enlazar dos servidores **Oracles**.

Nos situamos en la primera de las máquinas, que recordemos que recibe el nombre de **servidor**.

Nos dirigiremos a los ficheros `listener.ora` y `tnsnames.ora`, ambos se encuentran en la ruta `$ORACLE_HOME/network/admin`, ya que en ellos es donde realizaremos la configuración.

Primeramente, para habilitar el acceso remoto al servidor, debemos modificar el fichero `listener.ora`. Por defecto, posee este aspecto:

<pre>
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\bin\oraclr19.dll")
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Si nos fijamos, dentro del bloque **LISTENER**, en la línea que define la regla para el protocolo TCP, que es la que nos interesa, podemos ver que en el campo **HOST** está configurado para que solo escuche las peticiones cuyo origen es **localhost**. También está configurado para que el puerto por el que escuche sea el **1521**, que es el que viene configurado por defecto, a mí me vale, por eso lo dejo. Obviamente lo que hay que cambiar es el valor del campo **HOST**, y establecerle como valor la interfaz desde la que queremos escuchar las peticiones. En mi caso, voy a especificar el **nombre de mi máquina** para que así escuche todas las peticiones.

<pre>
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\bin\oraclr19.dll")
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = DESKTOP-IGG1O7P)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Una vez hemos realizado este cambio, podemos iniciar el listener. El listener se maneja con estos comandos:

- **lsnrctl start:** inicia el servicio.
- **lsnrctl stop:** detiene el servicio.
- **lsnrctl status:** muestra información sobre el estado.

Lo iniciamos:

<pre>
C:\Windows\System32>lsnrctl start

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 17-DIC-2020 14:07:48

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Iniciando tnslsnr: espere...

TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
El archivo de parßmetros del sistema es C:\Users\javier\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Mensajes de log escritos en C:\Users\javier\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
ESTADO del LISTENER
------------------------
Alias                     LISTENER
Versi¾n                   TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
Fecha de Inicio       28-ENE-2020 14:07:52
Tiempo Actividad   0 dÝas 0 hr. 0 min. 10 seg.
Nivel de Rastreo        off
Seguridad               ON: Local OS Authentication
SNMP                      OFF
Parßmetros del Listener   C:\Users\javier\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Log del Listener          C:\Users\javier\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo Resumen de Puntos Finales...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))
Resumen de Servicios...
El servicio "CLRExtProc" tiene 1 instancia(s).
  La instancia "CLRExtProc", con estado UNKNOWN, tiene 1 manejador(es) para este servicio...
El comando ha terminado correctamente
</pre>

Vemos que lo ha iniciado correctamente. Ahora, para asegurarnos que realmente está escuchando peticiones desde el puerto 1521 vamos a utilizar el comando `netstat`:

<pre>
C:\Users\servidor>netstat

Conexiones activas

  Proto  Dirección local        Dirección remota       Estado
  TCP    127.0.0.1:1521         DESKTOP-IGG1O7P:49692  ESTABLISHED
  TCP    127.0.0.1:49692        DESKTOP-IGG1O7P:1521   ESTABLISHED
  TCP    [fe80::c9ee:eb4d:5f0b:a64f%4]:49703  DESKTOP-IGG1O7P:1521   TIME_WAIT
</pre>

Vemos que efectivamente está escuchando en dicho puerto.

Hecho esto, ya habríamos habilitado al servidor para que permita el acceso remoto, por tanto, vamos a dirigirnos al segundo y último fichero de configuración, el llamado `tnsnames.ora`, que por defecto posee esta configuración:

<pre>
LISTENER_ORCL =
  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))


ORACLR_CONNECTION_DATA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
    (CONNECT_DATA =
      (SID = CLRExtProc)
      (PRESENTATION = RO)
    )
  )

ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
</pre>

Editaremos el último bloque que definirá la conexión con el segundo servidor *Oracle*, quedando de esta manera:

<pre>
ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.56)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
</pre>

Una vez modificado este fichero, debemos parar el proceso **listener** y volverlo a iniciar para que así se apliquen los nuevos cambios.

<pre>
C:\Windows\system32>lsnrctl stop

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 03-FEB-2021 17:53:36

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
El comando ha terminado correctamente

C:\Windows\system32>lsnrctl start

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 03-FEB-2021 17:53:58

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Iniciando tnslsnr: espere...

TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
El archivo de parßmetros del sistema es C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Mensajes de log escritos en C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
ESTADO del LISTENER
------------------------
Alias                     LISTENER
Versi¾n                   TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
Fecha de Inicio       03-FEB-2021 17:54:02
Tiempo Actividad   0 dÝas 0 hr. 0 min. 10 seg.
Nivel de Rastreo        off
Seguridad               ON: Local OS Authentication
SNMP                      OFF
Parßmetros del Listener   C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Log del Listener          C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo Resumen de Puntos Finales...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))
Resumen de Servicios...
El servicio "CLRExtProc" tiene 1 instancia(s).
  La instancia "CLRExtProc", con estado UNKNOWN, tiene 1 manejador(es) para este servicio...
El comando ha terminado correctamente

C:\Windows\system32>
</pre>

Bien, ahora debemos dirigirnos al segundo servidor, que es al que vamos a realizarle la consulta, y en su fichero `listener.ora`, habilitar el acceso remoto como hicimos anteriormente:

<pre>
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home)
      (PROGRAM = extproc)
      (ENVS = "EXTPROC_DLLS=ONLY:C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\bin\oraclr19.dll")
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = DESKTOP-IGG1O7P)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
</pre>

Cuando hayamos realizado la modificación, iniciaremos de nuevo el **listener** y aplicaremos los cambios:

<pre>
C:\Windows\system32>lsnrctl start

LSNRCTL for 64-bit Windows: Version 19.0.0.0.0 - Production on 03-FEB-2021 18:02:49

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Iniciando tnslsnr: espere...

TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
El archivo de parßmetros del sistema es C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Mensajes de log escritos en C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
Recibiendo en: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))

Conectßndose a (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
ESTADO del LISTENER
------------------------
Alias                     LISTENER
Versi¾n                   TNSLSNR for 64-bit Windows: Version 19.0.0.0.0 - Production
Fecha de Inicio       03-FEB-2021 18:02:55
Tiempo Actividad   0 dÝas 0 hr. 0 min. 12 seg.
Nivel de Rastreo        off
Seguridad               ON: Local OS Authentication
SNMP                      OFF
Parßmetros del Listener   C:\Users\servidor\Desktop\WINDOWS.X64_193000_db_home\network\admin\listener.ora
Log del Listener          C:\Users\servidor\Desktop\diag\tnslsnr\DESKTOP-IGG1O7P\listener\alert\log.xml
Recibiendo Resumen de Puntos Finales...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DESKTOP-IGG1O7P)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(PIPENAME=\\.\pipe\EXTPROC1521ipc)))
Resumen de Servicios...
El servicio "CLRExtProc" tiene 1 instancia(s).
  La instancia "CLRExtProc", con estado UNKNOWN, tiene 1 manejador(es) para este servicio...
El comando ha terminado correctamente
</pre>

Cuando ya poseamos todas las configuraciones listas, vamos a proceder a crear la conexión entre los servidores.

Pero antes de esto, voy a crear un usuario y alguna tabla que poder consultar, ya que este servidor, es totalmente virgen, por decirlo de alguna forma:

<pre>
C:\Windows\system32>sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on MiÚ Feb 3 18:06:19 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Introduzca el nombre de usuario: system
Introduzca la contrase±a:
Hora de ┌ltima Conexi¾n Correcta: Jue Ene 28 2021 18:56:11 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> CREATE USER c##javierserv2 IDENTIFIED BY contraseña;

Usuario creado.

SQL> GRANT ALL PRIVILEGES TO c##javierserv2;

Concesi¾n terminada correctamente.
</pre>

Vamos a crear la tabla **Marcas**, que será la que consultaremos luego a partir de este [script](images/abd_interconexiones_de_servidores_de_bases_de_datos/scriptoracle.txt):

<pre>
C:\Windows\system32>sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on MiÚ Feb 3 18:07:21 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Introduzca el nombre de usuario: c##javierserv2
Introduzca la contrase±a:

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> create table Marcas
  2  (
  3  Codigo VARCHAR(6),
  4  Nombre VARCHAR(20),
  5  Sede VARCHAR(15),
  6  CONSTRAINT pk_Codigo PRIMARY KEY(Codigo)
  7  );

Tabla creada.

SQL> insert into Marcas(Codigo,Nombre,Sede) values ('000100','VeteCat','Barcelona');

1 fila creada.

SQL> insert into Marcas(Codigo,Nombre,Sede) values ('000200','Nike','Lisboa');

1 fila creada.

SQL> insert into Marcas(Codigo,Nombre,Sede) values ('000300','Danone','New York');

1 fila creada.

SQL> insert into Marcas(Codigo,Nombre,Sede) values ('000400','Samsung','Tokyo');

1 fila creada.

SQL> insert into Marcas(Codigo,Nombre,Sede) values ('000500','Zara','Berlin');

1 fila creada.
</pre>

Ahora sí, vamos a crear el propio enlace.

Para ello nos dirigimos al primer servidor y con el usuario **sys**, crearemos el enlace hacia el segundo servidor.

La sintáxis para crear un enlace es la siguiente:

<pre>
create database link linkserv2
connect to c##javierserv2
identified by contraseña
using 'orcl';
</pre>

Vemos el resultado de la creación del enlace:

<pre>
C:\Windows\system32>sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on MiÚ Feb 3 18:07:21 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Introduzca el nombre de usuario: system
Introduzca la contrase±a:
Hora de ┌ltima Conexi¾n Correcta: Mar Ene 19 2021 19:32:59 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> create database link linkserv2
  2  connect to c##javierserv2
  3  identified by contraseña
  4  using 'orcl';

Enlace con la base de datos creado.
</pre>

Vamos a probar a hacer una consulta desde el primer servidor a la tabla **Marcas** que acabamos de crear y se encuentra en el segundo servidor:

<pre>
SQL> select * from marcas@linkserv2;

CODIGO NOMBRE               SEDE
------ -------------------- ---------------
000100 VeteCat              Barcelona
000200 Nike                 Lisboa
000300 Danone               New York
000400 Samsung              Tokyo
000500 Zara                 Berlin
</pre>

¡Bien! Ya tenemos el enlace creado y utilizable, y por último vamos a realizar una consulta que una la tabla **Tiendas** (tabla almacenada en el primer servidor) y la tabla **Marcas** (tabla almacenada en el segundo servidor):

<pre>

</pre>

Como hemos visto, hemos podido realizar la consulta correctamente, por lo que habríamos terminado este ejercicio.


#### Enlace entre dos servidores de bases de datos PostgreSQL

En este apartado vamos a realizar un enlace entre dos servidores **PostgreSQL**.

*PostgreSQL* hace uso de la extensión `dblink` para realizar o aceptar consultas desde enlaces, por lo que debemos instalar esta herramienta que se encuentra en el paquete llamado `postgresql-contrib`

<pre>
apt install postgresql-contrib -y
</pre>

Hecho esto, procederemos a editar el fichero de configuración de ambos servidores `/etc/postgresql/XXX/main/postgresql.conf`, y en él descomentaremos la línea llamada `listen_addresses`. Como valor le estableceremos la IP que nos interese que escuche nuestro servidor, en mi caso introduzco el valor ***** para que así escuche cualquier petición. De manera que la línea resultante sería la siguiente:

<pre>
listen_addresses = '*'
</pre>

Como segunda modificación, que también debe realizarse en ambos servidores, tenemos que dirigirnos al fichero `/etc/postgresql/XXX/main/pg_hba.conf` y buscar la siguiente línea:

<pre>
host    all             all             127.0.0.1/32            md5
</pre>

Esta línea actualmente define que no se permita la conexión remota, ya que por defecto solo escucha peticiones de *localhost*. Por tanto cambiamos este valor y la línea queda de esta manera:

<pre>
host    all             all             0.0.0.0/0            md5
</pre>

Realizados los cambios, vamos a reiniciar los servicios de los dos servidores para así aplicar los nuevos cambios:

<pre>
systemctl restart postgresql
</pre>






























#### Enlace entre un servidor ORACLE y otro PostgreSQL o MySQL empleando Heterogeneus Services
