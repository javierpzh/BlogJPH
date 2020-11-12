Title: Instalación local de un CMS PHP
Date: 2020/10/29
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: LAMP, CMS, Linux, Apache, MariaDB, MySQL, PHP, DrupalCMS, AnchorCMS, PicoCMS

Esta tarea consiste en instalar un **CMS** de tecnología **PHP** en un servidor local. Los pasos que tendrás que dar los siguientes:

## Tarea 1: Instalación de un servidor LAMP

- **Crea una instancia de vagrant basado en un box debian o ubuntu**

He creado una máquina virtual utilizando **Vagrant** y **VirtualBox**, mediante el siguiente fichero *VagrantFile*:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

 config.vm.define :servidor1 do |servidor1|
  servidor1.vm.box = "debian/buster64"
  servidor1.vm.network "private_network", ip: "192.168.30.15"
 end

end
</pre>

- **Instala en esa máquina virtual toda la pila LAMP**
- **Entrega una documentación resumida donde expliques los pasos fundamentales para realizar esta tarea.**

Una vez tenemos la máquina lista, vamos a instalar el **servidor LAMP**, que hace referencia a:

- **L**inux, el sistema operativo
- **A**pache, el servidor web
- **M**ySQL/MariaDB, el gestor de bases de datos
- **P**HP, el lenguaje de programación

Antes de nada voy a preparar la máquina para la instalación, voy a actualizar los paquetes instalados, ya que la box que estoy utilizando no es de la última versión de Debian.

<pre>
apt update && apt upgrade -y && apt autoremove -y
</pre>

El primer paso sería instalar nuestro gestor de base de datos, **MySQL**, por tanto, lo instalamos:

<pre>
apt install mariadb-server mariadb-client -y
</pre>

Una vez lo hemos instalado, vamos a configurar una serie de opciones con el comando `mysql_secure_installation`. Vamos a especificarle una **contraseña de root**, vamos a **eliminar los usuarios anónimos**, vamos a **desactivar el acceso remoto** a la base de datos, en resumen, vamos a restablecer la base de datos, con nuestras preferencias:

<pre>
root@buster:/home/vagrant# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

You already have a root password set, so you can safely answer 'n'.

Change the root password? [Y/n] Y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] Y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
</pre>

Procedemos a instalar el servidor web **Apache**, que lo vamos a instalar con este comando:

<pre>
apt install apache2 apache2-utils -y
</pre>

Y vamos a habilitar su servicio en cada inicio del sistema con:

<pre>
systemctl enable apache2
</pre>

Nos quedaría por instalar el **servidor PHP**, para ello:

<pre>
apt install php libapache2-mod-php php-cli php-mysql -y
</pre>

También he instalado las **librerías php** de *apache* y *mysql*, para que todos los sistemas puedan funcionar de manera conjunta.

Activamos el módulo de **PHP** de **Apache**.

<pre>
a2enmod php7.3
</pre>

Y por último introducimos la siguiente línea en forma de script PHP, que lo único que hace es crear un fichero llamado `phpinfo.php` dentro del directorio `/var/www/html`, en el que escribe **<?php phpinfo(); ?>**.

`echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php`

Hemos terminado de montar nuestro servidor LAMP.

##Tarea 2: Instalación de drupal en mi servidor local

- **Configura el servidor web con virtual hosting para que el CMS sea accesible desde la dirección: `www.nombrealumno-drupal.org`.**

En la ruta `/etc/apache2/sites-available/` creamos un fichero de configuración para esta página. Podemos copiar el fichero llamado `000-default.conf` para tener la estructura y luego lo modificamos:

<pre>
cp 000-default.conf javierperezhidalgo-drupal.conf
nano javierperezhidalgo-drupal.conf
</pre>

Dentro de este fichero, establecemos la url de la web en el apartado **ServerName**. Tiene que quedar así:

<pre>
ServerName www.javierperezhidalgo-drupal.org
</pre>

Creamos el enlace simbólico para activar el sitio web:

<pre>
a2ensite javierperezhidalgo-drupal.conf
</pre>

Reinicamos el servicio del servidor apache:

<pre>
systemctl restart apache2
</pre>

Si nos dirigimos a nuestra máquina anfitriona y añadimos al `/etc/hosts` esta línea, en el navegador podremos visualizar la web `www.javierperezhidalgo-drupal.org`:

