Title: Servidores OpenStack: DNS, Web y Base de Datos
Date: 2021/01/04
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: OpenStack, bind9, Apache, MySQL, MariaDB

## Servidor DNS

**Vamos a instalar un servidor DNS en *Freston* que nos permita gestionar la resolución directa e inversa de nuestros nombres. Mi subdominio dentro del dominio principal `gonzalonazareno.org`, se llamará `javierpzh.gonzalonazareno.org`. A partir de este momento no será necesario la resolución estática en los servidores.**

**Determina la regla DNAT en *Dulcinea* para que podamos hacer consultas DNS desde el exterior**

**Configura de forma adecuada todas las máquinas para que usen como servidor DNS a *Freston*.**

**Indica al profesor el nombre de tu dominio para que pueda realizar la delegación en el servidor DNS principal *papion-dns*.**

**Comprueba que los servidores tienen configurados el nuevo nombre de dominio de forma adecuada después de volver a reiniciar el servidor (o tomar una nueva configuración DHCP). Para que el servidor tenga el *FQDN* debes tener configurado de forma correcta el parámetro *domain* y el parámetro *search* en el fichero `/etc/resolv.conf`, además debemos evitar que este fichero se sobreescriba con los datos que manda el servidor DHCP de *OpenStack*. Quizás sea buena idea mirar la configuración de *cloud-init*. Documenta la configuración que has tenido que modificar y muestra el contenido del fichero `/etc/resolv.conf` y la salida del comando `hostname -f` después de un reinicio.**

**El servidor DNS se va a configurar en un principio de la siguiente manera:**

- **El servidor DNS se llama `freston.(nombre).gonzalonazareno.org` y va a ser el servidor con autoridad para la zona `(nombre).gonzalonazareno.org`.**

- **El servidor debe resolver el nombre de todas las máquinas.**

- **El servidor debe resolver los distintos servicios (virtualhost, servidor de base de datos, servidor LDAP, ...).**

- **Debes determinar cómo vas a nombrar a *Dulcinea*, para que seamos capaz de resolver la IP flotante y la ip fija. Para ello vamos a usar vistas en bind9.**

- **Debes considerar la posibilidad de hacer tres zonas de resolución inversa: para las redes `10.0.0.0/24`, `10.0.1.0/24` y `10.0.2.0/24` (no vamos a crear la zona inversa para la red externa de IP flotantes), para resolver IP fijas y flotantes del *cloud*.**


**Entrega el resultado de las siguientes consultas desde un cliente interno a nuestra red y otro externo:**

- **El servidor DNS con autoridad sobre la zona del dominio `(nombre).gonzalonazareno.org`**

- **La dirección IP de *Dulcinea*.**

- **Una resolución de `www`.**

- **Un resolución inversa de IP fija en cada una de las redes. (Esta consulta sólo funcionará desde una máquina interna).**


Vamos a instalar el servidor bind9:

<pre>
apt install bind9 -y
</pre>

Una vez instalado, vamos a pasar a definir las vistas que vamos a crear posteriormente. Para ello, nos dirigimos al fichero `/etc/bind/named.conf.local` y añadimos los siguientes bloques que definirán cada una de las vistas:

<pre>
view red_externa {
        match-clients {172.22.0.0/15; 192.168.202.2;};
        allow-recursion { any; };

        include "/etc/bind/zones.rfc1918";

        zone "javierpzh.gonzalonazareno.org" {
          type master;
          file "/var/cache/bind/db.javierpzh.gonzalonazareno.org";
        };
};

view red_DMZ {
        match-clients {10.0.2.0/24;};
        allow-recursion { any; };

        include "/etc/bind/zones.rfc1918";

        zone "javierpzh.gonzalonazareno.org" {
          type master;
          file "/var/cache/bind/db.javierpzh.gonzalonazareno.org";
        };

        zone "1.0.10.in-addr.arpa" {
          type master;
          file "/var/cache/bind/db.1.0.10";
        };

        zone "2.0.10.in-addr.arpa" {
          type master;
          file "/var/cache/bind/db.2.0.10";
        };
};

view red_interna {
        match-clients {10.0.1.0/24;};
        allow-recursion { any; };

        include "/etc/bind/zones.rfc1918";

        zone "javierpzh.gonzalonazareno.org" {
          type master;
          file "/var/cache/bind/db.javierpzh.gonzalonazareno.org";
        };

        zone "1.0.10.in-addr.arpa" {
          type master;
          file "/var/cache/bind/db.1.0.10";
        };

        zone "2.0.10.in-addr.arpa" {
          type master;
          file "/var/cache/bind/db.2.0.10";
        };
};
</pre>

Vamos a explicar las líneas que acabamos de añadir.

