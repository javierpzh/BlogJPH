Title: Introducción a Docker
Date: 2021/02/04
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: Docker



--------------------------------------------------------------------------------
## Almacenamiento

#### 1. Vamos a trabajar con volúmenes docker:

- **Crea un volumen docker que se llame `miweb`.**

<pre>
javier@debian:~$ docker volume create miweb
miweb

javier@debian:~$ docker volume ls
DRIVER              VOLUME NAME
local               051b59979e0527c228be360c9b7568856a8cf37b16b9ce415f3e5fa48b812891
local               e1be424428521f02e06f73a92c2100b8cc42aaf813680bc3ee792c1353ae3abf
local               miweb
</pre>

- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html`, (que sabemos que es el *document root* del servidor que nos ofrece esa imagen) el volumen docker que has creado.**

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

- **Utiliza el comando `docker cp` para copiar un fichero `info.php` en el directorio `/var/www/html`.**

<pre>
javier@debian:~$ docker cp info.php pruebavolumendocker:/var/www/html
</pre>

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`.**

![.](images/iaw_introducción_a_docker/info.php.png)

- **Borra el contenedor.**

<pre>

</pre>

- **Crea un nuevo contenedor y monta el mismo volumen como en el ejercicio anterior.**

<pre>

</pre>

- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`. ¿Seguía existiendo ese fichero?**

<pre>

</pre>


#### 2. Vamos a trabajar con bind mount:

- **Crea un directorio en tu *host* y dentro crea un fichero `index.html`.**



- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html` el directorio que has creado por medio de bind mount.**



- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `index.html`.**



- **Modifica el contenido del fichero `index.html` en tu *host* y comprueba que al refrescar la página ofrecida por el contenedor, el contenido ha cambiado.**



- **Borra el contenedor**



- **Crea un nuevo contenedor y monta el mismo directorio como en el ejercicio anterior.**



- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `index.html`. ¿Se sigue viendo el mismo contenido?**




####Contenedores con almacenamiento persistente

- **Crea un contenedor desde la imagen *Nextcloud* (usando *sqlite*) configurando el almacenamiento como nos muestra la documentación de la imagen en *Docker Hub* (pero utilizando bind mount). Sube algún fichero.**



- **Elimina el contenedor.**



- **Crea un contenedor nuevo con la misma configuración de volúmenes. Comprueba que la información que teníamos (ficheros, usuaurio, …), sigue existiendo.**



- **Comprueba el contenido de directorio que se ha creado en el *host*.**



.
