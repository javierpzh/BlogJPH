Title: OpenStack: Servidores Web, Base de Datos y DNS
Date: 2020/12/18
Category: Servicios de Redes e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: OpenStack, bind9, Apache, MySQL, MariaDB

## Servidor DNS

**Vamos a instalar un servidor DNS en *freston* que nos permita gestionar la resolución directa e inversa de nuestros nombres. Cada alumno va a poseer un servidor dns con autoridad sobre un subdominio de nuestro dominio principal `gonzalonazareno.org`, que se llamará `(nombre).gonzalonazareno.org`. A partir de este momento no será necesario la resolución estática en los servidores.**

**Determina la regla DNAT en *dulcinea* para que podamos hacer consultas DNS desde el exterior**

**Configura de forma adecuada todas las máquinas para que usen como servidor DNS a *freston*.**

**Indica al profesor el nombre de tu dominio para que pueda realizar la delegación en el servidor DNS principal *papion-dns*.**

**Comprueba que los servidores tienen configurados el nuevo nombre de dominio de forma adecuada después de volver a reiniciar el servidor (o tomar una nueva configuración DHCP). Para que el servidor tenga el *FQDN* debes tener configurado de forma correcta el parámetro *domain* y el parámetro *search* en el fichero `/etc/resolv.conf`, además debemos evitar que este fichero se sobreescriba con los datos que manda el servidor DHCP de *OpenStack*. Quizás sea buena idea mirar la configuración de *cloud-init*. Documenta la configuración que has tenido que modificar y muestra el contenido del fichero `/etc/resolv.conf` y la salida del comando `hostname -f` después de un reinicio.**

**El servidor DNS se va a configurar en un principio de la siguiente manera:**

- **El servidor DNS se llama `freston.(nombre).gonzalonazareno.org` y va a ser el servidor con autoridad para la zona `(nombre).gonzalonazareno.org`.**



- **El servidor debe resolver el nombre de todas las máquinas.**



- **El servidor debe resolver los distintos servicios (virtualhost, servidor de base de datos, servidor LDAP, ...).**



- **Debes determinar cómo vas a nombrar a dulcinea, para que seamos capaz de resolver la IP flotante y la ip fija. Para ello vamos a usar vistas en bind9.**



- **Debes considerar la posibilidad de hacer tres zonas de resolución inversa: para las redes `10.0.0.0/24`, `10.0.1.0/24` y `10.0.2.0/24`. (No vamos a crear la zona inversa para la red externa de IP flotantes). para resolver IP fijas y flotantes del *cloud*.**




**Entrega el resultado de las siguientes consultas desde un cliente interno a nuestra red y otro externo:**

- **El servidor DNS con autoridad sobre la zona del dominio `(nombre).gonzalonazareno.org`**



- **La dirección IP de *dulcinea*.**



- **Una resolución de `www`.**



- **Un resolución inversa de IP fija en cada una de las redes. (Esta consulta sólo funcionará desde una máquina interna).**




## Servidor Web

**En *quijote (CentOs)* (Servidor que está en la DMZ) vamos a instalar un servidor web *Apache*. Configura el servidor para que sea capaz de ejecutar código PHP (para ello vamos a usar un servidor de aplicaciones `php-fpm`). Entrega una captura de pantalla accediendo a `www.(nombre).gonzalonazareno.org/info.php` donde se vea la salida del fichero `info.php`. Investiga la reglas DNAT de cortafuegos que tienes que configurar en *dulcinea* para, cuando accedemos a la IP flotante se acceda al servidor web.**




## Servidor de base de datos

**En *sancho (Ubuntu)* vamos a instalar un servidor de base de datos *MariaDB* `bd.(nombre).gonzalonazareno.org`. Entrega una prueba de funcionamiento donde se vea como se realiza una conexión a la base de datos desde *quijote*.**








![.](images/sri_OpenStack_Servidores_Web_Base_de_Datos_y_DNS/.png)
