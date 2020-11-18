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


**2. Vamos a nombrar el servicio de base de datos que tenemos en producción. Como es un servicio interno no la vamos a nombrar en la zona DNS, la vamos a nombrar usando resolución estática. El nombre del servicio de base de datos se debe llamar: `bd.iesgnXX.es`.**



**3. Por lo tanto los recursos que deberás crear en la base de datos serán (respeta los nombres):**

- **Dirección de la base de datos: `bd.iesgnXX.es`**
- **Base de datos: `bd_drupal`**
- **Usuario: `user_drupal`**
- **Password: `pass_drupal`**

**4. Realiza la migración de la aplicación.**



**5. Asegurate que las URL limpias de drupal siguen funcionando en nginx.**



**6. La aplicación debe estar disponible en la URL: `portal.iesgnXX.es` (Sin ningún directorio).**

### Instalación / migración de la aplicación Nextcloud

**1. Instala la aplicación web *Nextcloud* en tu entorno de desarrollo.**



**2. Realiza la migración al servidor en producción, para que la aplicación sea accesible en la URL: `www.iesgnXX.es/cloud`**



**3. Instala en un ordenador el cliente de nextcloud y realiza la configuración adecuada para acceder a "tu nube".**




**Documenta de la forma más precisa posible cada uno de los pasos que has dado, y entrega pruebas de funcionamiento para comprobar el proceso que has realizado.**
