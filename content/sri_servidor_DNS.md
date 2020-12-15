Title: Servidor DNS
Category: Servicios de Red e Internet
Date: 2020/12/11
Header_Cover: theme/images/banner-servicios.jpg
Tags: DNS, bind9, dnsmasq

### Escenario

1. **En nuestra red local tenemos un servidor Web que sirve dos páginas web: `www.iesgn.org`, `departamentos.iesgn.org`.**

2. **Vamos a instalar en nuestra red local un servidor DNS (lo puedes instalar en el mismo equipo que tiene el servidor web).**

3. **Voy a suponer en este documento que el nombre del servidor DNS va a ser `pandora.iesgn.org`. El nombre del servidor de tu prácticas será `tunombre.iesgn.org`.**

### Servidor DNSmasq

Las dos páginas servidas por *Apache2* las he creado pero voy a omitir su explicación, pues ya tengo otras entradas en las que hablo expresamente de esto. Te dejo este enlace por si quieres saber algo más de [Apache2](https://javierpzh.github.io/tag/apache.html).

**Instala el servidor DNS *dnsmasq* en `pandora.iesgn.org` y configúralo para que los clientes puedan conocer los nombres necesarios.**

He creado una instancia en el *cloud* de **OpenStack** que será la máquina que actuará como **servidor**, posee una dirección IP **172.22.200.174**.

Una vez en ella, lo primero que debemos hacer es instalar el siguiente paquete:

<pre>
apt install dnsmasq -y
</pre>

Para comenzar a configurar el servidor *dnsmasq*, empezaremos por descomentar la siguiente línea en el fichero `/etc/dnsmasq.conf` para que el servidor *dnsmasq* pueda leer en caso de que sea necesario, es decir, cuando él mismo no pueda resolver una petición, la configuración del fichero `/etc/resolv.conf`:

<pre>
strict-order
</pre>

En este fichero, también debemos buscar la directiva **interface**, descomentarla y establecerle como valor, la interfaz de red de nuestra máquina, en mi caso es la **eth0**, de manera que el resultado sería este:

<pre>
interface=eth0
</pre>

Con esto, ya habríamos terminado la configuración del servicio `dnsmasq`.

Vamos a cambiar el nombre de la máquina, para ello, editamos el fichero `/etc/hostname`. En mi caso la máquina se llamará `javierpzh` por lo que el contenido del fichero es:

<pre>
javierpzh
</pre>

Si vemos, actualmente el *prompt* de la máquina posee este aspecto:

<pre>
root@servidor-dns:~#
</pre>

Debemos reiniciar la máquina para que este cambio se aplique, pero antes, vamos a modificar el fichero `/etc/hosts` para cambiar el **hostname** y el **FQDN** de la máquina.

Antes de hacer esto, por experiencia, ya sé, que al reiniciar la máquina se restablecerá el fichero `/etc/hosts`. Para cambiar este funcionamiento, tenemos que dirigirnos al fichero `/etc/cloud/cloud.cfg` y buscar esta línea:

<pre>
manage_etc_hosts: true
</pre>

Le cambiamos el valor a *false*:

<pre>
manage_etc_hosts: false
</pre>

Ahora sí, vamos a cambiar el fichero `/etc/hosts`. Nos interesa cambiar la línea con la dirección **127.0.1.1** que es la que hace referencia a la propia máquina. Establezco como **FQDN** `javierpzh.iesgn.org` y como **hostname**, `javierpzh`:

<pre>
127.0.1.1 javierpzh.iesgn.org javierpzh
</pre>

Hecho esto, vamos a reiniciar la máquina con el comando `reboot`.

Si después del reinicio volvemos a mirar el *prompt*:

<pre>
root@javierpzh:~#
</pre>

Vemos como hemos modificado correctamente el *hostname* de la máquina.

Vamos a mirar también el *FQDN*:

<pre>
root@javierpzh:~# hostname
javierpzh

root@javierpzh:~# hostname -f
javierpzh.iesgn.org
</pre>

También lo hemos modificado. Con esto, habríamos terminado todo el trabajo en la máquina *servidor*.

#### Tarea 1: Modifica los clientes para que utilicen el nuevo servidor DNS. Realiza una consulta a `www.iesgn.org`, y a `www.josedomingo.org`. Realiza una prueba de funcionamiento para comprobar que el servidor *dnsmasq* funciona como caché DNS. Muestra el fichero hosts del cliente para demostrar que no estás utilizando resolución estática. Realiza una consulta directa al servidor *dnsmasq*. ¿Se puede realizar resolución inversa?**

La máquina que actuará como **cliente**, será mi máquina anfitriona.

Una vez en el *cliente*, vamos a instalar el paquete `dnsutils`, para poder hacer uso de la herramienta `dig`:

<pre>
apt install dnsutils -y
</pre>

Una vez instalado este paquete, vamos a añadir en el fichero `/etc/resolv.conf`, que contiene los servidores DNS que va a utilizar esta máquina, esta línea para indicar que haga uso del servidor DNS que hemos creado:

<pre>
nameserver 192.168.150.50

nameserver 10.0.2.3
</pre>

Añadimos la línea `nameserver 192.168.150.10`, cuya dirección corresponde a la IP de la máquina servidor.

Hecho esto, podemos realizar una consulta a `www.iesgn.org`:

<pre>
root@debian:~# dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 62534
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; AUTHORITY SECTION:
org.			900	IN	SOA	a0.org.afilias-nst.info. noc.afilias-nst.info. 2014176427 1800 900 604800 86400

;; Query time: 56 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: jue dic 10 20:39:07 CET 2020
;; MSG SIZE  rcvd: 105

root@debian:~#
</pre>

Vemos como nos está respondiendo nuestro servidor DNS, ya que nos indica que la respuesta viene de la IP 192.168.150.10.

Realizo una consulta a `departamentos.iesgn.org`, dirección a la que ya había realizado una consulta anteriormente, por lo que tendría que tener esta consulta en caché:

<pre>
root@debian:~# dig departamentos.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> departamentos.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 46650
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;departamentos.iesgn.org.	IN	A

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: jue dic 10 20:39:41 CET 2020
;; MSG SIZE  rcvd: 52

root@debian:~#
</pre>

Vemos como efectivamente la tenía en caché y por eso el tiempo de respuesta es de **0 msec**.

Hago una consulta a `www.josedomingo.org`, la cual me debería responder ya que en el servidor hemos realizado la configuración adecuada para que pueda utilizar DNS externos en caso de que sea necesario:

<pre>
root@debian:~# dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 44979
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	393	IN	CNAME	playerone.josedomingo.org.
playerone.josedomingo.org. 393	IN	A	137.74.161.90

;; Query time: 47 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: jue dic 10 20:40:20 CET 2020
;; MSG SIZE  rcvd: 88

root@debian:~#
</pre>

Por último, vamos a comprobar la resolución inversa haciendo una consulta a la IP de la dirección `playerone.josedomingo.org` que es la *137.74.161.90*:

<pre>
root@debian:~# dig -x 137.74.161.90

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 137.74.161.90
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19197
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;90.161.74.137.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
90.161.74.137.in-addr.arpa. 43200 IN	PTR	playerone.josedomingo.org.

;; Query time: 82 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: jue dic 10 20:40:58 CET 2020
;; MSG SIZE  rcvd: 94

root@debian:~#
</pre>

Vemos que nos ha respondido de nuevo nuestro servidor DNS, por lo que también podríamos realizar resoluciones inversas.


### Servidor bind9

**Desinstala el servidor *dnsmasq* del ejercicio anterior e instala un servidor DNS *bind9*. Las características del servidor DNS que queremos instalar son las siguientes:**

- **El servidor DNS se llama `pandora.iesgn.org` y por supuesto, va a ser el servidor con autoridad para la zona `iesgn.org`.**

- **Vamos a suponer que tenemos un servidor para recibir los correos que se llame `correo.iesgn.org` y que está en la dirección x.x.x.200 (esto es ficticio).**

- **Vamos a suponer que tenemos un servidor FTP que se llame `ftp.iesgn.org` y que está en x.x.x.201 (esto es ficticio).**

- **Además queremos nombrar a los clientes.**

- **También hay que nombrar a los virtual hosts de apache: `www.iesgn.org` y `departementos.iesgn.org`.**

- **Se tienen que configurar la zona de resolución inversa.**


#### Tarea 2: Realiza la instalación y configuración del servidor *bind9* con las características anteriormente señaladas. Entrega las zonas que has definido. Muestra al profesor su funcionamiento.**

Antes de desinstalar el servidor DNS, vamos a realizar de nuevo una consulta a `www.josedomingo.org` para ver que servidor DNS nos responde ahora:

<pre>
root@debian:~# dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21525
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	900	IN	CNAME	playerone.josedomingo.org.
playerone.josedomingo.org. 548	IN	A	137.74.161.90

;; Query time: 53 msec
;; SERVER: 212.166.132.110#53(212.166.132.110)
;; WHEN: jue dic 10 20:57:53 CET 2020
;; MSG SIZE  rcvd: 88

root@debian:~#
</pre>

Vemos que ahora nos ha respondido un servidor DNS que ha obtenido por DHCP, cuya dirección es *212.166.132.110*, y que ya lógicamente no responde el que habíamos creado nosotros.

Realizada esta comprobación, sí vamos a instalar el servidor **bind9**:

<pre>
apt install bind9 -y
</pre>

Una vez instalado, debemos modificar su fichero de configuración, para ello nos dirigimos a `/etc/bind/named.conf.local` y añadimos el siguiente bloque:

<pre>
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type master;
        file "/var/cache/bind/db.iesgn.org";
};

