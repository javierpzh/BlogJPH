Title: Introducción a Docker
Date: 2021/02/08
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: Docker



--------------------------------------------------------------------------------
## Almacenamiento

#### 1. Vamos a trabajar con volúmenes docker:

- **Crea un volumen docker que se llame `miweb`.**

Creamos el nuevo volumen:

<pre>
javier@debian:~$ docker volume create miweb
miweb

javier@debian:~$ docker volume ls
DRIVER              VOLUME NAME
local               051b59979e0527c228be360c9b7568856a8cf37b16b9ce415f3e5fa48b812891
local               e1be424428521f02e06f73a92c2100b8cc42aaf813680bc3ee792c1353ae3abf
local               miweb
</pre>

Listo.

- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html`, (que sabemos que es el *document root* del servidor que nos ofrece esa imagen) el volumen docker que has creado.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker pull php:7.4-apache
7.4-apache: Pulling from library/php
a076a628af6f: Already exists
02bab8795938: Already exists
657d9d2c68b9: Already exists
f47b5ee58e91: Already exists
2b62153f094c: Already exists
60b09083723b: Already exists
1701d4d0a478: Already exists
bae0c4dc63ea: Already exists
a1c05958a901: Already exists
5964d339be93: Already exists
1319bb6aacaa: Already exists
71860efe761d: Already exists
c5a84dbdd6a5: Already exists
Digest: sha256:584d2109fa4f3f0cf25358828254dc5668882167634384ad68537a3069d31652
Status: Downloaded newer image for php:7.4-apache

javier@debian:~$ docker run -d --name pruebavolumendocker -v miweb:/var/www/html -p 8080:80 php:7.4-apache
9b350c4f505b085d9633f8f46bb3a200266d4d09785c6311adae82daf1834403
</pre>

Listo.

- **Utiliza el comando `docker cp` para copiar un fichero `info.php` en el directorio `/var/www/html`.**

Copiamos el archivo `info.php`:

<pre>
javier@debian:~$ docker cp info.php pruebavolumendocker:/var/www/html
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`.**

Nos dirigimos a la dirección `http://localhost:8080/info.php`:

![.](images/iaw_introducción_a_docker/info.php.png)

Efectivamente podemos visualizar el fichero `info.php`.

- **Borra el contenedor.**

Eliminamos el contenedor:

<pre>
javier@debian:~$ docker rm -f pruebavolumendocker
pruebavolumendocker
</pre>

Listo.

- **Crea un nuevo contenedor y monta el mismo volumen como en el ejercicio anterior.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker run -d --name pruebavolumendocker2 -v miweb:/var/www/html -p 8080:80 php:7.4-apache
4fe9ed47558cbc4e44c73c2d4507228828bf003048c137491df434ec6e3ca58c
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`. ¿Seguía existiendo ese fichero?**

Podemos ver que sí, ya que estamos utilizando el mismo volumen.

![.](images/iaw_introducción_a_docker/info.php2.png)



#### 2. Vamos a trabajar con bind mount:

- **Crea un directorio en tu *host* y dentro crea un fichero `index.html`.**

Creamos el directorio y el fichero:

<pre>
javier@debian:~$ mkdir pruebadocker

javier@debian:~$ nano pruebadocker/index.html
</pre>

Listo.

- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html` el directorio que has creado por medio de bind mount.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker run -d --name bindmount -v /home/javier/pruebadocker:/var/www/html -p 8080:80 php:7.4-apache
6796f397cf0f9c1331778dc917caff72885bf3e594272d46e1fa65f3b58c686f
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `index.html`.**

Nos dirigimos a la dirección `http://localhost:8080`:

![.](images/iaw_introducción_a_docker/bindmount1.png)

Podemos visualizar la información.

- **Modifica el contenido del fichero `index.html` en tu *host* y comprueba que al refrescar la página ofrecida por el contenedor, el contenido ha cambiado.**

Modificamos el contenido del fichero `index.html`:

<pre>
javier@debian:~$ nano pruebadocker/index.html
</pre>

Nos dirigimos a la dirección `http://localhost:8080`:

![.](images/iaw_introducción_a_docker/bindmount2.png)

Efectivamente ha cambiado el contenido.

- **Borra el contenedor**

Eliminamos el contenedor:

<pre>
javier@debian:~$ docker rm -f bindmount
bindmount
</pre>

Listo.

- **Crea un nuevo contenedor y monta el mismo directorio como en el ejercicio anterior.**

Creamos el contenedor:

<pre>
javier@debian:~$ docker run -d --name bindmount2 -v /home/javier/pruebadocker:/var/www/html -p 8080:80 php:7.4-apache
5a1d596d751ae93fb1acc99f32f830573e89652cfb5d3a4900cfc9c835ea2fdb
</pre>

Listo.

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `index.html`. ¿Se sigue viendo el mismo contenido?**

Al igual que en el ejercicio anterior, podemos ver que sí, ya que estamos utilizando el mismo volumen.

![.](images/iaw_introducción_a_docker/bindmount2.png)


####Contenedores con almacenamiento persistente

- **Crea un contenedor desde la imagen *Nextcloud* (usando *sqlite*) configurando el almacenamiento como nos muestra la documentación de la imagen en *Docker Hub* (pero utilizando bind mount). Sube algún fichero.**

Creamos el contenedor:

<pre>
javier@debian:~$ mkdir nextcloud

javier@debian:~$ docker run -d --name Nextcloud -v /home/javier/nextcloud:/var/www/html -p 8080:80 nextcloud
1fd90edb9161d28a68c58799ddeea2c58ce0acec3e85663997baae9987709274
</pre>

Nos dirigimos a la dirección `http://localhost:8080`:

![.](images/iaw_introducción_a_docker/nextcloud.png)

Lo instalamos con una base de datos **sqlite** y una vez lo tengamos instalado, subimos cualquier fichero. En mi caso he subido el fichero llamado **logojp.jpg**.

![.](images/iaw_introducción_a_docker/nextcloud2.png)

Listo.

- **Elimina el contenedor.**

Eliminamos el contenedor:

<pre>
javier@debian:~$ docker rm -f Nextcloud
Nextcloud
</pre>

Listo.

- **Crea un contenedor nuevo con la misma configuración de volúmenes. Comprueba que la información que teníamos (ficheros, usuaurio, …), sigue existiendo.**

Creamos el nuevo contenedor llamado **Nextcloud2**:

<pre>
javier@debian:~$ docker run -d --name Nextcloud2 -v /home/javier/nextcloud:/var/www/html -p 8080:80 nextcloud
b102fd06e36cba2e26db09414359892e3ad403a64715f7e4311cad460b2d7684
</pre>

Nos dirigimos a la dirección `http://localhost:8080`:

![.](images/iaw_introducción_a_docker/nextcloud3.png)

Podemos ver como esta vez no nos pide instalar la aplicación, sino que directamente nos pide que iniciemos sesión. Iniciamos sesión con el usuario creado anteriormente y visualizamos los archivos:

![.](images/iaw_introducción_a_docker/nextcloud4.png)

Efectivamente se encuentra el logo que hemos subido en el anterior contenedor, por lo que no hemos perdido la información al eliminar el contenedor.

- **Comprueba el contenido de directorio que se ha creado en el *host*.**

Visualizamos el contenido del directorio `/home/javier/nextcloud`:

<pre>
javier@debian:~/nextcloud$ ls
3rdparty  config       core         data        lib           ocs           remote.php  status.php
apps      console.php  cron.php     index.html  occ           ocs-provider  resources   themes
AUTHORS   COPYING      custom_apps  index.php   ocm-provider  public.php    robots.txt  version.php
</pre>

Podemos ver como efectivamente se encuentran todos los datos de la web.


## Redes

#### Instalación de WordPress

