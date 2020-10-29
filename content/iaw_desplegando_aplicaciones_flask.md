Title: Desplegando aplicaciones flask
Date: 2020/10/29
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: virtualenv, Apache, python3


## Desplegando aplicaciones flask

### Despliegue en el entorno de desarrollo

Vamos a trabajar con la aplicación flask_temperaturas que puedes encontrar en el siguiente enlace: [https://github.com/josedom24/flask_temperaturas](https://github.com/josedom24/flask_temperaturas).

Clona el repositorio en tu equipo, mira las versiones de los paquetes necesarios para que la aplicación funcione en el fichero `requirements.txt` y responde las siguientes preguntas:

**1. ¿Podríamos instalar estos paquetes con `apt`?**

Podríamos instalar estos paquetes con *apt* pero con diferentes versiones, ya que los paquetes de los repositorios Debian no poseen las últimas versiones de muchos paquetes.

**2. ¿Sería buena idea instalar como root estos paquetes en el sistema con `pip`?**



**3. ¿Cómo sería la mejor manera de instalar estos paquetes?**

En un entorno virtual creado con **Python**, para que no interfiera con la paquetería instalada en el equipo.

#### Trabajamos con entornos virtuales

**Crea un entorno virtual con el módulo `venv` e instala en él los paquetes necesarios para que el programa funcione. Una vez instalado, ejecuta la aplicación con el servidor de desarrollo y comprueba que funciona.**

Para crear un entorno virtual con *python3*:

<pre>
python3 -m venv desplegandoaplicacionflask
</pre>

Vamos a actualizar el paquete `pip` para evitar problemas al instalar paquetes:

<pre>
pip install --upgrade pip
</pre>

Como hemos clonado el repositorio que contiene el archivo `requirements.txt`, podemos hacer una instalación de todos esos paquetes con un solo comando:

<pre>
pip install -r requirements.txt
</pre>


### Despliegue en el entrono de producción

¿Cómo podemos hacer que un servidor web como apache2 sea capaz de servir una aplicación escrita en python? Para ello se utiliza un protocolo que nos permite comunicar al servidor web con la aplicación web: **WSGI (Web Server Gateway Interface)**.

Es decir, el protocolo WSGI define las reglas para que el servidor web se comunique con la aplicación web. Cuando al servidor llega una petición que tenemos que mandar a la aplicación web python tenemos al menos dos cosas que tener en cuenta:

- Tenemos un fichero de entrada, es decir la petición siempre se debe enviar un único fichero., Este fichero se llama fichero WSGI.
- La aplicación web python con la que se comunica el servidor web utilizando el protocolo WSGI se debe llama `application`. Por lo tanto el fichero WSGI entre otras cosas debe nombrar a la aplicación de esta manera.

#### Configuración de apache2 para servir una aplicación web flask

Lo primero que tenemos que hacer es instalar el módulo de apache2, `wsgi`:

<pre>
apt install libapache2-mod-wsgi-py3
</pre>

- Suponemos que tenemos un servidor web apache2 con el módulo wsgi activado.
- Suponemos que nuestra aplicación se encuentra en `/var/www/html/flask_temperatura`.
- Suponemos que hemos creado un entorno virtual con los paquetes instalados en `/home/debian/venv/flask`.

#### Creación del fichero wsgi

Lo primero que vamos a hacer es crear el fichero WSGI, que vamos a llamar app.wsgi estará en `/var/www/html/flask_temperatura` y tendrá el siguiente contenido:

<pre>
from app import app as application
</pre>

Veamos:

- El primer `app` corresponde con el nombre del módulo, es decir del fichero del programa, en nuestro caso se llama `app.py`.
- El segundo `app` corresponde a la aplicación flask creada en `app.py: app = Flask(__name__)`.
- Importamos la aplicación flask, pero la llamamos `application` necesario para que el servidor web pueda enviarle peticiones.

#### Configuración de apache2

Yo he utilizado el virtualhost por defecto, si usamos otro virtualhost esta configuración ira en el fichero correspondiente:

<pre>
#ServerName www.example.org
DocumentRoot /var/www/html/flask_temperaturas
WSGIDaemonProcess flask_temp user=www-data group=www-data processes=1 threads=5 python-path=/var/www/html/flask_temperaturas:/home/debian/venv/flask/lib/python3.7/site-packages
WSGIScriptAlias / /var/www/html/flask_temperaturas/app.wsgi

<Directory /var/www/html/flask_temperaturas>
        WSGIProcessGroup flask_temp
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
<\/Directory>
</pre>

Vamos a explicar la configuración:

- En el `DocumentRoot` se indica el directorio donde está la aplicación. Realmente el servidor web siempre va a llamar al fichero WSGI `app.wsgi`, pero el DocumentRoot es necesario por si hay contenido estático.
- La línea **WSGIDaemonProcess**: Se define un grupo de procesos que se van a encargar de ejecutar la aplicación (servidor de aplicaciones). A estos procesos se le ponen un nombre (`flask_temp`), se indican el usuario y el grupo que van a utilizar (en este caso el mismo que el del servidor web), se indica el número de procesos (`process`) e hilos (`threads`) que va a tener cada proceso, y finalmente se indica los directorios donde se encuentran la aplicación y los paquetes necesarios (`python-path`), como puedes observar se pone el directorio donde esta la aplicación y el directorio donde se encuentran los paquetes en el entorno virtual, separados por dos puntos.
- La directiva `WSGIScriptAlias` nos permite indicar que programa se va a ejecutar (el fichero WSGI: `/var/www/html/flask_temperaturas/app.wsgi`) cuando se haga una petición a la url `/`.
- La sección `Directory` nos permite asignar el proceso creado anteriormente (`WSGIProcessGroup flask_temp`) al directorio donde tenemos la aplicación.

Reinicia el servicio web y prueba el funcionamiento. Si te da algún error *500* puedes ver los errores, en `/var/log/apache2/error.log`.

**Realiza la configuración de apache2 para que sirva la aplicación con la que estamos trabajando en un virtualhost `python.iesgn.org`.**