zone "150.168.192.in-addr.arpa" {
        type master;
        file "/var/cache/bind/db.192.168.150";
};
</pre>

Vamos a explicar las líneas que acabamos de añadir.

En primer lugar, hemos escrito una línea que hacer referencia a un archivo llamado `zones.rfc1918`, que es un fichero de configuración de las zonas privadas que queremos definir.

Los bloques definen la zona `iesgn.org` con su correspondiente **zona inversa**, además vemos como hemos especificado que actúen como **maestro**.

Una vez explicado, vamos a empezar con las modificaciones. En primer lugar, debemos comentar en el fichero `/etc/bind/zones.rfc1918` la siguiente línea:

<pre>
zone "168.192.in-addr.arpa" { type master; file "/etc/bind/db.empty"; };
</pre>

Ahora, vamos a configurar las zonas que definimos en el paso anterior. En mi caso copio el fichero `/etc/bind/db.empty` para utilizarlo como plantilla del nuevo archivo de configuración de esta zona **iesgn.org**.

<pre>
root@DNS:/etc/bind# cp db.empty /var/cache/bind/db.iesgn.org
</pre>

Hecho esto, empezamos a editar nuestro archivo `db.iesgn.org`. Lo primero que debemos hacer en él es definir el servidor con privilegios sobre la zona, en mi caso lo he llamado `javierpzh.iesgn.org`. Lo definimos con un registro de tipo **NS**:

