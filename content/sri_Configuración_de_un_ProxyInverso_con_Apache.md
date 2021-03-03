Title: Configuración de un proxy inverso con Apache
Date: 2018/03/03
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: Proxy Inverso, Apache

En este artículo vamos a instalar un **proxy inverso** con *Apache*.

El escenario en el que vamos a trabajar, está definido en este [Vagrantfile](images/sri_Configuración_de_un_ProxyInverso_con_Apache/Vagrantfile.txt).

Tendremos una máquina llamada **balanceador** que estará conectada a nuestra red doméstica, de manera que podremos acceder a ella, además de estar conectada a una red privada, a la que también pertenecerán dos máquinas, cada una con un servidor *Apache* y que servirán webs distintas.

La máquina **balanceador** actuará como *proxy inverso* y se encargará de redirigir las distintas peticiones, a las diferentes máquinas internas.

En mi caso, ambas páginas webs serán de prueba, y he utilizado dos plantillas cualquiera. Puedes descargar ambas desde los siguientes enlaces: [Coffee-Master](https://themewagon.com/themes/free-coffee-shop-bootstrap-template/) y [Original-Master](https://themewagon.com/themes/free-bootstrap-blog-website-template/).

He descargado una plantilla en cada máquina interna, y he almacenado ambas carpetas resultantes en el directorio `/var/www/html`.

A continuación dejo el contenido de los ficheros de los diferentes *virtualhosts*:

**Máquina apache1**:

<pre>
root@apache1:~# cat /etc/apache2/sites-available/000-default.conf

<\VirtualHost *:80\>

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/coffee-master/

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

**Máquina apache2**:

<pre>
root@apache2:~# cat /etc/apache2/sites-available/000-default.conf

<\VirtualHost *:80\>

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/original-master/

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Explicado esto, vamos a empezar con las configuraciones del propio *post*.

Pongámonos en situación, ahora mismo nos encontramos con las dos máquinas internas sirviendo cada una, una web distinta. Obviamente para acceder a ellas tenemos que utilizar la máquina **balanceador**, que es la que posee una dirección de mi red local.

Bien, ahora lo que queremos hacer es acceder a las webs, a través de la máquina **balanceador**, y acceder a través del nombre que le indiquemos a cada web. Para llevar a cabo esto, primeramente debemos habilitar el siguiente módulo de *Apache*:

<pre>
a2enmod proxy proxy_http
</pre>

Hecho esto, necesitaremos crear los distintos *virtualhosts*, que en mi caso, se llamarán `/etc/apache2/sites-available/app1.conf` y `/etc/apache2/sites-available/app2.conf`.

Vamos a ver el contenido del fichero `/etc/apache2/sites-available/app1.conf` y luego explicaremos su funcionamiento:

<pre>
<\VirtualHost *:80\>

        ServerName www.app1.org

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        ProxyPass "/" "http://10.10.10.11/"
        ProxyPassReverse "/" "http://10.10.10.11/"

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.


que será el encargado de redirigir la petición




<pre>
<\VirtualHost *:80\>

        ServerName www.app2.org

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        ProxyPass "/" "http://10.10.10.22/"
        ProxyPassReverse "/" "http://10.10.10.22/"

<\/VirtualHost\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.





<pre>
a2ensite app1.conf
a2ensite app2.conf
</pre>



<pre>
systemctl restart apache2
</pre>














`/etc/hosts`

<pre>
192.168.0.74 www.app1.org
192.168.0.74 www.app2.org
</pre>



















.
