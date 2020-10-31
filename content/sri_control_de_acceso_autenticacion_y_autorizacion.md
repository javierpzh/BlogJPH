Title: Control de acceso, autentificación y autorización
Date: 2020/10/27
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: web, Apache

## Control de acceso

El **Control de acceso** en un servidor web nos permite determinar desde donde podemos acceder a los recursos del servidor.

En **apache2.2** se utilizan las siguientes directivas: [order](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#order), [allow](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#allow) y [deny](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#deny). Un buen manual para que quede más claro lo puedes encontrar en este [enlace](http://systemadmin.es/2011/04/la-directiva-order-de-apache). La directiva [satisfy](http://httpd.apache.org/docs/2.2/mod/core.html#satisfy) controla como se debe comportar el servidor cuando tenemos autorizaciones de control de acceso (allow, deny,…) y tenemos autorizaciones de usuarios (require).

En **apache2.4** se utilizan las siguientes directivas: [Require](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#require), [RequireAll](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#requireall), [RequireAny](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#requireany) y [RequireNone](https://httpd.apache.org/docs/2.4/es/mod/mod_authz_core.html#requirenone)

**1. Comprueba el control de acceso por defecto que tiene el virtual host por defecto (000-default).**

De manera predeterminada, el fichero de configuración `000-default` tiene este control de acceso:

<pre>
VirtualHost *:80
</pre>

Vemos que el control de acceso es de cualquier dirección, mientras el puerto establecido sea el 80.

## Autentificación básica

El servidor web Apache puede acompañarse de distintos módulos para proporcionar diferentes modelos de autenticación. La primera forma que veremos es la más simple. Usamos para ello el módulo de autenticación básica que viene instalada “de serie” con cualquier Apache: [mod_auth_basic](http://httpd.apache.org/docs/2.4/es/mod/mod_auth_basic.html). La configuración que tenemos que añadir en el fichero de definición del Virtual Host a proteger podría ser algo así:

<pre>
<\Directory "/var/www/miweb/privado">
  AuthUserFile "/etc/apache2/claves/passwd.txt"
  AuthName "Palabra de paso"
  AuthType Basic
  Require valid-user
<\/Directory>
</pre>

El método de autentificación básica se indica en la directiva [AuthType](http://httpd.apache.org/docs/2.4/es/mod/core.html#authtype).

- En `Directory` escribimos el directorio a proteger, que puede ser el raíz de nuestro Virtual Host o un directorio interior a este.
- En [AuthUserFile](http://httpd.apache.org/docs/2.4/es/mod/mod_authn_file.html#authuserfile) ponemos el fichero que guardará la información de usuarios y contraseñas que debería de estar, como en este ejemplo, en un directorio que no sea visitable desde nuestro Apache. Ahora comentaremos la forma de generarlo.
- Por último, en [AuthName](http://httpd.apache.org/docs/2.4/es/mod/core.html#authname) personalizamos el mensaje que aparecerá en la ventana del navegador que nos pedirá la contraseña.
- Para controlar el control de acceso, es decir, que usuarios tienen permiso para obtener el recurso utilizamos las siguientes directivas: [AuthGroupFile](http://httpd.apache.org/docs/2.4/es/mod/mod_authz_groupfile.html#authgroupfile), [Require user](http://httpd.apache.org/docs/2.4/es/mod/core.html#require), [Require group](http://httpd.apache.org/docs/2.4/es/mod/core.html#require).

El fichero de contraseñas se genera mediante la utilidad `htpasswd`. Su sintaxis es bien sencilla. Para añadir un nuevo usuario al fichero operamos así:

<pre>
htpasswd /etc/apache2/claves/passwd.txt carolina
New password:
Re-type new password:
Adding password for user carolina
</pre>

Para crear el fichero de contraseñas con la introducción del primer usuario tenemos que añadir la opción `-c` (create) al comando anterior. Si por error la seguimos usando al incorporar nuevos usuarios borraremos todos los anteriores, así que cuidado con esto. Las contraseñas, como podemos ver a continuación, no se guardan en claro. Lo que se almacena es el resultado de aplicar una [función hash](https://es.wikipedia.org/wiki/Funci%C3%B3n_hash):

<pre>
josemaria:rOUetcAKYaliE
carolina:hmO6V4bM8KLdw
alberto:9RjyKKYK.xyhk
</pre>

Para denegar el acceso a algún usuario basta con que borremos la línea correspondiente al mismo. No es necesario que le pidamos a Apache que vuelva a leer su configuración cada vez que hagamos algún cambio en este fichero de contraseñas.

La principal ventaja de este método es su sencillez. Sus inconvenientes: lo incómodo de delegar la generación de nuevos usuarios en alguien que no sea un administrador de sistemas o de hacer un front-end para que sea el propio usuario quien cambie su contraseña. Y, por supuesto, que dichas contraseñas viajan en claro a través de la red. Si queremos evitar esto último podemos crear una [instancia Apache con SSL](https://blog.unlugarenelmundo.es/2008/09/23/chuletillas-y-viii-apache-2-con-ssl-en-debian/).

### Cómo funciona este método de autentificación

Cuando desde el cliente intentamos acceder a una URL que esta controlada por el método de autentificación básico:

**1. El servidor manda una respuesta del tipo 401 *HTTP/1.1 401 Authorization Required* con una cabecera `WWW-Authenticate` al cliente de la forma:**

<pre>
WWW-Authenticate: Basic realm="Palabra de paso"
</pre>

**2. El navegador del cliente muestra una ventana emergente preguntando por el nombre de usuario y contraseña y cuando se rellena se manda una petición con una cabecera `Authorization`**:

<pre>
Authorization: Basic am9zZTpqb3Nl
</pre>

En realidad la información que se manda es el **nombre de usuario** y la **contraseña en base 64**, que se puede decodificar fácilmente con cualquier [utilidad](https://www.base64decode.org/).

## Autentificación tipo digest

La autentificación tipo **digest** soluciona el problema de la transferencia de contraseñas en claro sin necesidad de usar SSL. El procedimiento, como veréis, es muy similar al tipo básico pero cambiando algunas de las directivas y usando la utilidad `htdigest` en lugar de `htpassword` para crear el fichero de contraseñas. El módulo de autenticación necesario suele venir con Apache pero no habilitado por defecto. Para activarlo usamos la utilidad `a2enmod` y, a continuación reiniciamos el servidor Apache:

<pre>
a2enmod auth_digest
/etc/init.d/apache2 restart
</pre>

Luego incluimos una sección como esta en el fichero de configuración de nuestro Virtual Host:

<pre>
<\Directory "/var/www/miweb/privado">
  AuthType Digest
  AuthName "dominio"
  AuthUserFile "/etc/claves/digest.txt"
  Require valid-user
<\/Directory>
</pre>

Como vemos, es muy similar a la configuración necesaria en la autenticación básica. La directiva `AuthName` que en la autenticación básica se usaba para mostrar un mensaje en la ventana que pide el usuario y contraseña, ahora se usa también para identificar un nombre de dominio (realm) que debe de coincidir con el que aparezca después en el fichero de contraseñas. Dicho esto, vamos a generar dicho fichero con la utilidad htdigest:

<pre>
htdigest -c /etc/claves/digest.txt dominio josemaria
Adding password for josemaria in realm dominio.
New password:
Re-type new password:
</pre>

Al igual que ocurría con `htpassword`, la opción `-c` (create) sólo debemos de usarla al crear el fichero con el primer usuario. Luego añadiremos los restantes usuarios prescindiendo de ella. A continuación vemos el fichero que se genera después de añadir un segundo usuario:

<pre>
josemaria:dominio:8d6af4e11e38ee8b51bb775895e11e0f
gemma:dominio:dbd98f4294e2a49f62a486ec070b9b8c
</pre>

### Cómo funciona este método de autentificación

Cuando desde el cliente intentamos acceder a una URL que esta controlada por el método de autentificación de tipo digest:

**1. El servidor manda una respuesta del tipo 401 *HTTP/1.1 401 Authorization Required* con una cabecera `WWW-Authenticate` al cliente de la forma:**

<pre>
WWW-Authenticate: Digest realm="dominio",
                  nonce="cIIDldTpBAA=9b0ce6b8eff03f5ef8b59da45a1ddfca0bc0c485",
                  algorithm=MD5,
                  qop="auth"
</pre>

**2. El navegador del cliente muestra una ventana emergente preguntando por el nombre de usuario y contraseña y cuando se rellena se manda una petición con una cabecera `Authorization`**

<pre>
Authorization	Digest username="jose",
               realm="dominio",
               nonce="cIIDldTpBAA=9b0ce6b8eff03f5ef8b59da45a1ddfca0bc0c485",
               uri="/digest/",
               algorithm=MD5,
               response="814bc0d6644fa1202650e2c404460a21",
               qop=auth,
               nc=00000001,
               cnonce="3da69c14300e446b"
</pre>

La información que se manda es responde que en este caso esta cifrada usando md5 y que se calcula de la siguiente manera:

- Se calcula el md5 del nombre de usuario, del dominio (realm) y la contraseña, la llamamos **HA1**.
- Se calcula el md5 del método de la petición (por ejemplo GET) y de la uri a la que estamos accediendo, la llamamos **HA2**.
- El reultado que se manda es el md5 de HA1, un número aleatorio (nonce), el contador de peticiones (nc), el qop y el HA2.

Una vez que lo recibe el servidor, puede hacer la misma operación y comprobar si la información que se ha enviado es válida, con lo que se permitiría el acceso.

## Ejercicios

**Crea un escenario en Vagrant o reutiliza uno de los que tienes en ejercicios anteriores, que tenga un servidor con una red pública, y una privada y un cliente conectado a la red privada. Crea un host virtual `departamentos.iesgn.org`.**

He creado este fichero Vagrantfile para definir el escenario:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

 config.vm.define :servidor do |servidor|
  servidor.vm.box="debian/buster64"
  servidor.vm.hostname="servidor"
  servidor.vm.network :public_network, :bridge=>"wlo1"
  servidor.vm.network :private_network, ip: "192.168.150.1", virtualbox__intnet: "redprivadaApache"
 end

 config.vm.define :cliente do |cliente|
  cliente.vm.box="debian/buster64"
  cliente.vm.hostname="cliente"
  cliente.vm.network :private_network, ip: "192.168.150.10", virtualbox__intnet: "redprivadaApache"
 end

end
</pre>

Confirmamos que en la máquina **servidor** se han creado correctamente las interfaces de red pública y privada:

<pre>
vagrant@servidor:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86000sec preferred_lft 86000sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:5b:f1:f9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.38/24 brd 192.168.0.255 scope global dynamic eth1
       valid_lft 86009sec preferred_lft 86009sec
    inet6 fe80::a00:27ff:fe5b:f1f9/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:28:bb:c2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.150.1/24 brd 192.168.150.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe28:bbc2/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Podemos ver como la IP pública que posee es la **192.168.0.38** y la IP privada la **192.168.150.1**. Pero aún no hemos cambiado la puerta de enlace para que tenga conectividad a internet a través de la máquina anfitriona:

<pre>
vagrant@servidor:~$ sudo ip r replace default via 192.168.0.1

vagrant@servidor:~$ ip r
default via 192.168.0.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.38
192.168.150.0/24 dev eth2 proto kernel scope link src 192.168.150.1
</pre>

Ya sí puede acceder a mi router doméstico y por tanto posee conexión.

Vamos a hacer lo mismo para la máquina **cliente**. Vemos las interfaces de red:

<pre>
vagrant@cliente:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 85783sec preferred_lft 85783sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:93:04:32 brd ff:ff:ff:ff:ff:ff
    inet 192.168.150.10/24 brd 192.168.150.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe93:432/64 scope link
       valid_lft forever preferred_lft forever
</pre>

Nos ha creado bien la dirección IP de la red privada, que es la **192.168.150.10**. Cambiamos la puerta de enlace para que tenga conexión a la máquina servidor:

<pre>
vagrant@cliente:~$ sudo ip r replace default via 192.168.150.1

vagrant@cliente:~$ ip r
default via 192.168.150.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.150.0/24 dev eth1 proto kernel scope link src 192.168.150.10
</pre>

Y ahora sí, tenemos configuradas las dos máquinas correctamente y podemos empezar a realizar los procedimientos.

Vamos a instalar **apache**. Para esto, antes de nada voy a actualizar los paquetes necesarios, y voy a desinstalar los que ya no hagan falta. Esto lo hago porque la box que estoy utilizando es de **Debian 10.4** y a día de hoy la versión estable es la **10.6**:

<pre>
apt update && apt upgrade -y && apt autoremove -y && apt install apache2 -y
</pre>

Una vez instalado Apache, podemos empezar a realizar las configuraciones. Lo primero es crear el sitio web, para ello:

Creamos el archivo de configuración del sitio web. Podemos copiar el fichero por defecto, que se encuentra en `/etc/apache2/sites-available` y a partir de éste, personalizar el nuevo:

<pre>
root@servidor:/etc/apache2/sites-available# cp 000-default.conf departamentos.conf

root@servidor:/etc/apache2/sites-available# nano departamentos.conf
</pre>

Editamos las siguientes líneas del fichero `departamentos.conf`:

<pre>
ServerName www.departamentos.iesgn.org
DocumentRoot /var/www/departamentos
</pre>

Una vez terminado este fichero, tenemos que activar esta página:

<pre>
root@servidor:/etc/apache2/sites-available# a2ensite departamentos.conf
Enabling site departamentos.
To activate the new configuration, you need to run:
  systemctl reload apache2
</pre>

Ya solo nos falta crear el `index.html` que hemos especificado en la configuración de la página que se iba a encontrar en la ruta `/var/www/departamentos`:

<pre>
root@servidor:/var/www# mkdir departamentos

root@servidor:/var/www# cd departamentos/

root@servidor:/var/www/departamentos# nano index.html
</pre>

Reiniciamos el servicio y ya podemos visualizar la página.

<pre>
systemctl restart apache2
</pre>

Ojo, para poder ver esta web, debemos indicar en el archivo `/etc/hosts` de nuestra máquina anfitriona esta línea:

<pre>
192.168.0.38    departamentos.iesgn.org
</pre>




**1. A la URL `departamentos.iesgn.org/intranet` sólo se debe tener acceso desde el cliente de la red local, y no se pueda acceder desde la anfitriona por la red pública. A la URL `departamentos.iesgn.org/internet`, sin embargo, sólo se debe tener acceso desde la anfitriona por la red pública, y no desde la red local.**

Lo primero sería crear en `/var/www/departamentos` dos carpetas: una para **intranet** y otra para **internet**, y dentro de ellas crear un fichero `index.html`:

<pre>
root@servidor:/var/www/departamentos# mkdir intranet

root@servidor:/var/www/departamentos# cd intranet/

root@servidor:/var/www/departamentos/intranet# cp ../index.html ./

root@servidor:/var/www/departamentos/intranet# nano index.html

root@servidor:/var/www/departamentos/intranet# cd ..

root@servidor:/var/www/departamentos# mkdir internet

root@servidor:/var/www/departamentos# cp index.html ./internet/

root@servidor:/var/www/departamentos# cd internet/

root@servidor:/var/www/departamentos/internet# nano index.html
</pre>

Una vez tenemos creados las dos páginas webs, es el momento de establecer el control de acceso.

Las restricciones de acceso se llevan a cabo en el fichero de configuración de la web, es decir, en `/etc/apache2/sites-available/departamentos.conf`. Se nos pide que a la página `Intranet` pueda acceder la máquina conectada a la red local **192.168.150.0/24**, es decir nuestra mv, cuya IP es **192.168.150.10**, y a la página `Internet` cualquier equipo que no pertenezca a la red local.
Para ello el fichero debe quedar así:

<pre>
<\Directory /var/www/departamentos/intranet \>
 Require ip 192.168.150
<\/Directory\>

<\Directory /var/www/departamentos/internet \>
 <\RequireAll\>
   Require all granted
   Require not ip 192.168.150
 <\/RequireAll\>
<\/Directory\>
</pre>

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Con esto lo que estamos haciendo es:

- **Máquina anfitrión:** permitirle el acceso a la página `departamentos.iesgn.org/internet/`.

    - Si accedemos a `departamentos.iesgn.org/internet/`:

    ![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/anfitrioninternet.png)

    - Si accedemos a `departamentos.iesgn.org/intranet/`:

    ![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/anfitrionintranet.png)

- **Máquina cliente:** permitirle el acceso a la página `departamentos.iesgn.org/intranet/`.

    - Si accedemos a `departamentos.iesgn.org/internet/`:

    ![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/mvinternet.png)

    - Si accedemos a `departamentos.iesgn.org/intranet/`:

    ![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/mvintranet.png)


**2. Autentificación básica. Limita el acceso a la URL `departamentos.iesgn.org/secreto`. Comprueba las cabeceras de los mensajes HTTP que se intercambian entre el servidor y el cliente. ¿Cómo se manda la contraseña entre el cliente y el servidor?. Entrega una breve explicación del ejercicio.**

Lo primero sería crear en `/var/www/departamentos` la carpeta **secreto** y dentro de ella crear un fichero `index.html`:

<pre>
root@servidor:/var/www/departamentos# mkdir secreto

root@servidor:/var/www/departamentos# cp index.html ./secreto/

root@servidor:/var/www/departamentos# cd secreto/

root@servidor:/var/www/departamentos/secreto# nano index.html
</pre>

Ahora vamos a configurar para que a la página `departamentos.iesgn.org/secreto` solo se pueda acceder si la persona está autorizada y posee un usuario y una contraseña.

Para ello, lo primero sería crear el **archivo de contraseñas** de Apache:

<pre>
root@servidor:/var/www/departamentos/secreto# htpasswd -c /var/www/departamentos/secreto/.htpasswd javier
New password:
Re-type new password:
Adding password for user javier
</pre>

Si quisiéramos añadir un nuevo usuario, deberíamos introducir el mismo comando pero sin la opción `-c`, ya que sino, nos crearía un nuevo un archivo machacando el ya existente.

Nos quedaría especificar en el `/etc/apache2/sites-available/departamentos.conf` esta configuración de autenticación básica. Debemos añadir algo así:

<pre>
<\Directory /var/www/departamentos/secreto \>
 AuthType Basic
 AuthName "Identifiquese para acceder a esta pagina"
 AuthUserFile /var/www/departamentos/secreto/.htpasswd
 Require valid-user
<\/Directory\>
</pre>

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Si ahora probamos a acceder a `departamentos.iesgn.org/secreto`:

![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacion.png)

Vemos que nos pide que iniciemos sesión ya que el contenido está protegido. Vamos a ver que puede pasar:

- Iniciamos sesión correctamente:

![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacioncompleta.png)

- No iniciamos sesión o de manera incorrecta:

![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacionfallida.png)

Si capturamos el tráfico con `tcpdump`:

<pre>
root@servidor:/etc/apache2/sites-available# tcpdump -vi eth2
tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 262144 bytes
14:55:27.187941 IP (tos 0x0, ttl 64, id 24679, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.48608 > server-13-224-119-105.mad50.r.cloudfront.net.https: Flags [S], cksum 0xfb72 (correct), seq 678382085, win 64240, options [mss 1460,sackOK,TS val 1814746981 ecr 0,nop,wscale 7], length 0
14:55:29.144973 IP (tos 0x0, ttl 64, id 29037, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.39088 > server-13-224-119-76.mad50.r.cloudfront.net.https: Flags [S], cksum 0x3657 (correct), seq 1403051891, win 64240, options [mss 1460,sackOK,TS val 3963388188 ecr 0,nop,wscale 7], length 0
14:55:30.164161 IP (tos 0x0, ttl 64, id 29038, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.39088 > server-13-224-119-76.mad50.r.cloudfront.net.https: Flags [S], cksum 0x325c (correct), seq 1403051891, win 64240, options [mss 1460,sackOK,TS val 3963389207 ecr 0,nop,wscale 7], length 0
14:55:30.398228 IP (tos 0x0, ttl 64, id 23179, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.44642 > 192.168.0.38.http: Flags [S], cksum 0x0f96 (correct), seq 3591738047, win 64240, options [mss 1460,sackOK,TS val 2129104776 ecr 0,nop,wscale 7], length 0
14:55:30.398257 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.0.38.http > 192.168.150.10.44642: Flags [S.], cksum 0x17b0 (incorrect -> 0x5d66), seq 3316736439, ack 3591738048, win 65160, options [mss 1460,sackOK,TS val 411070110 ecr 2129104776,nop,wscale 6], length 0
14:55:30.398468 IP (tos 0x0, ttl 64, id 23180, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44642 > 192.168.0.38.http: Flags [.], cksum 0x88c4 (correct), ack 1, win 502, options [nop,nop,TS val 2129104776 ecr 411070110], length 0
14:55:30.398558 IP (tos 0x0, ttl 64, id 23181, offset 0, flags [DF], proto TCP (6), length 393)
    192.168.150.10.44642 > 192.168.0.38.http: Flags [P.], cksum 0x9e2c (correct), seq 1:342, ack 1, win 502, options [nop,nop,TS val 2129104777 ecr 411070110], length 341: HTTP, length: 341
	GET /secreto HTTP/1.1
	Host: departamentos.iesgn.org
	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
	Accept-Language: en-US,en;q=0.5
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Upgrade-Insecure-Requests: 1

14:55:30.398589 IP (tos 0x0, ttl 64, id 19904, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.0.38.http > 192.168.150.10.44642: Flags [.], cksum 0x17a8 (incorrect -> 0x856f), ack 342, win 1013, options [nop,nop,TS val 411070110 ecr 2129104777], length 0
14:55:30.399333 IP (tos 0x0, ttl 64, id 19905, offset 0, flags [DF], proto TCP (6), length 816)
    192.168.0.38.http > 192.168.150.10.44642: Flags [P.], cksum 0x1aa4 (incorrect -> 0x068e), seq 1:765, ack 342, win 1013, options [nop,nop,TS val 411070111 ecr 2129104777], length 764: HTTP, length: 764
	HTTP/1.1 401 Unauthorized
	Date: Sat, 31 Oct 2020 14:55:30 GMT
	Server: Apache/2.4.38 (Debian)
	WWW-Authenticate: Basic realm="Identifiquese para acceder a esta pagina"
	Content-Length: 470
	Keep-Alive: timeout=5, max=100
	Connection: Keep-Alive
	Content-Type: text/html; charset=iso-8859-1

	<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
	<html><head>
	<title>401 Unauthorized</title>
	</head><body>
	<h1>Unauthorized</h1>
	<p>This server could not verify that you
	are authorized to access the document
	requested.  Either you supplied the wrong
	credentials (e.g., bad password), or your
	browser doesn't understand how to supply
	the credentials required.</p>
	<hr>
	<address>Apache/2.4.38 (Debian) Server at departamentos.iesgn.org Port 80</address>
	</body></html>
14:55:30.399511 IP (tos 0x0, ttl 64, id 23182, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44642 > 192.168.0.38.http: Flags [.], cksum 0x8472 (correct), ack 765, win 501, options [nop,nop,TS val 2129104777 ecr 411070111], length 0
14:55:32.180572 IP (tos 0x0, ttl 64, id 29039, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.39088 > server-13-224-119-76.mad50.r.cloudfront.net.https: Flags [S], cksum 0x2a7c (correct), seq 1403051891, win 64240, options [mss 1460,sackOK,TS val 3963391223 ecr 0,nop,wscale 7], length 0
14:55:34.356162 IP (tos 0x0, ttl 64, id 63813, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.55928 > server-13-224-119-20.mad50.r.cloudfront.net.https: Flags [S], cksum 0x225e (correct), seq 2313360561, win 64240, options [mss 1460,sackOK,TS val 864854197 ecr 0,nop,wscale 7], length 0
14:55:35.406072 IP (tos 0x0, ttl 64, id 19906, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.0.38.http > 192.168.150.10.44642: Flags [F.], cksum 0x17a8 (incorrect -> 0x6ee3), seq 765, ack 342, win 1013, options [nop,nop,TS val 411075117 ecr 2129104777], length 0
14:55:35.426077 IP (tos 0x0, ttl 64, id 23183, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44642 > 192.168.0.38.http: Flags [F.], cksum 0x5d3f (correct), seq 342, ack 766, win 501, options [nop,nop,TS val 2129109804 ecr 411075117], length 0
14:55:35.426153 IP (tos 0x0, ttl 64, id 19907, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.0.38.http > 192.168.150.10.44642: Flags [.], cksum 0x17a8 (incorrect -> 0x5b2b), ack 343, win 1013, options [nop,nop,TS val 411075137 ecr 2129109804], length 0
14:55:36.849437 IP (tos 0x0, ttl 64, id 60909, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.44644 > 192.168.0.38.http: Flags [S], cksum 0x3962 (correct), seq 286463169, win 64240, options [mss 1460,sackOK,TS val 2129111227 ecr 0,nop,wscale 7], length 0
14:55:36.849491 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.0.38.http > 192.168.150.10.44644: Flags [S.], cksum 0x17b0 (incorrect -> 0x72df), seq 4071043042, ack 286463170, win 65160, options [mss 1460,sackOK,TS val 411076560 ecr 2129111227,nop,wscale 6], length 0
14:55:36.849716 IP (tos 0x0, ttl 64, id 60910, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44644 > 192.168.0.38.http: Flags [.], cksum 0x9e3d (correct), ack 1, win 502, options [nop,nop,TS val 2129111227 ecr 411076560], length 0
14:55:36.849951 IP (tos 0x0, ttl 64, id 60911, offset 0, flags [DF], proto TCP (6), length 440)
    192.168.150.10.44644 > 192.168.0.38.http: Flags [P.], cksum 0xb269 (correct), seq 1:389, ack 1, win 502, options [nop,nop,TS val 2129111228 ecr 411076560], length 388: HTTP, length: 388
	GET /secreto HTTP/1.1
	Host: departamentos.iesgn.org
	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
	Accept-Language: en-US,en;q=0.5
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Upgrade-Insecure-Requests: 1
	Authorization: Basic amF2aWVyOm1hcnRhZ3VhcGE3

14:55:36.849981 IP (tos 0x0, ttl 64, id 63565, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.0.38.http > 192.168.150.10.44644: Flags [.], cksum 0x17a8 (incorrect -> 0x9ab8), ack 389, win 1013, options [nop,nop,TS val 411076561 ecr 2129111228], length 0
14:55:36.850484 IP (tos 0x0, ttl 64, id 63566, offset 0, flags [DF], proto TCP (6), length 664)
    192.168.0.38.http > 192.168.150.10.44644: Flags [P.], cksum 0x1a0c (incorrect -> 0xf9e4), seq 1:613, ack 389, win 1013, options [nop,nop,TS val 411076561 ecr 2129111228], length 612: HTTP, length: 612
	HTTP/1.1 301 Moved Permanently
	Date: Sat, 31 Oct 2020 14:55:36 GMT
	Server: Apache/2.4.38 (Debian)
	Location: http://departamentos.iesgn.org/secreto/
	Content-Length: 336
	Keep-Alive: timeout=5, max=100
	Connection: Keep-Alive
	Content-Type: text/html; charset=iso-8859-1

	<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
	<html><head>
	<title>301 Moved Permanently</title>
	</head><body>
	<h1>Moved Permanently</h1>
	<p>The document has moved <a href="http://departamentos.iesgn.org/secreto/">here</a>.</p>
	<hr>
	<address>Apache/2.4.38 (Debian) Server at departamentos.iesgn.org Port 80</address>
	</body></html>
14:55:36.850689 IP (tos 0x0, ttl 64, id 60912, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44644 > 192.168.0.38.http: Flags [.], cksum 0x9a54 (correct), ack 613, win 501, options [nop,nop,TS val 2129111228 ecr 411076561], length 0
14:55:36.865574 IP (tos 0x0, ttl 64, id 2136, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.44646 > 192.168.0.38.http: Flags [S], cksum 0xa277 (correct), seq 3767262240, win 64240, options [mss 1460,sackOK,TS val 2129111243 ecr 0,nop,wscale 7], length 0
14:55:36.865602 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.0.38.http > 192.168.150.10.44646: Flags [S.], cksum 0x17b0 (incorrect -> 0x51ec), seq 284072851, ack 3767262241, win 65160, options [mss 1460,sackOK,TS val 411076577 ecr 2129111243,nop,wscale 6], length 0
14:55:36.865790 IP (tos 0x0, ttl 64, id 2137, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44646 > 192.168.0.38.http: Flags [.], cksum 0x7d4a (correct), ack 1, win 502, options [nop,nop,TS val 2129111243 ecr 411076577], length 0
14:55:36.865898 IP (tos 0x0, ttl 64, id 2138, offset 0, flags [DF], proto TCP (6), length 441)
    192.168.150.10.44646 > 192.168.0.38.http: Flags [P.], cksum 0xd602 (correct), seq 1:390, ack 1, win 502, options [nop,nop,TS val 2129111243 ecr 411076577], length 389: HTTP, length: 389
	GET /secreto/ HTTP/1.1
	Host: departamentos.iesgn.org
	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
	Accept-Language: en-US,en;q=0.5
	Accept-Encoding: gzip, deflate
	Authorization: Basic amF2aWVyOm1hcnRhZ3VhcGE3
	Connection: keep-alive
	Upgrade-Insecure-Requests: 1

14:55:36.865915 IP (tos 0x0, ttl 64, id 103, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.0.38.http > 192.168.150.10.44646: Flags [.], cksum 0x17a8 (incorrect -> 0x79c6), ack 390, win 1013, options [nop,nop,TS val 411076577 ecr 2129111243], length 0
14:55:36.866216 IP (tos 0x0, ttl 64, id 60913, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44644 > 192.168.0.38.http: Flags [F.], cksum 0x9a43 (correct), seq 389, ack 613, win 501, options [nop,nop,TS val 2129111244 ecr 411076561], length 0
14:55:36.866844 IP (tos 0x0, ttl 64, id 104, offset 0, flags [DF], proto TCP (6), length 541)
    192.168.0.38.http > 192.168.150.10.44646: Flags [P.], cksum 0x1991 (incorrect -> 0x5684), seq 1:490, ack 390, win 1013, options [nop,nop,TS val 411076578 ecr 2129111243], length 489: HTTP, length: 489
	HTTP/1.1 200 OK
	Date: Sat, 31 Oct 2020 14:55:36 GMT
	Server: Apache/2.4.38 (Debian)
	Last-Modified: Tue, 27 Oct 2020 16:13:06 GMT
	ETag: "dc-5b2a952786fef-gzip"
	Accept-Ranges: bytes
	Vary: Accept-Encoding
	Content-Encoding: gzip
	Content-Length: 153
	Keep-Alive: timeout=5, max=100
	Connection: Keep-Alive
	Content-Type: text/html

14:55:36.866928 IP (tos 0x0, ttl 64, id 63567, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.0.38.http > 192.168.150.10.44644: Flags [F.], cksum 0x17a8 (incorrect -> 0x9831), seq 613, ack 390, win 1013, options [nop,nop,TS val 411076578 ecr 2129111244], length 0
14:55:36.867025 IP (tos 0x0, ttl 64, id 2139, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44646 > 192.168.0.38.http: Flags [.], cksum 0x79da (correct), ack 490, win 501, options [nop,nop,TS val 2129111245 ecr 411076578], length 0
14:55:36.867128 IP (tos 0x0, ttl 64, id 60914, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44644 > 192.168.0.38.http: Flags [.], cksum 0x9a30 (correct), ack 614, win 501, options [nop,nop,TS val 2129111245 ecr 411076578], length 0
14:55:37.269131 IP (tos 0x0, ttl 64, id 2140, offset 0, flags [DF], proto TCP (6), length 354)
    192.168.150.10.44646 > 192.168.0.38.http: Flags [P.], cksum 0xf234 (correct), seq 390:692, ack 490, win 501, options [nop,nop,TS val 2129111647 ecr 411076578], length 302: HTTP, length: 302
	GET /favicon.ico HTTP/1.1
	Host: departamentos.iesgn.org
	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
	Accept: image/webp,*/*
	Accept-Language: en-US,en;q=0.5
	Accept-Encoding: gzip, deflate
	Authorization: Basic amF2aWVyOm1hcnRhZ3VhcGE3
	Connection: keep-alive

14:55:37.269361 IP (tos 0x0, ttl 64, id 105, offset 0, flags [DF], proto TCP (6), length 553)
    192.168.0.38.http > 192.168.150.10.44646: Flags [P.], cksum 0x199d (incorrect -> 0xde2d), seq 490:991, ack 692, win 1009, options [nop,nop,TS val 411076980 ecr 2129111647], length 501: HTTP, length: 501
	HTTP/1.1 404 Not Found
	Date: Sat, 31 Oct 2020 14:55:37 GMT
	Server: Apache/2.4.38 (Debian)
	Content-Length: 285
	Keep-Alive: timeout=5, max=99
	Connection: Keep-Alive
	Content-Type: text/html; charset=iso-8859-1

	<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
	<html><head>
	<title>404 Not Found</title>
	</head><body>
	<h1>Not Found</h1>
	<p>The requested URL was not found on this server.</p>
	<hr>
	<address>Apache/2.4.38 (Debian) Server at departamentos.iesgn.org Port 80</address>
	</body></html>
14:55:37.269526 IP (tos 0x0, ttl 64, id 2141, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.150.10.44646 > 192.168.0.38.http: Flags [.], cksum 0x7393 (correct), ack 991, win 501, options [nop,nop,TS val 2129111647 ecr 411076980], length 0
14:55:37.278921 IP (tos 0x0, ttl 64, id 43417, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.39096 > server-13-224-119-76.mad50.r.cloudfront.net.https: Flags [S], cksum 0x1c44 (correct), seq 527371755, win 64240, options [mss 1460,sackOK,TS val 3963396321 ecr 0,nop,wscale 7], length 0
14:55:37.566369 IP (tos 0x0, ttl 64, id 34771, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.52160 > server-13-224-119-24.mad50.r.cloudfront.net.https: Flags [S], cksum 0xcb58 (correct), seq 3011471053, win 64240, options [mss 1460,sackOK,TS val 3860977696 ecr 0,nop,wscale 7], length 0
14:55:38.320152 IP (tos 0x0, ttl 64, id 43418, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.39096 > server-13-224-119-76.mad50.r.cloudfront.net.https: Flags [S], cksum 0x1833 (correct), seq 527371755, win 64240, options [mss 1460,sackOK,TS val 3963397362 ecr 0,nop,wscale 7], length 0
14:55:38.580440 IP (tos 0x0, ttl 64, id 34772, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.52160 > server-13-224-119-24.mad50.r.cloudfront.net.https: Flags [S], cksum 0xc762 (correct), seq 3011471053, win 64240, options [mss 1460,sackOK,TS val 3860978710 ecr 0,nop,wscale 7], length 0
14:55:40.500879 IP (tos 0x0, ttl 64, id 43419, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.39096 > server-13-224-119-76.mad50.r.cloudfront.net.https: Flags [S], cksum 0x0fae (correct), seq 527371755, win 64240, options [mss 1460,sackOK,TS val 3963399543 ecr 0,nop,wscale 7], length 0
14:55:40.596930 IP (tos 0x0, ttl 64, id 34773, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.150.10.52160 > server-13-224-119-24.mad50.r.cloudfront.net.https: Flags [S], cksum 0xbf82 (correct), seq 3011471053, win 64240, options [mss 1460,sackOK,TS val 3860980726 ecr 0,nop,wscale 7], length 0
</pre>



**3. Cómo hemos visto la autentificación básica no es segura, modifica la autentificación para que sea del tipo `digest`, y sólo sea accesible a los usuarios pertenecientes al grupo `directivos`. Comprueba las cabeceras de los mensajes HTTP que se intercambian entre el servidor y el cliente. ¿Cómo funciona esta autentificación?**

(Me he equivocado y he añadido los usuarios al grupo **gruposecreto** en vez de **directivos**).

Para llevar a cabo una autenticación de tipo **Digest**, antes debemos habilitar su módulo:

<pre>
a2enmod auth_digest
</pre>

 El proceso es muy parecido al anterior, por tanto lo primero sería crear el **archivo de contraseñas**:

<pre>
root@servidor:/var/www/departamentos/secreto# htdigest -c /var/www/departamentos/secreto/.htdigest gruposecreto javier
Adding password for javier in realm gruposecreto.
New password:
Re-type new password:
</pre>

A diferencia de la autenticación básica, en esta debemos añadir un nombre de domino, es decir, un grupo al que va a pertenecer el usuario.

Si quisiéramos añadir un nuevo usuario, deberíamos introducir el mismo comando pero sin la opción `-c`, ya que sino, nos crearía un nuevo un archivo machacando el ya existente.

Nos quedaría especificar en el `/etc/apache2/sites-available/departamentos.conf` esta configuración de autenticación básica. Debemos añadir algo así:

<pre>
<\Directory /var/www/departamentos/secreto \>
 AuthType Digest
 AuthName "gruposecreto"
 AuthUserFile /var/www/departamentos/secreto/.htdigest
 Require valid-user
<\/Directory\>
</pre>

**Atención:** a esta configuración hay que eliminarle los carácteres `\`, que he tenido que introducir para escapar los carácteres siguientes, así que en caso de querer copiar la configuración, debemos tener en cuenta esto.

Reiniciamos el servicio:

<pre>
systemctl restart apache2
</pre>

Si ahora probamos a acceder a `departamentos.iesgn.org/secreto`:

![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacionhtdigest.png)

Vemos que nos pide que iniciemos sesión ya que el contenido está protegido. Vamos a ver que puede pasar:

- Iniciamos sesión correctamente:

![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacioncompletahtdigest.png)

- No iniciamos sesión o de manera incorrecta:

![.](images/sri_control_de_acceso_autenticacion_y_autorizacion/autenticacionfallida.png)


**4. Vamos a combinar el control de acceso (tarea 6) y la autenticación (tareas 7 y 8), y vamos a configurar el virtual host para que se comporte de la siguiente manera: el acceso a la URL `departamentos.iesgn.org/secreto` se hace forma directa desde la intranet, desde la red pública te pide la autenticación. Muestra el resultado al profesor.**