<pre>
$TTL	86400
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.

$ORIGIN iesgn.org.

javierpzh	IN      A       192.168.150.10
</pre>

Voy a explicar el bloque añadido.

El registro **SOA** es la autoridad sobre la zona, en mi caso `javierpzh.iesgn.org`.

El registro **$ORIGIN** se usa para así evitar poner en cada registro que creemos la zona, es decir, a los próximos registros que creemos, se les añadirá automáticamente la zona `iesgn.org`.

El registro de tipo **A** especifica la dirección IP correspondiente al dominio.

Explicado estos detalles, vamos a añadir al fichero `/etc/resolv.conf` de la máquina cliente la siguiente línea con la IP del servidor DNS (si ya la hemos añadido en la tarea 1, no hace falta obviamente):

<pre>
nameserver 192.168.150.10
</pre>

Hecho esto, ahora nuestro cliente utilizará nuestro servidor DNS *bind9*, pero, antes hemos definido un registro **SOA** para definir la autoridad sobre la zona `iesgn.org`, que en teoría debería ser `javierpzh`. ¿Lo comprobamos? Vamos a asegurarnos. Para verificar la autoridad de una zona, hacemos uso del comando `dig ns (zona)`:

<pre>
root@debian:~# dig ns iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> ns iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 593
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: e95232b2d6d4596a85863dd15fd35ba33bc75abdc250ccd0 (good)
;; QUESTION SECTION:
;iesgn.org.			IN	NS

;; ANSWER SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 12:44:35 CET 2020
;; MSG SIZE  rcvd: 106

root@debian:~#
</pre>

Efectivamente, la autoridad sobre esta zona es `javierpzh`.

Vamos a añadir la zona del **servidor de correos** que nos pide, aunque este servidor no exista. Para ello nos dirigimos de nuevo al fichero `/var/cache/bind/db.iesgn.org` y añadiremos un registro **MX**, junto con su correspondiente registro de tipo **A**:

