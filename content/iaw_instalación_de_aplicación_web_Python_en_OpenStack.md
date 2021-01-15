Title: Instalación de aplicación web Python en OpenStack
Date: 2021/01/11
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: OpenStack, Python, Django, virtualenv, git

**En esta tarea vamos a realizar la instalación de un *CMS Python* basado en *Django*. Puedes encontrar varios en el siguiente [enlace](https://djangopackages.org/grids/g/cms/).**

#### Instala el CMS en el entorno de desarrollo. Debes utilizar un entorno virtual.

Vamos a utilizar un repositorio de *GitHub* en el que guardaremos los ficheros que se generen durante la instalación del *CMS*. He creado un nuevo repositorio y lo voy a clonar en la dirección `entornos_virtuales`:

Para clonar dicho repositorio, obviamente necesitamos tener instalado el paquete `git`:

<pre>
apt install git -y
</pre>

Ahora sí, lo clonamos:

<pre>
javier@debian:~/entornos_virtuales$ git clone git@github.com:javierpzh/Web-Python-OpenStack.git
</pre>

En segundo lugar, vamos a crear el entorno virtual donde trabajaremos en el entorno de desarrollo, en mi caso, se encontrará en `entornos_virtuales/Web_Python_OpenStack`. Para crear un entorno virtual necesitamos tener instalado este paquete:

<pre>
apt install python3-venv -y
</pre>

Ya instalado, podemos crear el entorno virtual, y para ello, empleamos el siguiente comando:

<pre>
javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ python3 -m venv webpython
</pre>

Una vez creado, vamos a activarlo mediante el siguiente comando:

<pre>
javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ source webpython/bin/activate
</pre>

Si nos fijamos, vemos como el aspecto del *prompt* ha cambiado y ahora aparece el entorno virtual como activo:

<pre>
(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$
</pre>

Para actualizar `pip`:

<pre>
pip install --upgrade pip
</pre>

Ya tendríamos el entorno virtual listo para trabajar con él.

Llegó el momento de decidir qué CMS instalaremos. En mi caso, he decidido instalar **Mezzanine**.

<pre>
(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ pip install mezzanine
</pre>

Una vez instalado, vamos a crear nuestra web/proyecto con el siguiente comando:

<pre>
(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ mezzanine-project javierpzh
</pre>

Hecho esto, podremos ver como nos ha creado una carpeta con el nombre que hayamos decidido establecerle a nuestro proyecto. Dentro de esta carpeta podremos encontrar varios directorios/ficheros, pero el que nos interesa en este punto es el llamado `local_settings.py`, ya que, en él se encuentra la configuración básica de la base de datos.

<pre>
(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ ls
javierpzh  README.md  webpython

(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack$ cd javierpzh/

(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/javierpzh$ ls
deploy  fabfile.py  javierpzh  manage.py  requirements.txt

(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/javierpzh$ cd javierpzh/

(webpython) javier@debian:~/entornos_virtuales/Web-Python-OpenStack/javierpzh/javierpzh$ ls
__init__.py  local_settings.py  settings.py  urls.py  wsgi.py
</pre>



























#### Personaliza la página (cambia el nombre al blog y pon tu nombre) y añade contenido (algún artículo con alguna imagen).



#### Guarda los ficheros generados durante la instalación en un repositorio *GitHub*. Guarda también en ese repositorio la copia de seguridad de la base de datos. Ten en cuenta que en el entorno de desarrollo vas a tener una base de datos **sqlite**, y en el entorno de producción una **MariaDB**, por lo tanto, es recomendable para hacer la copia de seguridad y recuperarla los comandos: `python manage.py dumpdata` y `python manage.py loaddata`, para [más información](https://coderwall.com/p/mvsoyg/django-dumpdata-and-loaddata).



#### Realiza el despliegue de la aplicación en tu entorno de producción (servidor web y servidor de base de datos en el *cloud*). Utiliza un entorno virtual. Como servidor de aplicación puedes usar *gunicorn* o *uwsgi* (crea una unidad *systemd* para gestionar este servicio). El contenido estático debe servirlo el servidor web. La aplicación será accesible en la URL `python.javierpzh.gonzalonazareno.org`.
