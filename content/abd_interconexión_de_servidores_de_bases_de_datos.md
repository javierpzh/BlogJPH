Title: Interconexiones de Servidores de bases de datos
Date: 2018/01/28
Category: Administración de Bases de Datos
Header_Cover: theme/images/banner-basededatos.png
Tags: Base de Datos, Oracle, MySQL, MariaDB, PostgreSQL

**Las interconexiones de servidores de bases de datos son operaciones que pueden ser muy útiles en diferentes contextos. Básicamente, se trata de acceder a datos que no están almacenados en nuestra base de datos, pudiendo combinarlos con los que ya tenemos.**

**En este artículo veremos varias formas de crear un enlace entre distintos servidores de bases de datos. Los servidores enlazados siempre estarán instalados en máquinas diferentes.**

**Hay que decir que trabajaré sobre los escenarios creados en el *post* anterior, que trataba sobre [Instalación de Servidores y Clientes de bases de datos](https://javierpzh.github.io/instalacion-de-servidores-y-clientes-de-bases-de-datos.html), por lo que ya dispongo de los servidores instalados y con las configuraciones básicas.**

#### Enlace entre dos servidores de bases de datos ORACLE

En este primer caso, vamos a ver que configuraciones son necesarias para enlazar dos servidores **Oracles**.

Nos situamos en la primera de las máquinas, que recordemos que recibe el nombre de **servidor**.

Nos dirigiremos a los ficheros `listener.ora` y `tnsname.ora`, ambos se encuentran en la ruta `$ORACLE_HOME/network/admin`, ya que en ellos es donde realizaremos la configuración.

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























#### Enlace entre dos servidores de bases de datos Postgres


#### Enlace entre un servidor ORACLE y otro PostgreSQL o MySQL empleando Heterogeneus Services