<pre>
$TTL	86400
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.
@	IN	MX	10	scorreos.iesgn.org.


$ORIGIN iesgn.org.

javierpzh	IN      A       192.168.150.10
scorreos	IN	    A	      192.168.150.200
</pre>

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Ahora, haremos una consulta al servidor DNS y preguntaremos por el servidor de correos que hemos especificado, es decir, `scorreos.iesgn.org`:

<pre>
root@debian:~# dig mx iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> mx iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27223
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ec721cf5598d6a9fc228c0005fd38b75a7ed2cc8a2faefe4 (good)
;; QUESTION SECTION:
;iesgn.org.			IN	MX

;; ANSWER SECTION:
iesgn.org.		86400	IN	MX	10 scorreos.iesgn.org.

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
scorreos.iesgn.org.	86400	IN	A	192.168.150.200
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 17:57:31 CET 2020
;; MSG SIZE  rcvd: 147

root@debian:~#
</pre>

Vemos como nos responde con la información de este servidor de correos ficticio.

Es el momento de añadir la zona del **servidor FTP** que nos pide, aunque este servidor no exista. Para ello nos dirigimos de nuevo al fichero `/var/cache/bind/db.iesgn.org` y añadiremos un nuevo registro de tipo **A**:

<pre>
$TTL	86400
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.
@	IN	MX	10	scorreos.iesgn.org.


$ORIGIN iesgn.org.

javierpzh	IN      A       192.168.150.10
scorreos	IN	    A	      192.168.150.200
sftp		  IN	    A	      192.168.150.201
</pre>

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Ahora, haremos una consulta al servidor DNS y preguntaremos por el servidor FTP que hemos especificado, es decir, `sftp.iesgn.org`:

<pre>
root@debian:~# dig sftp.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> sftp.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36434
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 0fabe9ffc844e5d0399b7b345fd38b8ac57e6e1b28ea0bdb (good)
;; QUESTION SECTION:
;sftp.iesgn.org.			IN	A

;; ANSWER SECTION:
sftp.iesgn.org.		86400	IN	A	192.168.150.201

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 17:57:53 CET 2020
;; MSG SIZE  rcvd: 127

root@debian:~#
</pre>

Vemos como nos responde con la información de este servidor FTP ficticio.

Vamos a dar el siguiente paso, que será nombrar a los clientes, en mi caso, la dirección IP del cliente es la 192.168.0.26, ya que estoy utilizando como cliente mi máquina anfitriona. Añado el registro de tipo **A** en `/var/cache/bind/db.iesgn.org`:

<pre>
$TTL	86400
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.
@	IN	MX	10	scorreos.iesgn.org.


$ORIGIN iesgn.org.

javierpzh	IN      A       192.168.150.10
scorreos	IN	    A	      192.168.150.200
sftp		  IN	    A	      192.168.150.201
cliente		IN	    A	      192.168.0.26
</pre>

Ahora, haremos lo mismo, pero esta vez nombraremos a los *virtualhost* que creamos al principio de la práctica. De nuevo en el fichero `/var/cache/bind/db.iesgn.org`:

<pre>
$TTL	86400
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.
@	IN	MX	10	scorreos.iesgn.org.


$ORIGIN iesgn.org.

javierpzh	     IN      A       192.168.150.10
scorreos	     IN	     A	     192.168.150.200
sftp		       IN	     A	     192.168.150.201
cliente		     IN	     A	     192.168.0.26
www		         IN      A	     192.168.150.10
departamentos	 IN    	 A	     192.168.150.10
</pre>

¿Quedaría así no? Ya que los *virtualhost* se encuentran en la misma máquina que el servidor DNS.

Bueno, podríamos dejarlo así, y funcionaría perfectamente, pero no es lo más óptimo/cómodo por decirlo de alguna forma.

Si nos paramos un momento a pensar, anteriormente y como podemos apreciar, ya tenemos un registro tipo **A** que hace referencia a esa dirección IP, por lo que, ¿no os preguntáis si hay alguna forma de reutilizar este registro? Pues sí, obviamente sí. Y aquí entran en acción, los registros de tipo **CNAME**, que sirven para apuntar hacia otro de los registros ya existentes. De manera que es mucho más fácil y cómodo hacer referencia a una dirección a través de un nombre en vez de con la propia dirección en sí.