<pre>
192.168.30.15   www.javierperezhidalgo-drupal.org
</pre>

La página web tiene este aspecto:

![.](images/iaw_instalacion_local_de_un_cms_php/phpinfo.png)


- **Crea un usuario en la base de datos para trabajar con la base de datos donde se van a guardar los datos del CMS.**

Para crear un usario en MySQL:

<pre>
root@buster:/var/www/html# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 65
Server version: 10.3.25-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE drupal;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> CREATE USER 'drupal' IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON drupal.* TO 'drupal';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> exit
Bye
</pre>

Además de crear el usuario **drupal**, le he concedido todos los permisos para tener acceso y control sobre todas las tablas y bases de datos.

- **Descarga la versión que te parezca más oportuna de Drupal y realiza la instalación.**

Para descargar **Drupal** en su última versión, que en este momento es la **9**, nos dirigimos a la [página oficial de Drupal](https://www.drupal.org/download). Copiamos la ruta del enlace de descarga del archivo, en mi caso prefiero el *tar.gz* y lo descargamos en nuestro servidor LAMP con la utilidad `wget`.

<pre>
root@buster:~# wget https://www.drupal.org/download-latest/tar.gz
--2020-10-22 18:29:12--  https://www.drupal.org/download-latest/tar.gz
Resolving www.drupal.org (www.drupal.org)... 151.101.134.217
Connecting to www.drupal.org (www.drupal.org)|151.101.134.217|:443... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: https://ftp.drupal.org/files/projects/drupal-9.0.7.tar.gz [following]
--2020-10-22 18:29:13--  https://ftp.drupal.org/files/projects/drupal-9.0.7.tar.gz
Resolving ftp.drupal.org (ftp.drupal.org)... 151.101.134.217
Connecting to ftp.drupal.org (ftp.drupal.org)|151.101.134.217|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 16863270 (16M) [application/octet-stream]
Saving to: ‘tar.gz’

tar.gz                    100%[=====================================>]  16.08M  28.9MB/s    in 0.6s    

2020-10-22 18:29:14 (28.9 MB/s) - ‘tar.gz’ saved [16863270/16863270]

root@buster:~# tar xf tar.gz -C /var/www/html/

root@buster:~# ln -s /var/www/html/drupal-9.0.7/ /var/www/html/drupal

root@buster:~# chown -R www-data:www-data /var/www/html/drupal/
</pre>

Hemos descargado **Drupal** y lo hemos descomprimido en la ruta en la que se encuentra el sitio web. Además conviene crear un enlace simbólico sobre el directorio de Drupal para tener un nombre sin números de versión. Hemos otorgado a `www-data` como dueño del directorio y su contenido al servidor web.

También necesitamos algunas extensiones de PHP:

<pre>
apt install php-apcu php-gd php-mbstring php-uploadprogress php-xml -y
</pre>

Drupal puede hacer uso del sistema de reescritura de URLs, basado en el módulo `Rewrite` de Apache, que no está activado por defecto. Este módulo permite crear direcciones URL alternativas a las dinámicas generadas por la programación de nuestros sitio web, de tal modo que sean más legibles y fáciles de recordar. Activamos el módulo `Rewrite` y otros que puede usar Drupal:

<pre>
a2enmod expires headers rewrite
</pre>

Generamos un fichero de configuración para Drupal que permita el uso de archivos `.htaccess` que configuren el módulo `Rewrite`:

<pre>
root@buster:/var/www/html# cd /etc/apache2/conf-available/

root@buster:/etc/apache2/conf-available# nano drupal.conf
</pre>

El archivo `drupal.conf` tiene que contener:

<pre>
<\Directory /var/www/html/drupal>
        AllowOverride all
<\/Directory>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Activamos la configuración:

<pre>
root@buster:/etc/apache2/conf-available# a2enconf drupal.conf
Enabling conf drupal.
To activate the new configuration, you need to run:
  systemctl reload apache2
</pre>

Reiniciamos el servidor web:

<pre>
systemctl restart apache2
</pre>

En este punto ya podemos hacer uso del **Instalador Web de Drupal**. Accedemos a la web que hemos configurado antes con la URL `http://www.javierperezhidalgo-drupal.org` y le añadimos `/drupal`, y se nos abrirá el instalador.

![.](images/iaw_instalacion_local_de_un_cms_php/instaladorwebdrupal.png)

- Seleccionamos el idioma deseado.
- Seleccionamos el perfil de la instalación, en mi caso **estándar**.
- Configuramos la base de datos:

![.](images/iaw_instalacion_local_de_un_cms_php/instaladordrupalbbdd.png)

Y ya comienza el proceso de instalación:

![.](images/iaw_instalacion_local_de_un_cms_php/instalandodrupal.png)

Terminada la instalación llega el momento de configurar la identidad del sitio y crear el usuario administrador.

![.](images/iaw_instalacion_local_de_un_cms_php/configuraridentidadsitio.png)

Completamos según nuestras preferencias y guardamos y listo:

![.](images/iaw_instalacion_local_de_un_cms_php/paginainiciodrupal.png)


- **Realiza una configuración mínima de la aplicación (Cambia la plantilla, crea algún contenido, …)**

Para **cambiar el tema de nuestro CMS**, nos dirigimos a la opción que nos aparece arriba, **Apariencia** y seleccionamos `+ Instalar nuevo tema`, introducimos el enlace de descarga del tema que queremos añadir y listo. Cuidado, tenemos que comprobar que el tema que vamos a instalar es compatible con la versión de Drupal que estamos utilizando.

![.](images/iaw_instalacion_local_de_un_cms_php/temainstalado.png)

Lo seleccionamos como activo:

![.](images/iaw_instalacion_local_de_un_cms_php/temaseleccionado.png)

Y ya hemos cambiado el tema:

![.](images/iaw_instalacion_local_de_un_cms_php/nuevotemainicio.png)

Vamos a añadir alguna entrada, para ver como se mostraría el contenido. Para ello en la parte superior de las opciones, donde dice **Contenido**, clickamos en `+ Añadir contenido`, y se nos abrirá una especie de editor, que configuramos a nuestro gusto y guardamos los cambios.

Así quedaría nuestra nueva publicación:

![.](images/iaw_instalacion_local_de_un_cms_php/nuevocontenido.png)

- **Instala un módulo para añadir alguna funcionalidad a drupal.**

Para **instalar un nuevo módulo** en Drupal, es bastante sencillo y parecido a los temas. Vamos a la opción **Ampliar**, clickamos en `+ Instalar nuevo módulo`, introducimos el enlace de descarga del módulo que queremos añadir y listo. Al igual que con el tema, tenemos que verificar que funciona con nuestra versión de Drupal.

En mi caso, voy a instalar un módulo llamado ***AddToAny*** que permite compartir los artículos y entradas de la web a través de nuestras redes sociales.

![.](images/iaw_instalacion_local_de_un_cms_php/moduloinstalado.png)

Activamos el nuevo módulo:

![.](images/iaw_instalacion_local_de_un_cms_php/moduloactivado.png)

Observamos como en la página de inicio, ahora nos aparece un pequeño menú con varias redes sociales para compartir el artículo.

![.](images/iaw_instalacion_local_de_un_cms_php/nuevomodulo.png)

**En este momento, muestra al profesor la aplicación funcionando en local. Entrega una documentación resumida donde expliques los pasos fundamentales para realizar esta tarea.**

## Tarea 3: Configuración multinodo

- **Realiza un copia de seguridad de la base de datos.**

Realizamos una copia de seguridad de la base de datos de Drupal que tenemos en MySQL, mediante el comando:

<pre>
root@buster:/home/vagrant# mysqldump -u drupal -p drupal > copiaseguridaddrupal.sql
Enter password:

root@buster:/home/vagrant# ls
copiaseguridaddrupal.sql
</pre>

Le pasamos dos parámetros: la opción **-u** indica el nombre de usuario y la opción **-p** el nombre de la base de datos.

- **Crea otra máquina con vagrant, conectada con una red interna a la anterior y configura un servidor de base de datos.**

Modifico el escenario creado antes y queda así:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

 config.vm.define :servidor1 do |servidor1|
  servidor1.vm.box = "debian/buster64"
  servidor1.vm.network "private_network", ip: "192.168.30.15"
 end

 config.vm.define :maquina2 do |maquina2|
  maquina2.vm.box = "debian/buster64"
  maquina2.vm.network "private_network", ip: "192.168.30.30"
 end

end
</pre>

En la nueva máquina llamada **maquina2** hay que configurar el nuevo servidor de base de datos, para ello previamente preparo y actualizo los paquetes, e instalo los relativos a **MySQL**:

<pre>
apt update && apt upgrade -y && apt autoremove -y && apt install mariadb-server mariadb-client -y
</pre>

Una vez lo hemos instalado, vamos a configurar una serie de opciones con el comando `mysql_secure_installation`. Vamos a especificarle una **contraseña de root**, vamos a **eliminar los usuarios anónimos**, vamos a **desactivar el acceso remoto** a la base de datos, en resumen, vamos a restablecer la base de datos, con nuestras preferencias:

<pre>
root@buster:/home/vagrant# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

You already have a root password set, so you can safely answer 'n'.

Change the root password? [Y/n] Y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] Y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
</pre>

