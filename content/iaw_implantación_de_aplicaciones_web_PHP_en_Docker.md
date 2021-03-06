Title: Implantación de aplicaciones web PHP en Docker
Date: 2018/03/06
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-docker.png
Tags: Docker, PHP, contenedores, BookMedik

En este artículo voy a realizar el despliegue de varias aplicaciones web escritas en **PHP** en contenedores **Docker**.

Todos los ficheros necesarios y utilizados, se pueden encontrar en [este repositorio](https://github.com/javierpzh/Implantacion-de-aplicaciones-web-PHP-en-Docker) de *GitHub*.

En todos los apartados utilizaremos dos directorios, el llamado `build`, destinado a la construcción, y el segundo directorio, `deploy`, utilizado para el despliegue.


#### Ejecución de la aplicación BookMedik en Docker

En este primer apartado, vamos a ver como sería el proceso para ejecutar la aplicación **BookMedik** en contenedores *Docker*.

En primer lugar, nos situamos en el directorio `build` y en él, clonaremos el siguiente [repositorio](https://github.com/evilnapsis/bookmedik) que contiene la aplicación **BookMedik**.

Hecho esto, nos dirigiremos a nuestro directorio de despliegue, y en él crearemos nuestro fichero `docker-compose.yaml`, que inicialmente va a poseer este contenido:

<pre>
version: "3.1"

services:

  db:
    container_name: bookmedik-mysql
    image: mariadb
    restart: always
    environment:
      MYSQL_DATABASE: bookmedik
      MYSQL_USER: bookmedik
      MYSQL_PASSWORD: bookmedik
      MYSQL_ROOT_PASSWORD: javier
    volumes:
      - /home/javier/Docker/Volumes:/var/lib/mysql
</pre>

Podemos apreciar como hemos definido el despliegue de un contenedor llamado **bookmedik-mysql** basado en una imagen **mariadb**. Como podremos imaginar, este contenedor será el encargado de ejecutar nuestra base de datos. Vamos a crearlo ejecutando el siguiente comando:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea1/deploy$ docker-compose up -d
Creating bookmedik-mysql ... done
</pre>

Bien, ya habríamos generado nuestro primer contenedor, ahora, necesitaremos ejecutar el siguiente *script* que se encargará de crear las tablas/datos imprescindibles para nuestra aplicación. Este *script* se encuentra dentro del repositorio clonado anteriormente y recibe el nombre `schema.sql`. Antes de volcar las instrucciones en nuestra base de datos, debemos comentar la siguiente línea que se encuentra al inicio de este *script*:

<pre>
create database bookmedik;
</pre>

Esto debemos hacerlo, ya que, al crear el primer contenedor que ejecuta *MySQL*, ya hemos creado una base de datos con este nombre.

Hecho esto, podríamos ejecutar el *script*:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea1/deploy$ cat ../build/bookmedik/schema.sql | docker exec -i bookmedik-mysql /usr/bin/mysql -u bookmedik --password=bookmedik bookmedik
</pre>

En este punto, ya disponemos de nuestra base de datos totalmente operativa, por lo que tan sólo nos faltaría crear el contenedor que ejecutará la aplicación. Para ello, crearemos en el directorio `build`, el siguiente fichero `Dockerfile`:

<pre>
FROM debian
MAINTAINER Javier Pérez "javierperezhidalgo01@gmail.com"

EXPOSE 80

ADD bookmedik /var/www/html/
ADD script.sh /usr/local/bin/

RUN apt-get update && apt-get install -y apache2 \
libapache2-mod-php7.3 \
php7.3 \
php7.3-mysql \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& chmod +x /usr/local/bin/script.sh

ENV DATABASE_USER bookmedik
ENV DATABASE_PASSWORD bookmedik
ENV DATABASE_HOST db

ENTRYPOINT ["script.sh"]
</pre>

Por último, en la misma ruta, crearemos un fichero llamado `script.sh` con las siguientes líneas:

<pre>
#!/bin/bash

sed -i 's/$this->user="root";/$this->user="'${DATABASE_USER}'";/g' /var/www/html/core/controller/Database.php
sed -i 's/$this->pass="";/$this->pass="'${DATABASE_PASSWORD}'";/g' /var/www/html/core/controller/Database.php
sed -i 's/$this->host="localhost";/$this->host="'${DATABASE_HOST}'";/g' /var/www/html/core/controller/Database.php

apache2ctl -D FOREGROUND
</pre>

Esto nos ayudará a la hora de la asignación de variables.

Pues ya estaría todo listo, por lo que procederíamos a crear la imagen que posteriormente ejecutará el contenedor de la aplicación:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea1/build$ docker build -t javierpzh/bookmedik:v1 .
Sending build context to Docker daemon  5.774MB
Step 1/10 : FROM debian
 ---> 5890f8ba95f6
Step 2/10 : MAINTAINER Javier Pérez "javierperezhidalgo01@gmail.com"
 ---> Running in 597b0e74a1af
Removing intermediate container 597b0e74a1af
 ---> 2bd74e1c46ca
Step 3/10 : EXPOSE 80
 ---> Running in a626d30acc3a
Removing intermediate container a626d30acc3a
 ---> d5e3b4c5a31a
Step 4/10 : ADD bookmedik /var/www/html/
 ---> e3d721661a67
Step 5/10 : ADD script.sh /usr/local/bin/
 ---> 77688c1696ce
Step 6/10 : RUN apt-get update && apt-get install -y apache2 libapache2-mod-php7.3 php7.3 php7.3-mysql && apt-get clean && rm -rf /var/lib/apt/lists/* && chmod +x /usr/local/bin/script.sh
 ---> Running in 5c9ea292ceb8

 ...

 ---> 217f10aad8e5
Step 7/10 : ENV DATABASE_USER bookmedik
 ---> Running in 33177718555b
Removing intermediate container 33177718555b
 ---> 5c1d72d0d8f7
Step 8/10 : ENV DATABASE_PASSWORD bookmedik
 ---> Running in a81a444faa65
Removing intermediate container a81a444faa65
 ---> e50d8477e7ae
Step 9/10 : ENV DATABASE_HOST db
 ---> Running in 6d5caa1033d8
Removing intermediate container 6d5caa1033d8
 ---> 7a385cbb8132
Step 10/10 : ENTRYPOINT ["script.sh"]
 ---> Running in 4b6348f07a94
Removing intermediate container 4b6348f07a94
 ---> 58e4b5c7dcee
Successfully built 58e4b5c7dcee
Successfully tagged javierpzh/bookmedik:v1
</pre>

Finalizado el proceso, vamos a ver que efectivamente nos ha creado la nueva imagen:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea1/build$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
javierpzh/bookmedik   v1                  58e4b5c7dcee        33 seconds ago      251MB
</pre>

¡Bien! Disponemos de la nueva imagen, por lo que tan sólo nos quedaría crear el contenedor que ejecutará *BookMedik*. Para ello, añadiremos al fichero `docker-compose.yaml`, que creamos anteriormente en el directorio `deploy`, el siguiente bloque:

<pre>
  bookmedik:
    container_name: bookmedik
    image: javierpzh/bookmedik:v1
    restart: always
    ports:
      - 8080:80
    volumes:
      - /home/javier/Docker/Volumes:/var/log/apache2
</pre>

Podemos apreciar como hemos definido un nuevo despliegue, en este caso, se trata de un contenedor llamado **bookmedik** basado en la imagen creada, y que va a *mapear* puertos para que podamos acceder desde nuestro navegador en el puerto 8080. Vamos a crearlo ejecutando el siguiente comando:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea1/deploy$ docker-compose up -d
Creating bookmedik ...
Creating bookmedik ... done
</pre>

Bien, ya habríamos generado nuestro segundo contenedor, por lo que, en teoría, ya dispondríamos de nuestra aplicación. Antes de dirigirnos a nuestro navegador, vamos a listar los contenedores que poseemos activos:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea1/deploy$ docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                  NAMES
5dc207e7d56a        javierpzh/bookmedik:v1   "script.sh"              35 seconds ago      Up 33 seconds       0.0.0.0:8080->80/tcp   bookmedik
aef84a1160f0        mariadb                  "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        3306/tcp               bookmedik-mysql
</pre>

Efectivamente se están ejecutando los dos contenedores, por lo que es el momento de a acceder a la dirección `127.0.0.1:8080`:

![.](images/iaw_implantación_de_aplicaciones_web_PHP_en_Docker/bookmedik1.png)

Vamos a *loguearnos* mediante las credenciales por defecto: **admin/admin**.

![.](images/iaw_implantación_de_aplicaciones_web_PHP_en_Docker/bookmedik2.png)

¡Bien! Vemos como nos muestra la aplicación *BookMedik* por lo que habríamos finalizado este apartado.


#### Creando la imagen de BookMedik a partir de la imagen PHP

En este apartado, vamos a realizar un proceso parecido al anterior, pero en este caso, la imagen del contenedor que ejecutará la aplicación, estará creada a partir de la imagen oficial **PHP**.

Para llevar a cabo este ejercicio, podemos copiar las carpetas `build` y `deploy` que hemos utilizado en el apartado anterior, ya que vamos a hacer unas pequeñas modificaciones, pero gran parte será reutilizada.

En primer lugar, editaremos el fichero `Dockerfile`, y quedará de esta manera:

<pre>
FROM php:7.4-apache
MAINTAINER Javier Pérez "javierperezhidalgo01@gmail.com"

EXPOSE 80

ADD bookmedik /var/www/html/
ADD script.sh /usr/local/bin/

RUN docker-php-ext-install mysqli \
&& chmod +x /usr/local/bin/script.sh

ENV DATABASE_USER bookmedik
ENV DATABASE_PASSWORD bookmedik
ENV DATABASE_HOST db

ENTRYPOINT ["script.sh"]
</pre>

Podemos apreciar como ahora utilizaremos como imagen base la oficial PHP. Hecho esto, construiremos la nueva imagen. En mi caso, le establezco como nombre la versión 2 (**v2**):

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea2/build$ docker build -t javierpzh/bookmedik:v2 .
Sending build context to Docker daemon  5.774MB
Step 1/10 : FROM php:7.4-apache
7.4-apache: Pulling from library/php
45b42c59be33: Already exists
366d949cba16: Already exists
4c65628244f3: Already exists
79a8e4ec25c6: Already exists
3512b0c25baf: Already exists
a983b5b9a384: Already exists
0def93a72fb4: Already exists
b463e75d679a: Already exists
86780b697834: Already exists
7df64f4812c2: Already exists
59f175c32a30: Already exists
5363b603851d: Already exists
93fcdb189245: Already exists
Digest: sha256:e12c1c85cb4b5cd1f656368502be1f927b3d5e4c8a55960b6c0b5795a491aa6a
Status: Downloaded newer image for php:7.4-apache
 ---> 82e6dd286f92
Step 2/10 : MAINTAINER Javier Pérez "javierperezhidalgo01@gmail.com"
 ---> Running in d13aaa14c768
Removing intermediate container d13aaa14c768
 ---> af250719abe4
Step 3/10 : EXPOSE 80
 ---> Running in c2c5bcfa655d
Removing intermediate container c2c5bcfa655d
 ---> 131de1a87b20
Step 4/10 : ADD bookmedik /var/www/html/
 ---> 13cdcb0d4150
Step 5/10 : ADD script.sh /usr/local/bin/
 ---> 62204ccc0568
Step 6/10 : RUN docker-php-ext-install mysqli && chmod +x /usr/local/bin/script.sh
 ---> Running in feb5c30cd507

 ...

 ---> 9400396eb037
Step 7/10 : ENV DATABASE_USER bookmedik
 ---> Running in 6d12571c3783
Removing intermediate container 6d12571c3783
 ---> 4f1c9ea1b416
Step 8/10 : ENV DATABASE_PASSWORD bookmedik
 ---> Running in 23fb39232674
Removing intermediate container 23fb39232674
 ---> bc299d3eacac
Step 9/10 : ENV DATABASE_HOST db
 ---> Running in 8828925c295b
Removing intermediate container 8828925c295b
 ---> 19f8b95c983d
Step 10/10 : ENTRYPOINT ["script.sh"]
 ---> Running in f9db3c9cbc9c
Removing intermediate container f9db3c9cbc9c
 ---> cbf2c1f07b02
Successfully built cbf2c1f07b02
Successfully tagged javierpzh/bookmedik:v2
</pre>

Finalizado el proceso, vamos a ver que efectivamente nos ha creado la nueva imagen:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea2/build$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
javierpzh/bookmedik   v2                  cbf2c1f07b02        1 minute ago        420MB
javierpzh/bookmedik   v1                  58e4b5c7dcee        About an hour ago   251MB
</pre>

Vemos como nos ha creado una nueva versión de nuestra imagen, por lo que ahora, tan sólo nos quedaría modificar en el fichero `docker-compose.yaml`, el bloque relativo al contenedor que ejecutará *BookMedik*, e indicar que haga uso de esta imagen. El contenido total del fichero será el siguiente:

<pre>
version: "3.1"

services:

  db:
    container_name: bookmedik-mysql
    image: mariadb
    restart: always
    environment:
      MYSQL_DATABASE: bookmedik
      MYSQL_USER: bookmedik
      MYSQL_PASSWORD: bookmedik
      MYSQL_ROOT_PASSWORD: javier
    volumes:
      - /home/javier/Docker/Volumes:/var/lib/mysql

  bookmedik:
    container_name: bookmedik
    image: javierpzh/bookmedik:v2
    restart: always
    ports:
      - 8080:80
    volumes:
      - /home/javier/Docker/Volumes:/var/log/apache2
</pre>

Realizamos el despliegue:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea2/deploy$ docker-compose up -d
Recreating bookmedik ...
Recreating bookmedik ... done
</pre>

Ya habríamos reconstruido el contenedor de la aplicación. Antes de dirigirnos a nuestro navegador, vamos a listar los contenedores que poseemos activos:

<pre>
javier@debian:~/Docker/Implantacion-de-aplicaciones-web-PHP-en-Docker/Tarea2/deploy$ docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED              STATUS              PORTS                  NAMES
fd625dd2f9f9        javierpzh/bookmedik:v2   "script.sh"              About a minute ago   Up About a minute   0.0.0.0:8080->80/tcp   bookmedik
aef84a1160f0        mariadb                  "docker-entrypoint.s…"   About an hour ago    Up About an hour    3306/tcp               bookmedik-mysql
</pre>

Efectivamente se están ejecutando los dos contenedores, y podemos observar, como hemos cambiado el contenedor que ejecuta la aplicación mientras que el contenedor que ejecuta la base de datos, sigue siendo el mismo que el del apartado anterior.

Es el momento de a acceder a la dirección `127.0.0.1:8080`:

![.](images/iaw_implantación_de_aplicaciones_web_PHP_en_Docker/tarea2bookmedik1.png)

Vamos a *loguearnos* mediante las credenciales por defecto: **admin/admin**.

![.](images/iaw_implantación_de_aplicaciones_web_PHP_en_Docker/tarea2bookmedik2.png)

¡Bien! Vemos como nos sigue mostrando la aplicación *BookMedik*, pero ahora está ejecutándose en un contenedor creado a partir de una imagen distinta, en esta caso, la oficial de PHP.


## 



































































.