Utilizando los registros **CNAME** quedaría así:

<pre>
$TTL	86400
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.
@	IN	MX	10	scorreos.iesgn.org.


$ORIGIN iesgn.org.

javierpzh	     IN      A       192.168.150.10
scorreos	     IN	     A	     192.168.150.200
sftp		       IN	     A	     192.168.150.201
cliente		     IN	     A	     192.168.0.26
www		         IN      CNAME	 javierpzh
departamentos	 IN    	 CNAME	 javierpzh
</pre>

Explicado esto, vamos a probar si funciona como debería haciendo una consulta a las direcciones `www.iesgn.org` y `departamentos.iesgn.org`, pero no sin antes reiniciar el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Ahora sí, realizamos las consultas:

<pre>
root@debian:~# dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5478
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: eda2332198272cdf60febed55fd38ba7b6024adf329d5449 (good)
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		86400	IN	CNAME	javierpzh.iesgn.org.
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 17:58:22 CET 2020
;; MSG SIZE  rcvd: 124

------------------------------------------------------------------------

root@debian:~# dig departamentos.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> departamentos.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12032
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 7f93d61aeb4c0efc522158cd5fd38bbbd4312d4adf9d1116 (good)
;; QUESTION SECTION:
;departamentos.iesgn.org.	IN	A

;; ANSWER SECTION:
departamentos.iesgn.org. 86400	IN	CNAME	javierpzh.iesgn.org.
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; AUTHORITY SECTION:
iesgn.org.		86400	IN	NS	javierpzh.iesgn.org.

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 17:58:42 CET 2020
;; MSG SIZE  rcvd: 134
</pre>

Lógicamente como he comentado antes, funciona.

Por último, para terminar esta tarea, vamos a configurar la zona inversa de nuestra servidor DNS *bind9*.

Al igual que hicimos al principio del ejercicio, vamos a tomar como plantilla un archivo, pero esta vez será el `/etc/bind/db.127` y lo guardaremos de nuevo en `/var/cache/bind` con el nombre `db.192.168.150`.

<pre>
cp /etc/bind/db.127 /var/cache/bind/db.192.168.150
</pre>

Antes de mostrar como quedaría este fichero, hay que decir que por cada registro de tipo **A** que tengamos en nuestro archivos que contiene las zonas directas, tenemos que añadir un registro de tipo **PTR**.

En mi caso, el fichero `/var/cache/bind/db.192.168.150` tendría este aspecto:

<pre>
$TTL	604800
@	IN	SOA	javierpzh.iesgn.org. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	javierpzh.iesgn.org.

$ORIGIN 150.168.192.in-addr.arpa.

10	IN	PTR	  javierpzh.iesgn.org.
200	IN	PTR	  scorreos.iesgn.org.
201	IN	PTR	  sftp.iesgn.org
26  IN	PTR	  cliente.iesgn.org
</pre>

Reiniciamos el servidor DNS para que se apliquen los nuevos cambios:

<pre>
systemctl restart bind9
</pre>

Para comprobar que funciona la resolución inversa, vamos a hacer una consulta inversa. Para hacer esto utilizamos el comando `dig -x (IP)`:

<pre>
root@debian:~# dig -x 192.168.150.10

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 192.168.150.10
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 44927
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 3becf8105587fe516606f84b5fd38c12b82f225369f578b9 (good)
;; QUESTION SECTION:
;10.150.168.192.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
10.150.168.192.in-addr.arpa. 604800 IN	PTR	javierpzh.iesgn.org.

;; AUTHORITY SECTION:
150.168.192.in-addr.arpa. 604800 IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 18:00:09 CET 2020
;; MSG SIZE  rcvd: 147

root@debian:~#
</pre>

Parece que el servidor resuelve consultas inversas, pero vamos a hacer una prueba más realizando otra consulta inversa, esta vez al servidor de correos.

<pre>
root@debian:~# dig -x 192.168.150.200

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 192.168.150.200
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29504
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 779a6650f4f0623f495f51185fd38c25ceac5c00a3b27e45 (good)
;; QUESTION SECTION:
;200.150.168.192.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
200.150.168.192.in-addr.arpa. 604800 IN	PTR	scorreos.iesgn.org.