- **Crea un usuario en la base de datos para trabajar con la nueva base de datos.**

Para crear un usario en MySQL:

<pre>
root@buster:/home/vagrant# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 57
Server version: 10.3.25-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE drupal;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> CREATE USER 'drupal' IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON drupal.* TO 'drupal';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> exit
Bye
</pre>

- **Restaura la copia de seguridad en el nuevo servidor de base datos.**

Para mover la copia de seguridad de la base de datos que hemos realizado en pasos anteriores, en la máquina **servidor1** he instalado la utilidad **rclone**, he configurado mi cuenta de *Dropbox* y he copiado el archivo. Si quieres aprender más sobre *rclone* puedes visitar este [post](https://javierpzh.github.io/rclone-gestionando-nuestro-almacenamiento-en-la-nube.html).

Podríamos haberlo hecho con el típico comando `scp`, pero en caso de querer utilizarlo, tendríamos que establecer una contraseña en las máquinas, ya que *Vagrant* por defecto no deja que nos conectemos por **SSH** si no utilizamos la clave privada, y luego configurar en el fichero `/etc/ssh/sshd_config` la línea `PasswordAuthentication no` y sustituir el **no** por un **yes**, y reiniciar el servicio SSH, ya que hemos tocado su configuración. Esta solución me la comentó mi compañero [Álvaro](https://www.instagram.com/whosalvr/) ya que yo no caí en estos detalles.

Ahora voy a configurar la misma cuenta de *Dropbox* con *rclone* en la máquina **maquina2**, y voy a descargar la copia de seguridad de la base de datos.

<pre>
root@buster:/home/vagrant# rclone copy dropbox:/rclone/copiaseguridaddrupal.sql /home/vagrant/

root@buster:/home/vagrant# ls
copiaseguridaddrupal.sql
</pre>

Ya tengo la copia de seguridad en la **maquina2**, que es donde quiero restaurarla. Para restaurar una copia de seguridad de una base de datos en *MySQL*, introducimos el siguiente comando:

<pre>
mysql -u drupal -p drupal < copiaseguridaddrupal.sql
</pre>

El parámetro **-u** indica el nombre de usuario y **-p** el nombre de la base de datos, donde se va a restaurar la copia.

Si miramos las bases de datos del usuario **drupal**:

<pre>
root@buster:/home/vagrant# mysql -u drupal -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 63
Server version: 10.3.25-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| drupal             |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)
</pre>

Si entramos en la base de datos **drupal** y miramos las tablas:

<pre>
MariaDB [(none)]> use drupal;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [drupal]> show tables;
+----------------------------------+
| Tables_in_drupal                 |
+----------------------------------+
| batch                            |
| block_content                    |
| block_content__body              |
| block_content_field_data         |
| block_content_field_revision     |
| block_content_revision           |
| block_content_revision__body     |
| cache_bootstrap                  |
| cache_config                     |
| cache_container                  |
| cache_data                       |
| cache_default                    |
| cache_discovery                  |
| cache_dynamic_page_cache         |
| cache_entity                     |
| cache_menu                       |
| cache_render                     |
| cachetags                        |
| comment                          |
| comment__comment_body            |
| comment_entity_statistics        |
| comment_field_data               |
| config                           |
| file_managed                     |
| file_usage                       |
| history                          |
| key_value                        |
| key_value_expire                 |
| locale_file                      |
| locales_location                 |
| locales_source                   |
| locales_target                   |
| menu_link_content                |
| menu_link_content_data           |
| menu_link_content_field_revision |
| menu_link_content_revision       |
| menu_tree                        |
| node                             |
| node__body                       |
| node__comment                    |
| node__field_image                |
| node__field_tags                 |
| node_access                      |
| node_field_data                  |
| node_field_revision              |
| node_revision                    |
| node_revision__body              |
| node_revision__comment           |
| node_revision__field_image       |
| node_revision__field_tags        |
| path_alias                       |
| path_alias_revision              |
| queue                            |
| router                           |
| search_dataset                   |
| search_index                     |
| search_total                     |
| semaphore                        |
| sequences                        |
| sessions                         |
| shortcut                         |
| shortcut_field_data              |
| shortcut_set_users               |
| taxonomy_index                   |
| taxonomy_term__parent            |
| taxonomy_term_data               |
| taxonomy_term_field_data         |
| taxonomy_term_field_revision     |
| taxonomy_term_revision           |
| taxonomy_term_revision__parent   |
| user__roles                      |
| user__user_picture               |
| users                            |
| users_data                       |
| users_field_data                 |
| watchdog                         |
+----------------------------------+
76 rows in set (0.001 sec)

MariaDB [drupal]>
</pre>

Vemos que la copia se ha restaurado correctamente.

- **Desinstala el servidor de base de datos en el servidor principal.**

En **servidor1** desinstalamos el servidor de base de datos y borramos todos sus datos:

<pre>
apt remove --purge mariadb-server mariadb-client -y && apt autoremove -y
</pre>

Probamos a acceder a la página de Drupal ahora:

![.](images/iaw_instalacion_local_de_un_cms_php/bbddeliminada.png)

- **Realiza los cambios de configuración necesarios en drupal para que la página funcione.**

**Entrega una documentación resumida donde expliques los pasos fundamentales para realizar esta tarea. En este momento, muestra al profesor la aplicación funcionando en local.**

En este punto, queremos volver a tener disponible nuestra web de Drupal, pero funcionando con la base de datos en la nueva máquina, es decir, en **maquina2**.

Tenemos que cambiar la configuración de Drupal, para ello nos dirigimos al fichero que se encuentra en la ruta `/var/www/html/drupal-9.0.7/sites/default/settings.php`, y al final del archivo, se encuentra la configuración de la base de datos que utiliza Drupal. Como es obvio, está configurada como que la base de datos está en el mismo equipo, por tanto está configurado en **localhost**. Aquí viene el primer cambio, pues debemos remover *localhost* y sustituirlo por la IP de la máquina donde se encuentra la nueva base de datos sobre la que va a funcionar Drupal, que es la **192.168.30.30**.

<pre>
$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'contraseña',
  'prefix' => '',
  'host' => '192.168.30.30',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
</pre>

Una vez hecho esto, tendríamos que dirigirnos a la máquina donde hemos migrado la copia de seguridad, es decir la llamada **maquina2**, y tenemos que permitirle el acceso remoto a la base de datos.

El primer paso es editar el fichero de configuración que se encuentra en `/etc/mysql/mariadb.conf.d/50-server.cnf` y tenemos que editar, y en caso de estar comentadas la línea `bind-address`. En esta línea también tenemos que cambiar la IP, ya que por defecto aparece la de *localhost*, podemos poner una IP concreta si sabemos que siempre va a acceder un equipo con la misma dirección, o podemos habilitarlas todas. Si queremos esta última opción, la línea quedará así:

<pre>
bind-address            = 0.0.0.0
</pre>

En último lugar, vamos a permitirle tanto a nuestro usuario *drupal*, como a *root*, que puedan ser accesibles desde otros equipos.

<pre>
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'contraseña' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'drupal'@'%' IDENTIFIED BY 'contraseña' WITH GRANT OPTION;
</pre>

Reiniciamos el servidor:

<pre>
systemctl restart mysqld
</pre>

Ya podemos acceder de nuevo a nuestro sitio web Drupal.


## Tarea 4: Instalación de otro CMS PHP

- **Elige otro CMS realizado en PHP y realiza la instalación en tu infraestructura.**

- **Configura otro virtualhost y elige otro nombre en el mismo dominio.**

**En este momento, muestra al profesor la aplicación funcionando en local. Y describe en redmine los pasos fundamentales para realizar la tarea.**

He decidido elegir el CMS llamado **Anchor**. Este CMS cuenta con una interfaz de usuario muy simple. Instalar Anchor CMS te llevará muy poco tiempo. Soporta Markdown editor, campos personalizados, múltiples idiomas y la posibilidad de instalar múltiples temas.

Si nos ayudamos de la página oficial de [Anchor](https://anchorcms.com/), la descarga la podemos realizar desde [aquí](https://anchorcms.com/download).

Como antes para realizar la migración, desinstalé *MySQL* de la máquina **servidor1**, voy a volver a realizar la instalación y configuración, esta vez sin tantos detalles.

<pre>
apt install mariadb-server mariadb-client -y
mysql_secure_installation
</pre>

Creamos el usuario **anchor** de la base de datos y le otorgamos los permisos:

<pre>
root@buster:/home/vagrant# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 44
Server version: 10.3.25-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE anchor;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> CREATE USER anchor IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON anchor. * TO 'anchor';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> exit
Bye
</pre>

Vamos a instalar la utilidad para descargar archivos `curl`, ya que estamos siguiendo los pasos de la web de *Anchor* y utiliza este comando:

<pre>
apt install curl -y
</pre>

Necesitamos instalar *Composer* en el sistema, que es un administrador de dependencias PHP. Lo descargamos, instalamos y ejecutamos mediante el siguiente comando:

<pre>
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
</pre>

Descargamos y creamos la página de *Anchor* utilizando *Composer* con el comando:

<pre>
root@buster:/var/www/html# composer create-project anchorcms/anchor-cms
Do not run Composer as root/super user! See https://getcomposer.org/root for details
Continue as root/super user [yes]? yes
Creating a "anchorcms/anchor-cms" project at "./anchor-cms"
Installing anchorcms/anchor-cms (0.12.7)
    Failed to download anchorcms/anchor-cms from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing anchorcms/anchor-cms (0.12.7) into cache
  - Installing anchorcms/anchor-cms (0.12.7): Cloning 08e8e50790 from cache
Created project in /var/www/html/anchor-cms


  [Composer\Json\JsonValidationException]                    
  "./composer.json" does not match the expected JSON schema  


create-project [-s|--stability STABILITY] [--prefer-source] [--prefer-dist] [--repository REPOSITORY] [--repository-url REPOSITORY-URL] [--add-repository] [--dev] [--no-dev] [--no-custom-installers] [--no-scripts] [--no-progress] [--no-secure-http] [--keep-vcs] [--remove-vcs] [--no-install] [--ignore-platform-req IGNORE-PLATFORM-REQ] [--ignore-platform-reqs] [--ask] [--] [<package>] [<directory>] [<version>]
</pre>

Antes de pasar con el error del que nos ha informado, he cambiado el nombre del directorio:

<pre>
root@buster:/var/www/html# mv anchor-cms anchor
</pre>

Si nos fijamos, nos ha reportado un mensaje de error. Nos indica que ha detectado un fallo en el fichero `composer.json`. Para solucionar este error, debemos editar el fichero:

<pre>
root@buster:/var/www/html/anchor# nano composer.json
</pre>

En la línea que hace referencia al tipo, debemos cambiar el valor, que por defecto viene *CMS*, debemos indicar el tipo con letras minúsculas, de forma que quede así:

<pre>
"type": "cms"
</pre>

Corremos el instalador de nuevo:

<pre>
root@buster:/var/www/html/anchor# composer install
Do not run Composer as root/super user! See https://getcomposer.org/root for details
Continue as root/super user [yes]? yes
Installing dependencies from lock file (including require-dev)
Verifying lock file contents can be installed on current platform.
Warning: The lock file is not up to date with the latest changes in composer.json. You may be getting outdated dependencies. It is recommended that you run `composer update` or `composer update <package name>`.
Package operations: 13 installs, 0 updates, 0 removals
    Failed to download indigophp/hash-compat from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing indigophp/hash-compat (v1.1.0) into cache
    Failed to download ircmaxell/password-compat from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing ircmaxell/password-compat (v1.0.4) into cache
    Failed to download ircmaxell/security-lib from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing ircmaxell/security-lib (v1.1.0) into cache
    Failed to download ircmaxell/random-lib from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing ircmaxell/random-lib (v1.2.0) into cache
    Failed to download peridot-php/leo from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing peridot-php/leo (1.6.1) into cache
    Failed to download symfony/polyfill-mbstring from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing symfony/polyfill-mbstring (v1.7.0) into cache
    Failed to download psr/log from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing psr/log (1.0.2) into cache
    Failed to download symfony/debug from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing symfony/debug (v4.0.5) into cache
    Failed to download symfony/console from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing symfony/console (v3.4.5) into cache
    Failed to download phpunit/php-timer from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing phpunit/php-timer (1.0.9) into cache
    Failed to download peridot-php/peridot-scope from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing peridot-php/peridot-scope (1.3.0) into cache
    Failed to download evenement/evenement from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing evenement/evenement (v2.1.0) into cache
    Failed to download peridot-php/peridot from dist: The zip extension and unzip command are both missing, skipping.
Your command-line PHP is using multiple ini files. Run `php --ini` to show them.
    Now trying to download from source
  - Syncing peridot-php/peridot (1.19.0) into cache
  - Installing indigophp/hash-compat (v1.1.0): Cloning 43a19f4209 from cache
  - Installing ircmaxell/password-compat (v1.0.4): Cloning 5c5cde8822 from cache
  - Installing ircmaxell/security-lib (v1.1.0): Cloning f3db6de12c from cache
  - Installing ircmaxell/random-lib (v1.2.0): Cloning e9e0204f40 from cache
  - Installing peridot-php/leo (1.6.1): Cloning 2a6f60f237 from cache
  - Installing symfony/polyfill-mbstring (v1.7.0): Cloning 78be803ce0 from cache
  - Installing psr/log (1.0.2): Cloning 4ebe3a8bf7 from cache
  - Installing symfony/debug (v4.0.5): Cloning 1721e4e7ef from cache
  - Installing symfony/console (v3.4.5): Cloning 067339e9b8 from cache
  - Installing phpunit/php-timer (1.0.9): Cloning 3dcf38ca72 from cache
  - Installing peridot-php/peridot-scope (1.3.0): Cloning b5cc7ac35b from cache
  - Installing evenement/evenement (v2.1.0): Cloning 6ba9a77787 from cache
  - Installing peridot-php/peridot (1.19.0): Cloning 1c573868d8 from cache
Generating autoload files
</pre>

Ahora sí hemos instalado correctamente *Anchor* como nuestro CMS.

Hemos otorgado a `www-data` como dueño del directorio y su contenido al servidor web.

<pre>
root@buster:/var/www/html# chown -R www-data:www-data ./anchor/

root@buster:/var/www/html# ls -l
total 28
drwxr-xr-x 10 www-data www-data  4096 Oct 30 12:05 anchor
lrwxrwxrwx  1 root     root        27 Oct 28 09:52 drupal -> /var/www/html/drupal-9.0.7/
drwxr-xr-x  8 www-data www-data  4096 Oct 28 11:14 drupal-9.0.7
-rw-r--r--  1 root     root     10701 Oct 28 09:44 index.html
-rw-r--r--  1 root     root        20 Oct 28 09:45 phpinfo.php
drwxr-xr-x 13 www-data www-data  4096 Oct 29 17:59 Pico
</pre>

Solo nos quedaría configurar nuestro servidor web *Apache* para que sirviera la web. Para ello vamos a generar un fichero de configuración para *Anchor*:

<pre>
root@buster:/etc/apache2/sites-available# cp javierperezhidalgodrupal.conf anchor.conf

root@buster:/etc/apache2/sites-available# nano anchor.conf
</pre>

Dentro de este fichero especificamos la dirección de la web y el DocumentRoot:

<pre>
ServerName www.javierperezhidalgoanchor.com
DocumentRoot /var/www/html/anchor
</pre>

Habilitamos el sitio web para que *Apache* lo muestre y reiniciamos el servidor, como siempre hay que hacer cuando hagamos un cambio:

<pre>
root@buster:/etc/apache2/sites-available# a2ensite anchor.conf
Enabling site anchor.
To activate the new configuration, you need to run:
  systemctl reload apache2

root@buster:/etc/apache2/sites-available# systemctl restart apache2
</pre>

Por último, añadimos esta línea al fichero `/etc/hosts` del equipo anfitrión para que podamos ver la web en nuestro navegador.

<pre>
192.168.30.15   www.javierperezhidalgoanchor.com
</pre>

Introducimos en el navegador la dirección `www.javierperezhidalgoanchor.com` y nos saldrá el instalador de Anchor:

![.](images/iaw_instalacion_local_de_un_cms_php/anchor.png)

Vamos a realizar una instalación rápida, ya que es muy parecido al proceso que hemos realizado para Drupal.

En primer lugar indicamos el idioma y la zona horaria:

![.](images/iaw_instalacion_local_de_un_cms_php/idiomaanchor.png)

Especificamos la base de datos que va utilizar. La que previamente hemos creado en *MySQL*:

![.](images/iaw_instalacion_local_de_un_cms_php/bbddanchor.png)

Configuramos el nombre de la página, la descripción, ...

![.](images/iaw_instalacion_local_de_un_cms_php/confpaganchor.png)

Creamos la cuenta administradora del sitio web:

![.](images/iaw_instalacion_local_de_un_cms_php/cuentaanchor.png)

Y con esto ya hemos terminado la instalación de *Anchor*.

![.](images/iaw_instalacion_local_de_un_cms_php/instalacioncompletadaanchor.png)

Así luce nuestra nueva página:

![.](images/iaw_instalacion_local_de_un_cms_php/terminadoanchor.png)


## Instalación de un CMS PHP que no utiliza base de datos

También voy a instalar un CMS llamado **Pico**. No tiene un backend para editar los datos (aunque existe un plugin para ello). No utiliza consultas a la base de datos, por lo tanto, es súper rápido. Es compatible con el formato Markdown y las plantillas twig.

Vamos a proceder a instalarlo.

Si nos ayudamos de la página oficial de [Pico](http://picocms.org/), la descarga la podemos realizar clonando un repositorio de GitHub. Por tanto necesitamos el paquete `git` en nuestro sistema:

<pre>
apt install git -y
</pre>

Clonamos el repositorio en `/var/www/html`:

<pre>
git clone https://github.com/picocms/Pico.git
</pre>

Hemos otorgado a `www-data` como dueño del directorio y su contenido al servidor web.

<pre>
root@buster:/var/www/html# chown -R www-data:www-data ./Pico/

root@buster:/var/www/html# ls -l
total 24
lrwxrwxrwx  1 root     root        27 Oct 28 09:52 drupal -> /var/www/html/drupal-9.0.7/
drwxr-xr-x  8 www-data www-data  4096 Oct 28 11:14 drupal-9.0.7
-rw-r--r--  1 root     root     10701 Oct 28 09:44 index.html
-rw-r--r--  1 root     root        20 Oct 28 09:45 phpinfo.php
drwxr-xr-x 12 www-data www-data  4096 Oct 29 17:54 Pico
</pre>

Descargamos el instalador y lo lanzamos mediante los siguientes comandos:

<pre>
curl -sSL https://getcomposer.org/installer | php
php composer.phar create-project picocms/pico-composer pico
</pre>

Hemos instalado el CMS Pico. Solo nos quedaría configurar apache para que sirva este sitio web en la dirección `http://www.javierperezhidalgopico.com/Pico/pico/`. Primero creamos el fichero de configuración en `/etc/apache2/sites-available`, lo voy a llamar `pico.conf`. Añado las siguientes líneas:

<pre>
ServerName www.javierperezhidalgopico.com
DocumentRoot /var/www/html/Pico
</pre>

Habilitamos el despliegue de la página:

<pre>
a2ensite pico.conf
</pre>

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Acabamos de lanzar nuestra página en Pico, si queremos visualizarla en nuestra máquina anfitrión, añadimos la siguiente línea al fichero `/etc/hosts`:

<pre>
192.168.30.15   www.javierperezhidalgopico.com
</pre>

Nos dirigimos a la web `http://www.javierperezhidalgopico.com/Pico/pico/`:

![.](images/iaw_instalacion_local_de_un_cms_php/pico.png)


##Tarea 5: Necesidad de otros servicios

- **La mayoría de los CMS tienen la posibilidad de mandar correos electrónicos (por ejemplo para notificar una nueva versión, notificar un comentario,…)**



- **Instala un servidor de correo electrónico en tu servidor. Debes configurar un servidor relay de correo, para ello en el fichero `/etc/postfix/main.cf`, debes poner la siguiente línea:**

<pre>
relayhost = babuino-smtp.gonzalonazareno.org
</pre>



- **Configura alguno de los CMS para utilizar tu servidor de correo y realiza una prueba de funcionamiento.**



**Muestra al profesor algún correo enviado por tu CMS.**