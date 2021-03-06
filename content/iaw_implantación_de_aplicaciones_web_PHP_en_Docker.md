Title: Implantación de aplicaciones web PHP en Docker
Date: 2018/03/06
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-docker.png
Tags: Docker

**1. Ejecución de una aplicación web PHP en Docker.**

- Queremos ejecutar en un contenedor *Docker* la aplicación web escrita en *PHP*: [bookMedik](https://github.com/evilnapsis/bookmedik)

- Es necesario tener un contenedor con *MariaDB* donde vamos a crear la base de datos y los datos de la aplicación. El *script* para generar la base de datos y los registros lo encuentras en el repositorio y se llama `schema.sql`. Debes crear un usuario con su contraseña en la base de datos. La base de datos se llama *bookmedik* y se crea al ejecutar el *script*.

- Ejecuta el contenedor *MariaDB* y carga los datos del *script* `schema.sql`. [Para más información](https://gist.github.com/spalladino/6d981f7b33f6e0afe6bb).

- El contenedor *MariaDB* debe tener un volumen para guardar la base de datos.

- El contenedor que creas debe tener un volumen para guardar los *logs* de *Apache2*.

- Crea una imagen *Docker* con la aplicación desde una imagen base de *debian* o *ubuntu*. Ten en cuenta que el fichero de configuración de la base de datos (`core\controller\Database.php`) lo tienes que configurar utilizando las variables de entorno del contenedor *MariaDB*. (Nota: Para obtener las variables de entorno en *PHP* usar la función `getenv`. [Para más infomación](https://www.php.net/manual/es/function.getenv.php).

- La imagen la tienes que crear en tu máquina con el comando `docker build`.

- Crea un *script* con `docker compose` que levante el escenario con los dos contenedores.(Usuario: admin, contraseña: admin).

- **Entrega la URL del repositorio *GitHub* donde tengas la construcción (directorio build y el despliegue (directorio deploy))**
- **Entrega una captura de pantalla donde se vea funcionando la aplicación, una vez que te has *logueado*.**







Vamos a clonar el siguiente [repositorio](https://github.com/evilnapsis/bookmedik) que contiene la aplicación **bookMedik**.

<pre>
javier@debian:~$ mkdir Docker

javier@debian:~$ cd Docker/

javier@debian:~/Docker$ git clone https://github.com/evilnapsis/bookmedik.git
Clonando en 'bookmedik'...
remote: Enumerating objects: 856, done.
remote: Total 856 (delta 0), reused 0 (delta 0), pack-reused 856
Recibiendo objetos: 100% (856/856), 1.90 MiB | 3.63 MiB/s, listo.
Resolviendo deltas: 100% (372/372), listo.

javier@debian:~/Docker$ ls
bookmedik

javier@debian:~/Docker$ ls bookmedik/
assets  core  index.php  instalation.txt  logout.php  PhpWord  README.md  report  schema.sql
</pre>


























**2. Ejecución de una aplicación web PHP en Docker.**

- Realiza la imagen *Docker* de la aplicación a partir de la imagen oficial *PHP* que encuentras en *DockerHub*. Lee la documentación de la imagen para configurar una imagen con *Apache2* y *PHP*, además seguramente tengas que instalar alguna extensión de *PHP*.

- Crea esta imagen en *DockerHub*.

- Crea un *script* con `docker compose` que levante el escenario con los dos contenedores.

- **Entrega la URL del repositorio *GitHub* donde tengas la construcción (directorio build y el despliegue (directorio deploy))**
- **Entrega una captura de pantalla donde se vea funcionando la aplicación, una vez que te has *logueado*.**





















.