;; AUTHORITY SECTION:
150.168.192.in-addr.arpa. 604800 IN	NS	javierpzh.iesgn.org.

;; ADDITIONAL SECTION:
javierpzh.iesgn.org.	86400	IN	A	192.168.150.10

;; Query time: 0 msec
;; SERVER: 192.168.150.10#53(192.168.150.10)
;; WHEN: vie dic 11 18:00:27 CET 2020
;; MSG SIZE  rcvd: 157

root@debian:~#
</pre>

Vemos que también funciona correctamente, por lo que este ejercicio estaría terminado.


#### Tarea 3: Realiza las consultas dig/nslookup desde los clientes preguntando por los siguientes:**

- **Dirección de pandora.iesgn.org, www.iesgn.org, `ftp.iesgn.org`.**

- **El servidor DNS con autoridad sobre la zona del dominio `iesgn.org`.**

- **El servidor de correo configurado para `iesgn.org`.**

- **La dirección IP de `www.josedomingo.org`**.

- **Una resolución inversa**


### Servidor DNS esclavo

##### El servidor DNS actual funciona como **DNS maestro**. Vamos a instalar un nuevo servidor DNS que va a estar configurado como **DNS esclavo** del anterior, donde se van a ir copiando periódicamente las zonas del DNS maestro. Suponemos que el nombre del servidor DNS esclavo se va llamar `afrodita.iesgn.org`.

#### Tarea 4: Realiza la instalación del servidor DNS esclavo. Documenta los siguientes apartados:**

- **Entrega la configuración de las zonas del maestro y del esclavo.**

- **Comprueba si las zonas definidas en el maestro tienen algún error con el comando adecuado.**

- **Comprueba si la configuración de `named.conf` tiene algún error con el comando adecuado.**

- **Reinicia los servidores y comprueba en los *logs* si hay algún error. No olvides incrementar el número de serie en el registro SOA si has modificado la zona en el maestro.**

- **Muestra la salida del log donde se demuestra que se ha realizado la transferencia de zona.**


#### Tarea 5: Documenta los siguientes apartados:**

- **Configura un cliente para que utilice los dos servidores como servidores DNS.**

- **Realiza una consulta con `dig` tanto al maestro como al esclavo para comprobar que las respuestas son autorizadas. ¿En qué te tienes que fijar?**

- **Solicita una copia completa de la zona desde el cliente ¿qué tiene que ocurrir?. Solicita una copia completa desde el esclavo ¿qué tiene que ocurrir?**


#### Tarea 6: Muestra al profesor el funcionamiento del DNS esclavo:**

- **Realiza una consulta desde el cliente y comprueba que servidor está respondiendo.**

- **Posteriormente apaga el servidor maestro y vuelve a realizar una consulta desde el cliente ¿quién responde?**


### Delegación de dominios

Tenemos un servidor DNS que gestiona la zona correspondiente al nombre de dominio `iesgn.org`, en esta ocasión queremos delegar el subdominio `informatica.iesgn.org` para que lo gestione otro servidor DNS. Por lo tanto tenemos un escenario con dos servidores DNS:

- `pandora.iesgn.org`, es servidor DNS autorizado para la zona `iesgn.org`.

- `ns.informatica.iesgn.org`, es el servidor DNS para la zona `informatica.iesgn.org` y, está instalado en otra máquina.

Los nombres que vamos a tener en ese subdominio son los siguientes:

- `www.informatica.iesgn.org` corresponde a un sitio web que está alojado en el servidor web del departamento de informática.

- Vamos a suponer que tenemos un servidor FTP que se llame `ftp.informatica.iesgn.org` y que está en la misma máquina.

- Vamos a suponer que tenemos un servidor para recibir los correos que se llame `correo.informatica.iesgn.org`.

#### Tarea 7: Realiza la instalación y configuración del nuevo servidor DNS con las características anteriormente señaladas. Muestra el resultado al profesor.**




#### Tarea 8: Realiza las consultas dig/neslookup desde los clientes preguntando por los siguientes:**

- **Dirección de `www.informatica.iesgn.org`, `ftp.informatica.iesgn.org`.**

- **El servidor DNS que tiene configurado la zona del dominio `informatica.iesgn.org`. ¿Es el mismo que el servidor DNS con autoridad para la zona `iesgn.org`?**

- **El servidor de correo configurado para `informatica.iesgn.org`.**
