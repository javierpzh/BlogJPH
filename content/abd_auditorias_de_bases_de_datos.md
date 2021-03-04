Title: Auditorías de bases de datos
Date: 2018/03/04
Category: Administración de Bases de Datos
Header_Cover: theme/images/banner-basededatos.png
Tags: Base de Datos, Oracle, MySQL, MariaDB, PostgreSQL, MongoDB

## Oracle

#### Vamos a activar las auditorías en nuestro servidor.

Por defecto, *Oracle* incorpora las auditorías activadas, pero aún así, si queremos comprobar dicho funcionamiento por nosotros mismos, podríamos ejecutar la siguiente sentencia:

<pre>
SQL> SELECT name, value
  2  FROM v$parameter
  3  WHERE name like 'audit_trail';

NAME
--------------------------------------------------------------------------------
VALUE
--------------------------------------------------------------------------------
audit_trail
DB
</pre>

Podemos ver que efectivamente están activadas, ya que el parámetro `audit_trail`, posee el valor `db`, lo cual quiere decir que las auditorías se encuentran activadas y que los registros se almacenan en la base de datos.

En caso de que estuviesen desactivadas, es decir, que el parámetro `audit_trail`, posea el valor `NONE`, podríamos activarlas ejecutando la siguiente sentencia:

<pre>
ALTER SYSTEM SET audit_trail=db scope=spfile;
</pre>

Listo.

#### Vamos a activar la auditoría de los intentos de acceso fallidos al sistema.

En este apartado vamos a activar la auditoría que se encarga de detectar los intentos de acceso fallidos:

<pre>
SQL> AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

Auditoria terminada correctamente.
</pre>

Una vez habilitada, para comprobar su funcionamiento, realizaremos un inicio de sesión erróneo y posteriormente, visualizaremos como se ha registrado dicho intento de acceso:

<pre>
SQL> connect usuarioerror/error
ERROR:
ORA-01017: nombre de usuario/contrase?a no validos; conexion denegada

SQL> connect sysdba
Introduzca la contrase?a:
...

SQL> SELECT os_username, username, extended_timestamp, action_name, returncode
  2  FROM DBA_AUDIT_SESSION;

OS_USERNAME
--------------------------------------------------------------------------------
USERNAME
--------------------------------------------------------------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
ACTION_NAME		     RETURNCODE
---------------------------- ----------
oracle
USUARIOERROR
04/03/21 15:38:26,163150 +01:00
LOGON				   1017
</pre>

Podemos ver como efectivamente nos muestra el intento de acceso fallido, además del nombre de usuario utilizado, la fecha exacta, ...


#### Vamos a activar la auditoría de las operaciones DML realizadas por SCOTT.

En este apartado vamos a activar la auditoría de las operaciones DML realizadas por SCOTT, para ello ejecutamos la siguiente sentencia SQL:

<pre>
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTT;

Auditoria terminada correctamente.
</pre>

Una vez habilitada, para comprobar su funcionamiento, realizaremos un *INSERT*, un *UPDATE* y un *DELETE* y posteriormente, visualizaremos como se han registrado en dicha auditoría:

<pre>
SQL> INSERT INTO DEPT (DEPTNO, DNAME, LOC) VALUES (50,'Pruebas','Sevilla');

1 fila creada.

SQL> UPDATE DEPT SET LOC='Dos Hermanas' WHERE DEPTNO=50;

1 fila actualizada.

SQL> DELETE FROM DEPT WHERE DEPTNO=50;

1 fila suprimida.

SQL> SELECT username, obj_name, action_name, extended_timestamp
  2  FROM DBA_AUDIT_OBJECT;

USERNAME
------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME
----------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
DEPT
INSERT
04/03/21 16:21:19,163150 +01:00


USERNAME
------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME
----------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
DEPT
UPDATE
04/03/21 16:21:28,264893 +01:00


USERNAME
------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME
----------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
DEPT
DELETE
04/03/21 16:21:43,371902 +01:00
</pre>








#### Vamos a realizar una auditoría de grano fino para almacenar información sobre la inserción de empleados del departamento 10 en la tabla EMP de SCOTT.


#### Diferencias entre auditar una operación by access o by session.


#### Diferencias entre los valores db y db, extended del parámetro audit_trail. Demuéstralas poniendo un ejemplo de la información sobre una operación concreta recopilada con cada uno de ellos.


#### Localiza en Enterprise Manager las posibilidades para realizar una auditoría e intenta repetir con dicha herramienta los apartados 1, 3 y 4.































## PostgreSQL

#### Averigua si en PostgreSQL se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.




## MySQL

#### Averigua si en MySQL se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.




## MongoDB

#### Averigua las posibilidades que ofrece MongoDB para auditar los cambios que va sufriendo un documento.


#### Averigua si en MongoDB se pueden auditar los accesos al sistema.




















.
