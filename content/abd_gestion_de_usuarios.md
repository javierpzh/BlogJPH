Title: Gestión de Usuarios de bases de datos
Date: 2018/01/12
Category: Administración de Bases de Datos
Header_Cover: theme/images/banner-basededatos.png
Tags: Base de Datos, Oracle, MySQL, MariaDB, PostgreSQL, MongoDB

## Oracle

**1. Realiza un procedimiento llamado `MostrarObjetosAccesibles` que reciba un nombre de usuario y muestre todos los objetos a los que tiene acceso.**



**2. Realiza un procedimiento que reciba un nombre de usuario, un privilegio y un objeto y nos muestre el mensaje 'SI, DIRECTO' si el usuario tiene ese privilegio sobre objeto concedido directamente, 'SI, POR ROL' si el usuario lo tiene en alguno de los roles que tiene concedidos y un 'NO' si el usuario no tiene dicho privilegio.**



**3. Escribe una consulta que obtenga un *script* para quitar el privilegio de borrar registros en alguna tabla de *SCOTT* a los usuarios que lo tengan.**



**4. Crea un *tablespace* TS2 con tamaño de extensión de 256K. Realiza una consulta que genere un *script* que asigne ese *tablespace* como *tablespace* por defecto a los usuarios que no tienen privilegios para consultar ninguna tabla de *SCOTT*, excepto a *SYSTEM*.**



**5. La vida de un *DBA* es dura. Tras pedirlo insistentemente, en tu empresa han contratado una persona para ayudarte. Decides que se encargará de las siguientes tareas:**

- **Resetear los archivos de *log* en caso de necesidad.**

- **Crear funciones de complejidad de contraseña y asignárselas a usuarios.**

- **Eliminar la información de *rollback*. (este privilegio podrá pasarlo a quien quiera).**

- **Modificar información existente en la tabla dept del usuario scott. (este privilegio podrá pasarlo a quien quiera).**

- **Realizar pruebas de todos los procedimientos existentes en la base de datos.**

- **Poner un *tablespace* fuera de línea.**

**Crea un usuario llamado `Ayudante` y, sin usar los roles predefinidos de *Oracle*, dale los privilegios mínimos para que pueda resolver dichas tareas.**

**Pista: Si no recuerdas el nombre de un privilegio, puedes buscarlo en el diccionario de datos.**



**6. Muestra el texto de la última sentencia *SQL* que se ejecuto en el servidor, junto con el número de veces que se ha ejecutado desde que se cargó en el *Shared Pool* y el tiempo de CPU empleado en su ejecución.**



**7. Realiza un procedimiento que genere un *script* que cree un rol conteniendo todos los permisos que tenga el usuario cuyo nombre reciba como parámetro, le hayan sido asignados a aquel directamente o a través de roles. El nuevo rol deberá llamarse `BackupPrivsNombreUsuario`.**




## MySQL

**1. Escribe una consulta que obtenga un *script* para quitar el privilegio de borrar registros en alguna tabla de *SCOTT* a los usuarios que lo tengan.**




## PostgreSQL

**1. Escribe una consulta que obtenga un *script* para quitar el privilegio de borrar registros en alguna tabla de *SCOTT* a los usuarios que lo tengan.**




## MongoDB

**1. Averigua si existe la posibilidad en *MongoDB* de limitar el acceso de un usuario a los datos de una colección determinada.**



**2. Averigua si en *MongoDB* existe el concepto de privilegio del sistema y muestra las diferencias más importantes con *Oracle*.**



**3. Explica los roles por defecto que incorpora *MongoDB* y como se asignan a los usuarios.**

Primeramente veo conveniente explicar lo que es un **rol**.

Un *rol* se define como un conjunto de privilegios. Cuando a un usuario se le asigna un rol, los privilegios de ese rol son accesibles por el usuario.

Un privilegio define una acción o acciones que se pueden efectuar sobre un recurso. Los recursos pueden ser de varios tipos:

- Una base de datos.
- Una colección.
- Un conjunto de colecciones.
- A nivel de *cluster*: representa operaciones sobre el conjunto de réplicas o el *cluster* de *shards*.

Un rol puede además heredar privilegios de uno o varios roles.

*MongoDB* dispone de dos tipos de roles:

- **Roles predefinidos en el sistema:** son los que ya se encuentran creados de manera predeterminada y listos para utilizarse.

- **Roles definidos por el usuario:** son los creados por el administrador del sistema.

En este caso, nos interesan los **roles predefinidos**.

Dentro de éstos, podemos clasificar los distintos roles en varias categorías.

- Roles de usuarios de bases de datos

- Roles de administradores de base de datos

- Roles de administradores de *cluster*

- Roles de copias de seguridad/restauración

- Roles de superusuarios

Ahora sí, vamos a ver cada uno de los roles que existen en *MongoDB*.

#### Roles de usuarios de bases de datos

- **Roles que actúan a nivel de base de datos**

    - `read`: permite leer datos de todas las colecciones.

    - `readWrite`: permite leer y escribir datos de todas las colecciones.


#### Roles de administradores de bases de datos

- **Roles que actúan a nivel de base de datos**

    - `dbAdmin`: permite realizar tareas administrativas.

    - `userAdmin`: permite crear y modificar usuarios y roles en la base de datos actual

    - `dbOwner`: puede efectuar cualquier operación administrativa en la base de datos. Por lo tanto, junta los privilegios de `readWrite`, `dbAdmin` y `userAdmin`.


#### Roles de administradores de *cluster*

- **Roles que actúan a nivel de todo el sistema**

    - `clusterMonitor`: permite acceso de solo lectura a las herramientas de supervisión.

    - `clusterManager`: permite realizar acciones de administración y monitorización en el *cluster*.

    - `hostManager`: permite monitorizar y administrar servidores.

    - `clusterAdmin`: combina los tres roles anteriores, añadiendo además la acción `dropDatabase`.


#### Roles de copias de seguridad/restauración

- **Roles que actúan a nivel de base de datos**

    - `backup`:

    - `restore`:


#### Roles de todas las bases de datos

- **Roles que actúan a nivel de todas las bases de datos**

    - `readAnyDatabase`:

    - `readWriteAnyDatabase`:

    - `userAdminAnyDatabase`:

    - `dbAdminAnyDatabase`:


#### Roles de superusuarios

- **No son roles de superusuario directamente, pero pueden asignar a cualquier usuario cualquier privilegio en cualquier base de datos, también ellos mismos.**

    - `userAdmin`:

    - `dbOwner`:

    - `userAdminAnyDatabase`:

- **Roles que actúan a nivel de todo el sistema**

    - `root`:














**4. Explica como puede consultarse el diccionario de datos de *MongoDB* para saber que roles han sido concedidos a un usuario y qué privilegios incluyen.**

















.
