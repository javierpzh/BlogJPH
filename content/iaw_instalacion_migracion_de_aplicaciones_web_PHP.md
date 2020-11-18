Title: Instalación/migración de aplicaciones web PHP
Date: 2020/11/18
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: Apache, PHP, Nginx, Drupal, Nextcloud

### Realizar la migración de la aplicación Drupal que tienes instalada en el entorno de desarrollo a nuestro entorno de producción, para ello ten en cuenta lo siguiente:

Cuando me refiero al entorno de producción, estoy haciendo referencia a un servidor de OVH.

Antes de realizar la migración necesitamos preparar nuestro entorno de producción instalando todos los paquetes necesarios, como pueden ser `php`, `mysql`, ... para poder migrar *Drupal* de manera correcta. En mi caso tengo listo el entorno de producción, ya que en él lleve a cabo la instalación de un *servidor LEMP* que es lo que al fin y al cabo vamos a utilizar. Si quieres ver como instalar un *servidor LEMP* puedes verlo [aquí](https://javierpzh.github.io/instalacion-de-un-servidor-lemp.html).

**1. La aplicación se tendrá que migrar a un nuevo virtualhost al que se accederá con el nombre `portal.iesgnXX.es.`**

En nuestro entorno en producción, vamos a crear este nuevo *virtualhost*. Para ello antes que nada creamos la ruta donde vamos a almacenar esta aplicación, en mi caso dentro de `/srv/www/`:

<pre>
root@vpsjavierpzh:/srv/www# mkdir drupal
</pre>

Ahora debemos crear el fichero de configuración de *Nginx* que utilizará esta aplicación. Nos desplazamos a `/etc/nginx/sites-available/`, y podemos copiar el fichero por defecto para tener la estructura, en mi caso ya tengo un *virtualhost* creado y utilizo el fichero de este:

<pre>
root@vpsjavierpzh:/etc/nginx/sites-available# cp aplicacionesiesgn.conf drupal.conf
root@vpsjavierpzh:/etc/nginx/sites-available# nano drupal.conf
</pre>

Edito el fichero de configuración de *Drupal* y queda de tal manera:

<pre>
server {
        listen 80;
        listen [::]:80;

        root /srv/www/drupal;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name portal.iesgn15.es;

        location / {
                 try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        }
}
</pre>

Como podemos apreciar, a esta aplicación se accederá con la URL: `portal.iesgn15.es` como nos pide el ejercicio. Ya solo nos quedaría habilitar el servicio de este sitio web mediante la creación de un **enlace simbólico** a la ruta `/etc/nginx/sites-enabled/`:

<pre>
root@vpsjavierpzh:/etc/nginx/sites-available# ln -s /etc/nginx/sites-available/drupal.conf /etc/nginx/sites-enabled/

root@vpsjavierpzh:/etc/nginx/sites-available# ls -l /etc/nginx/sites-enabled/
total 0
lrwxrwxrwx 1 root root 49 Nov  9 18:44 aplicacionesiesgn.conf -> /etc/nginx/sites-available/aplicacionesiesgn.conf
lrwxrwxrwx 1 root root 34 Nov  9 12:09 default -> /etc/nginx/sites-available/default
lrwxrwxrwx 1 root root 38 Nov 18 08:06 drupal.conf -> /etc/nginx/sites-available/drupal.conf
</pre>

Como hemos realizado cambios en la configuración de *Nginx* debemos reiniciar el servicio:

<pre>
systemctl restart nginx.service
</pre>

**2. Vamos a nombrar el servicio de base de datos que tenemos en producción. Como es un servicio interno no la vamos a nombrar en la zona DNS, la vamos a nombrar usando resolución estática. El nombre del servicio de base de datos se debe llamar: `bd.iesgnXX.es`.**



**3. Por lo tanto los recursos que deberás crear en la base de datos serán (respeta los nombres):**

- **Dirección de la base de datos: `bd.iesgnXX.es`**
- **Base de datos: `bd_drupal`**
- **Usuario: `user_drupal`**
- **Password: `pass_drupal`**

<pre>
root@vpsjavierpzh:~# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 65
Server version: 10.3.25-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.001 sec)

MariaDB [(none)]> CREATE DATABASE bd_drupal;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> CREATE USER 'user_drupal' IDENTIFIED BY 'pass_drupal';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON bd_drupal.* TO 'user_drupal';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| bd_drupal          |
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
4 rows in set (0.001 sec)

MariaDB [(none)]> exit
Bye

root@vpsjavierpzh:~#
</pre>

**4. Realiza la migración de la aplicación.**



**5. Asegúrate que las URL limpias de *Drupal* siguen funcionando en *Nginx*.**



**6. La aplicación debe estar disponible en la URL: `portal.iesgnXX.es` (Sin ningún directorio).**




### Instalación / migración de la aplicación Nextcloud

**1. Instala la aplicación web *Nextcloud* en tu entorno de desarrollo.**



**2. Realiza la migración al servidor en producción, para que la aplicación sea accesible en la URL: `www.iesgnXX.es/cloud`**



**3. Instala en un ordenador el cliente de nextcloud y realiza la configuración adecuada para acceder a "tu nube".**




**Documenta de la forma más precisa posible cada uno de los pasos que has dado, y entrega pruebas de funcionamiento para comprobar el proceso que has realizado.**