En primer lugar, vemos que hemos añadido tres vistas distintas, una para cada una de las redes con las que vamos a interaccionar. La primera está destinada a la **red externa**, la segunda a la **red DMZ**, y la tercera a la **red interna**.

Podemos ver que he escrito una línea que hacer referencia a un archivo llamado `zones.rfc1918`, que es un fichero de configuración de las zonas privadas que queremos definir.

Los bloques definen las zonas de las que el servidor tiene autoridad, la **zona de resolución directa** `javierpzh.gonzalonazareno.org`, y sus correspondientes **zonas de resolución inversa** `1.0.10.in-addr.arpa` y `2.0.10.in-addr.arpa`, además vemos como hemos especificado que actúen como **maestro**.

Una vez explicado, como vamos a utilizar distintas vistas, debemos dirigirnos al fichero `/etc/bind/named.conf` y comentar (para comentar se utilizan dos caracteres `/`) o eliminar la siguiente línea:

<pre>
include "/etc/bind/named.conf.default-zones";
</pre>

Hecho esto, tenemos que dirigirnos al fichero `/etc/bind/named.conf.options`, e introducir las siguientes líneas:

<pre>
allow-query { 172.22.0.0/15;10.0.1.0/24;10.0.2.0/24;192.168.202.2; };

allow-recursion { any; };

allow-query-cache { any; };
</pre>

De manera que el contenido total del fichero sería:

<pre>
options {
        directory "/var/cache/bind";

        dnssec-validation auto;

        listen-on-v6 { any; };

        recursion yes;

        allow-query { 172.22.0.0/15;10.0.1.0/24;10.0.2.0/24;192.168.202.2; };

        allow-recursion { any; };

        allow-query-cache { any; };

        listen-on { any; };

        allow-transfer { none; };

};
</pre>

Ahora, vamos a configurar las zonas que definimos en el paso anterior. En mi caso copio el fichero `/etc/bind/db.empty` para utilizarlo como plantilla de los nuevos archivos de configuración.

En primer lugar, voy a definir y configurar la zona que utilizaremos en la vista destinada para la **red externa**:

<pre>
root@freston:~# cp /etc/bind/db.empty /var/cache/bind/db.externa.javierpzh.gonzalonazareno.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.externa.javierpzh.gonzalonazareno.org`:

<pre>
$TTL    86400
@       IN      SOA     dulcinea.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      dulcinea.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

dulcinea        IN      A       172.22.200.183
www             IN      CNAME   dulcinea
</pre>

Voy a explicar el bloque añadido.

Vemos que hay un apartado llamado **Serial**, este apartado es muy importante, ya que es el identificador de la zona, que debemos incrementar cada vez que hagamos un cambio. Se recomienda que el valor sea de este formato **YYMMDDNN**, es decir, la fecha de modificación y el número de la modificación. En mi caso he establecido **20123001** pues estoy realizando esta práctica el *30 de diciembre de 2020* y es la primera modificación que hago.

Los registros de tipo **SOA** representan la autoridad sobre la zona.

El registro de tipo **NS** define el servidor con privilegios sobre la zona.

El registro **$ORIGIN** se usa para que las líneas que se especifiquen debajo de él, sean autocompletadas con el dominio especificado en dicho registro. Esto nos sirve para evitar poner en cada registro que creemos, la zona, es decir, a los próximos registros que creemos, se les añadirá automáticamente la zona `javierpzh.gonzalonazareno.org`.

Los registros de tipo **A** especifican la direcciones IP correspondientes al dominio.

Los registros de tipo **CNAME** sirven para apuntar hacia otro de los registros de tipo **A** ya existentes. De manera que es mucho más fácil y cómodo hacer referencia a una dirección a través de un nombre en vez de con la propia dirección en sí.

Explicados estos detalles, vamos a continuar con la siguiente zona que se empleará para la vista de la **red DMZ**. Vuelvo a copiar el fichero `/etc/bind/db.empty` para utilizarlo como plantilla:

<pre>
root@freston:~# cp /etc/bind/db.empty /var/cache/bind/db.DMZ.javierpzh.gonzalonazareno.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.DMZ.javierpzh.gonzalonazareno.org`:

<pre>
$TTL    86400
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

freston         IN      A       10.0.1.6
dulcinea        IN      A       10.0.1.11
ubuntu          IN      A       10.0.1.8
quijote         IN      A       10.0.2.6
www             IN      CNAME   quijote
bd              IN      CNAME   sancho
ldap            IN      CNAME   freston
</pre>

Seguimos con la siguiente zona, esta, se empleará para la vista de la **red interna**. Vuelvo a copiar el fichero `/etc/bind/db.empty` para utilizarlo como plantilla:

<pre>
root@freston:~# cp /etc/bind/db.empty /var/cache/bind/db.interna.javierpzh.gonzalonazareno.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.interna.javierpzh.gonzalonazareno.org`:

<pre>
$TTL    86400
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN javierpzh.gonzalonazareno.org.

freston         IN      A       10.0.1.6
dulcinea        IN      A       10.0.1.11
ubuntu          IN      A       10.0.1.8
quijote         IN      A       10.0.2.6
www             IN      CNAME   quijote
bd              IN      CNAME   sancho
</pre>

Ya hemos creado y configurado las tres zonas de **resolución directa** que necesitamos, ahora vamos a pasar con las de **resolución inversa**.

Para estas, podemos tomar como plantilla otro archivo, el `/etc/bind/db.127`. Lo guardaremos de nuevo en `/var/cache/bind` con los nombres `db.1.0.10` y `db.2.0.10`.

<pre>
root@freston:~# cp /etc/bind/db.127 /var/cache/bind/db.1.0.10

root@freston:~# cp /etc/bind/db.127 /var/cache/bind/db.2.0.10
</pre>

Antes de mostrar como quedarían estos ficheros, hay que decir que por cada registro de tipo **A** que tengamos en nuestro archivo que contiene la zona directa, tenemos que añadir un registro de tipo **PTR**.

En mi caso, el fichero `/var/cache/bind/db.1.0.10` tendría este aspecto:

<pre>
$TTL    604800
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN 1.0.10.in-addr.arpa.

11     IN      PTR     dulcinea.javierpzh.gonzalonazareno.org.
6      IN      PTR     freston.javierpzh.gonzalonazareno.org.
8      IN      PTR     sancho.javierpzh.gonzalonazareno.org.
</pre>

En mi caso, el fichero `/var/cache/bind/db.2.0.10` tendría este aspecto:

<pre>
$TTL    604800
@       IN      SOA     freston.javierpzh.gonzalonazareno.org. root.localhost. (
                        20123001        ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      freston.javierpzh.gonzalonazareno.org.

$ORIGIN 2.0.10.in-addr.arpa.

6     IN      PTR     quijote.javierpzh.gonzalonazareno.org.
</pre>

Hemos terminado de crear las diferentes zonas, y tan solo nos quedaría crear la regla **DNAT** en **Dulcinea** para poder realizar las consultas a nuestro servidor DNS instalado en **Freston**.

Añadimos la siguiente regla:

<pre>
iptables -t nat -A PREROUTING -p udp --dport 53 -i eth0 -j DNAT --to 10.0.1.6:53
</pre>

Esta regla, lo que hace, es redirigir el tráfico que proviene desde la interfaz **eth0** y su destino es el puerto **53**, a la dirección **10.0.1.6:53**, es decir, la IP de **Freston** y el puerto **53** de dicha máquina, donde se encontrará nuestro servidor DNS.

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Bien, hemos terminado de configurar nuestro servidor DNS, pero debemos configurar nuestros clientes para que hagan uso de este servidor. Para ello debemos realizar las siguientes modificaciones en cada máquina:

**Dulcinea, Freston y Sancho:**

Vamos a añadir al fichero `/etc/resolv.conf` las siguientes líneas con la información del servidor DNS:

<pre>
nameserver 10.0.1.6
search javierpzh.gonzalonazareno.org
</pre>

**Quijote:**

Vamos a añadir al fichero `/etc/resolv.conf` las siguientes líneas con la información del servidor DNS:

<pre>
nameserver 10.0.1.6
search javierpzh.gonzalonazareno.org
</pre>

Hecho esto, ahora nuestros clientes utilizarán nuestro servidor DNS *bind9* ubicado en *Freston*.

Como ya poseemos un servidor DNS bien configurado, podemos eliminar las entradas referentes a los distintos equipos en el fichero `/etc/hosts` de manera que no nos hará falta hacer uso de la resolución estática.






















## Servidor Web

**En *Quijote (CentOS)* (Servidor que está en la DMZ) vamos a instalar un servidor web *Apache*. Vamos a configurar el servidor para que sea capaz de ejecutar código PHP (para ello vamos a usar un servidor de aplicaciones `php-fpm`). Entrega una captura de pantalla accediendo a `www.(nombre).gonzalonazareno.org/info.php` donde se vea la salida del fichero `info.php`. Investiga la reglas *DNAT* de cortafuegos que tienes que configurar en *Dulcinea* para, cuando accedemos a la IP flotante se acceda al servidor web.**

Antes de instalar el servidor web, vamos a dirigirnos a **Dulcinea** y vamos a crear la regla necesaria para hacer **DNAT**. La regla es la siguiente:

<pre>
iptables -t nat -A PREROUTING -p tcp --dport 80 -i eth0 -j DNAT --to 10.0.2.6:80
</pre>

Esta regla, lo que hace, es redirigir el tráfico que proviene desde la interfaz **eth0** y su destino es el puerto **80**, a la dirección **10.0.2.6:80**, es decir, la IP de **Quijote** y el puerto **80** de dicha máquina, donde se encontrará nuestro servidor web.

Una vez tenemos creada la regla *DNAT* en *Dulcinea*, procedemos a instalar el servidor web **Apache** en *Quijote*, que lo vamos a instalar con este comando, ya que en **CentOS** *Apache* se incluye en el paquete **httpd**:

<pre>
dnf install httpd -y
</pre>

Una vez instalado, debemos abrir los puertos *80* y *443*, que utilizará *Apache*, ya que por defecto, en el *firewall* de *CentOS*, vienen cerrados.

<pre>
[root@quijote ~]# firewall-cmd --permanent --add-service=http
success

[root@quijote ~]# firewall-cmd --permanent --add-service=https
success

[root@quijote ~]# firewall-cmd --reload
success
</pre>

Habilitamos para que este servicio se inicie en cada arranque del sistema.

<pre>
[root@quijote ~]# systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
</pre>

Hecho esto, si nos dirigimos nuestro navegador e introducimos la dirección IP de *Dulcinea*, nos debe aparecer una página como esta:

![.](images/sri_OpenStack_Servidores_Web_Base_de_Datos_y_DNS/quijoteapache.png)

Vemos accediendo a la IP de *Dulcinea* nos muestra la página servida por nuestro servidor web, que se encuentra en *Quijote*, por lo que tanto la regla *DNAT* creada en *Dulcinea*, como el servidor *httpd*, están bien.















## Servidor de base de datos

**En *Sancho (Ubuntu)* vamos a instalar un servidor de base de datos *MariaDB* `bd.(nombre).gonzalonazareno.org`. Entrega una prueba de funcionamiento donde se vea como se realiza una conexión a la base de datos desde *Quijote*.**

El primer paso sería instalar nuestro gestor de base de datos, **MySQL**, por tanto, lo instalamos:

<pre>
apt install mariadb-server mariadb-client -y
</pre>

Una vez lo hemos instalado, vamos a configurar una serie de opciones con el comando `mysql_secure_installation`. Vamos a especificarle una **contraseña de root**, vamos a **eliminar los usuarios anónimos**, vamos a especificar que queremos **desactivar el acceso remoto** a la base de datos, en resumen, vamos a restablecer la base de datos, con nuestras preferencias. Esta es una manera de asegurar el servicio. Aquí muestro el proceso:

<pre>
root@sancho:~# mysql_secure_installation

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

Change the root password? [Y/n] y
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

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
</pre>

Es el turno de crear un usuario propio, asignarle privilegios y especificarle que sea accesible desde *Quijote*, es decir, desde cualquier dirección IP dentro de **10.0.2.XXX**. En realidad, podría poner que solo sea accesible para la IP de *Quijote*, ya que éste tiene la IP estática, pero prefiero hacerlo así por si en algún momento tenemos que cambiar la IP de *Quijote*. Para hacer esto debemos conectarnos como *root*:

<pre>
root@sancho:~# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 57
Server version: 10.3.25-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'javier'@'10.0.2.*' IDENTIFIED BY 'contraseña';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'javier'@'10.0.2.*';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> exit
Bye
</pre>

Una vez tenemos el usuario al que accederemos remotamente, nos quedaría configurar el acceso remoto a nuestro servidor *MySQL*, para ello, debemos modificar el fichero de configuración `/etc/mysql/mariadb.conf.d/50-server.cnf` y buscar la línea `bind-address = 127.0.0.1` y sustituirla por la siguiente:

<pre>
bind-address = 0.0.0.0
</pre>

Esto hará que el servidor escuche las peticiones que provienen de todas las interfaces, a diferencia del punto anterior, que estaba configurado para que solo escuchara en *localhost*.

--------------------------------------------------------------------------------

Hecho esto podemos dirigirnos al **cliente**, es decir, vamos a comprobar el acceso remoto desde *Quijote*. Para ello necesitamos instalar *MySQL*:

<pre>
dnf install mysql-server -y
</pre>

Ahora probamos a acceder:

<pre>
mysql -h 10.0.1.8 -u javier -p
</pre>

El parámetro **-h** indica la dirección del servidor, y los parámetros **-u** y **-p**, como ya sabemos, indican el usuario y la autenticación mediante contraseña.

Obtenemos este resultado:

<pre>
[root@quijote ~]# mysql -h sancho -u javier -p
</pre>




.
