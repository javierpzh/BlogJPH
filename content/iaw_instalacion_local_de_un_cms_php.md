Title: Instalación local de un CMS PHP
Date: 2020/10/21
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: lamp, cms, apache, mariadb, mysql, php

Esta tarea consiste en instalar un **CMS** de tecnología **PHP** en un servidor local. Los pasos que tendrás que dar los siguientes:

## Tarea 1: Instalación de un servidor LAMP

- **Crea una instancia de vagrant basado en un box debian o ubuntu**

He creado una máquina virtual utilizando **Vagrant** y **VirtualBox**, mediante el siguiente fichero *VagrantFile*:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"
  config.vm.network "private_network", ip: "192.168.30.15"

end
</pre>

- **Instala en esa máquina virtual toda la pila LAMP**
- **Entrega un documentación resumida donde expliques los pasos fundamentales para realizar esta tarea.**

Una vez tenemos la máquina lista, vamos a instalar el **servidor LAMP**. Antes de nada vamos a preparar la máquina para la instalación:

<pre>
apt update && apt upgrade -y && apt autoremove -y
</pre>

El primer paso sería instalar nuestro gestor de base de datos, yo voy a utilizar **MySQL**. Lo instalamos:

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
apt install -y apache2 apache2-utils
</pre>

Y vamos a habilitar su servicio en cada inicio del sistema con:

<pre>
systemctl enable apache2
</pre>

Nos quedaría por instalar el **servidor PHP**, para ello:

<pre>
apt install php libapache2-mod-php php-cli php-mysql -y
</pre>

También he instalado las **librerías php** de *apache* y *mysql*.

Activamos el módulo de **PHP** de **Apache**.

<pre>
a2enmod php7.3
</pre>

Y por último introducimos la siguiente línea en forma de script PHP, que lo único que hace es crear un fichero llamado `phpinfo.php` dentro del directorio `/var/www/html`, en el que escribe **<?php phpinfo(); ?>**.

`echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php`

Hemos terminado nuestro servidor LAMP.

##Tarea 2: Instalación de drupal en mi servidor local

- **Configura el servidor web con virtual hosting para que el CMS sea accesible desde la dirección: `www.nombrealumno-drupal.org`.**
- **Crea un usuario en la base de datos para trabajar con la base de datos donde se van a guardar los datos del CMS.**
- **Descarga la versión que te parezca más oportuna de Drupal y realiza la instalación.**
- **Realiza una configuración mínima de la aplicación (Cambia la plantilla, crea algún contenido, …)**
- **Instala un módulo para añadir alguna funcionalidad a drupal.**

**En este momento, muestra al profesor la aplicación funcionando en local. Entrega un documentación resumida donde expliques los pasos fundamentales para realizar esta tarea.**

## Tarea 3: Configuración multinodo

- **Realiza un copia de seguridad de la base de datos**
- **Crea otra máquina con vagrant, conectada con una red interna a la anterior y configura un servidor de base de datos.**
- **Crea un usuario en la base de datos para trabajar con la nueva base de datos.**
- **Restaura la copia de seguridad en el nuevo servidor de base datos.**
- **Desinstala el servidor de base de datos en el servidor principal.**
- **Realiza los cambios de configuración necesario en drupal para que la página funcione.**

**Entrega un documentación resumida donde expliques los pasos fundamentales para realizar esta tarea. En este momento, muestra al profesor la aplicación funcionando en local.**

## Tarea 4: Instalación de otro CMS PHP

- **Elige otro CMS realizado en PHP y realiza la instalación en tu infraestructura.**
- **Configura otro virtualhost y elige otro nombre en el mismo dominio.**

**En este momento, muestra al profesor la aplicación funcionando en local. Y describe en redmine los pasos fundamentales para realizar la tarea.**

##Tarea 5: Necesidad de otros servicios

- **La mayoría de los CMS tienen la posibilidad de mandar correos electrónicos (por ejemplo para notificar una nueva versión, notificar un comentario,…)**

- **Instala un servidor de correo electrónico en tu servidor. debes configurar un servidor relay de correo, para ello en el fichero `/etc/postfix/main.cf`, debes poner la siguiente línea:**

<pre>
relayhost = babuino-smtp.gonzalonazareno.org
</pre>

- **Configura alguno de los CMS para utilizar tu servidor de correo y realiza una prueba de funcionamiento.**

**Muestra al profesor algún correo enviado por tu CMS.**
