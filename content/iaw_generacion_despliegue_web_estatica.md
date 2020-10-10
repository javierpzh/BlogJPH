Title: Implantación y despliegue de una aplicación web estática
Date: 2020/10/10
Category: Implantación de Aplicaciones Web

## Ejercicios

**1. Selecciona una combinación entre generador de páginas estáticas y servicio donde desplegar la página web. Escribe tu propuesta en redmine, cada propuesta debe ser original.**

He decidido utilizar como generador de páginas estáticas Pelican, ya que utiliza el lenguaje de Python y es el que más he utilizado y el que más controlo. Como servicio donde desplegar la web he decidido utilizar GitHub Pages ya que todos los cambios los iré guardando en un repositorio de mi GitHub.

**2. Comenta la instalación del generador de página estática. Recuerda que el generador tienes que instalarlo en tu entorno de desarrollo. Indica el lenguaje en el que está desarrollado y el sistema de plantillas que utiliza.**

Voy a trabajar en un entorno de desarrollo, para así evitar posibles conflictos a la hora de instalar Pelican y las demás necesidades. Para crear un entorno virtual, antes debemos instalar este paquete:
<pre>
sudo apt-get install python3-venv
</pre>
Ahora ya podemos crear nuestro entorno de desarrollo. Hay que decir que este entorno lo creamos dentro de una carpeta y solo lo podremos activar desde esa carpeta, pero lo vamos a poder utilizar por todas las rutas.
Para crear un entorno:
<pre>
python3 -m venv (nombreentorno)
</pre>
Para activarlo:
<pre>
source (nombreentorno)/bin/activate
</pre>
Si lo hemos activado bien, vemos que ha cambiado el prompt y ahora aparece el nombre del entorno.
Ahora estamos trabajando en un nuevo espacio, que es independiente a los paquetes instalados de nuestro equipo, si queremos ver lo que tenemos en este espacio:
<pre>
pip list
</pre>
Para instalar cualquier paquete, es igual que con 'apt' pero con 'pip'. En mi caso voy a instalar Pelican y Markdown que es el lenguaje que voy a utilizar para crear el contenido de mi web:
<pre>
pip install pelican markdown
</pre>
Pelican es un generador de páginas estáticas libre y que está desarrollado en Python. Utiliza el sistema de plantillas de jinja2. Tiene muchas ventajas ya que le puedes añadir muchos temas y plugins diferentes de una forma muy sencilla, con el objetivo que te centres únicamente en la elaboración del contenido, que se escribirá en un archivo Markdown, este lenguaje es muy simple y muy fácil de aprender, puedes ver un poco [aquí](https://guides.github.com/features/mastering-markdown/).

Para crear un nuevo sitio web con Pelican:
<pre>
(blogjph) javier@debian:~/virtualenv/Pelican/BlogJPH$ pelican-quickstart
Welcome to pelican-quickstart v4.5.0.

This script will help you create a new Pelican-based website.

Please answer the following questions so this script can generate the files
needed by Pelican.

  Where do you want to create your new web site? [.]
  What will be the title of this web site? Javier Pérez Hidalgo
  Who will be the author of this web site? Javier Pérez Hidalgo
  What will be the default language of this web site? [en] es
  Do you want to specify a URL prefix? e.g., https://example.com   (Y/n) n
  Do you want to enable article pagination? (Y/n)
  How many articles per page do you want? [10]
  What is your time zone? [Europe/Paris] Europe/Madrid
  Do you want to generate a tasks.py/Makefile to automate generation and publishing? (Y/n)
  Do you want to upload your website using FTP? (y/N)
  Do you want to upload your website using SSH? (y/N)
  Do you want to upload your website using Dropbox? (y/N)
  Do you want to upload your website using S3? (y/N)
  Do you want to upload your website using Rackspace Cloud Files? (y/N)
  Do you want to upload your website using GitHub Pages? (y/N)
Done. Your new project is available at /home/virtualenv/Pelican/BlogJPH/
(blogjph) javier@debian:~/virtualenv/Pelican/BlogJPH$
</pre>
Si listamos los directorios podemos ver como nos ha creado una serie de carpetas que son las que contendrán el contenido e información de nuestra web.

**3. Configura el generador para cambiar el nombre de tu página, el tema o estilo de la página,… Indica cualquier otro cambio de configuración que hayas realizado.**



**4. Genera un sitio web estático con al menos 3 páginas. Deben estar escritas en Markdown y deben tener los siguientes elementos HTML: títulos, listas, párrafos, enlaces e imágenes. El código que estas desarrollando, configuración del generado, páginas en markdown,… debe estar en un repositorio Git (no es necesario que el código generado se guarde en el repositorio, evitalo usando el fichero .gitignore).**



**5. Explica el proceso de despliegue utilizado por el servicio de hosting que vas a utilizar.**



**6. Piensa algún método (script, scp, rsync, git,…) que te permita automatizar la generación de la página (integración continua) y el despliegue automático de la página en el entorno de producción, después de realizar un cambio de la página en el entorno de desarrollo. Muestra al profesor un ejemplo de como al modificar la página se realiza la puesta en producción de forma automática.**
