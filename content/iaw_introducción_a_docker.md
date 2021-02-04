Title: Introducción a Docker
Date: 2021/02/04
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: Docker



--------------------------------------------------------------------------------
## Almacenamiento

#### 1. Vamos a trabajar con volúmenes docker:

- **Crea un volumen docker que se llame `miweb`.**



- **Crea un contenedor desde la imagen `php:7.4-apache` donde montes en el directorio `/var/www/html` (que sabemos que es el *document root* del servidor que nos ofrece esa imagen) el volumen docker que has creado.**



- **Utiliza el comando `docker cp` para copiar un fichero `info.php` en el directorio `/var/www/html`.**



- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`.**



- **Borra el contenedor.**



- **Crea un nuevo contenedor y monta el mismo volumen como en el ejercicio anterior.**



- **Accede al contenedor desde el navegador para ver la información ofrecida por el fichero `info.php`. ¿Seguía existiendo ese fichero?**




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