Para la instalación de WordPress necesitamos dos contenedores: la base de datos (imagen *mariadb*) y el servidor web con la aplicación (imagen *wordpress*). Los dos contenedores tienen que estar en la misma red y deben tener acceso por nombres (resolución DNS), ya que en un principio no sabemos que IP va a poseer cada contenedor. Por lo tanto vamos a crear los contenedores en la misma red:

<pre>
docker network create red_wp
</pre>

Siguiendo la documentación de la imagen *mariadb* y la imagen *wordpress* podemos ejecutar los siguientes comandos para crear los dos contenedores:

<pre>
docker run -d --name servidor_mysql \
           --network red_wp \
           -v /opt/mysql_wp:/var/lib/mysql \
           -e MYSQL_DATABASE=bd_wp \
           -e MYSQL_USER=user_wp \
           -e MYSQL_PASSWORD=asdasd \
           -e MYSQL_ROOT_PASSWORD=asdasd \
           mariadb

...

docker run -d --name servidor_wp \
             --network red_wp \
             -v /opt/wordpress:/var/www/html/wp-content \
             -e WORDPRESS_DB_HOST=servidor_mysql \
             -e WORDPRESS_DB_USER=user_wp \
             -e WORDPRESS_DB_PASSWORD=asdasd \
             -e WORDPRESS_DB_NAME=bd_wp \
             -p 80:80 \
             wordpress

...

docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
5b2c5a82a524        wordpress           "docker-entrypoint.s…"   9 minutes ago       Up 9 minutes        0.0.0.0:80->80/tcp   servidor_wp
f70f22aed3d1        mariadb             "docker-entrypoint.s…"   9 minutes ago       Up 9 minutes        3306/tcp             servidor_mysql
</pre>

Algunas observaciones:

- El contenedor *servidor_mysql* ejecuta un *script* `docker-entrypoint.sh` que es el encargado, a partir de las variables de entorno, de configurar la base de datos: crea un usuario, crea la base de datos, cambia la contraseña del usuario *root*, ... y termina ejecutando el servidor *mariadb*.

- Al crear la imagen *mariadb* han tenido en cuenta de que tiene que permitir la conexión desde otra máquina, por lo que en la configuración tenemos comentado el parámetro `bind-address`.

- Del mismo modo, el contenedor *servidor_wp* ejecuta un *script* `docker-entrypoint.sh`, que entre otras cosas, a partir de las variables de entorno, ha creado el fichero `wp-config.php` de *wordpress*, por lo que durante la instalación no nos pedirá las credenciales de la base de datos.

- Si nos fijamos, la variable de entorno `WORDPRESS_DB_HOST` la hemos inicializado al nombre del servidor de base de datos. Como ambos contenedores están conectados a la misma red definida por el usuario, el contenedor *wordpress* al intentar acceder al nombre *servidor_mysql*, estará accediendo al contenedor de la base de datos.

- El servicio al que vamos a acceder desde el exterior es al servidor web, es por lo que hemos mapeado los puertos con la opción `-p`. Sin embargo, en el contenedor de la base de datos no es necesario mapear los puertos porque no vamos a acceder a ella desde el exterior. Eso sí, el contenedor *servidor_wp*, sí puede acceder al puerto 3306 del *servidor_mysql* sin problemas, ya que están conectados a la misma red.


#### Ejercicios

- **Ejecuta una instrucción docker para visualizar el contenido del fichero `wp-config.php` y verifica que los parámetros de conexión a la base de datos son los mismo que los indicados en las variables de entorno.**



- **Ejecuta una instrucción docker para comprobar que desde el *servidor_wp* podemos hacer *ping* usando el nombre *servidor_mysql*. (Tendrás que instalar el paquete `iputils-ping` en el contenedor).**



- **Visualiza el fichero `/etc/mysql/mariadb.conf.d/50-server.cnf` del contenedor con la base de datos y comprueba cómo está configurado el parámetro `bind-address`.**



- **Instala otro CMS PHP siguiendo la documentación de [Docker Hub](https://hub.docker.com/) de la aplicación seleccionada.**








































.
