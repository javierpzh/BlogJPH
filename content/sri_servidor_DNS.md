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

**Instala el servidor DNS *dnsmasq* en `pandora.iesgn.org` y configúralo para que los clientes puedan conocer los nombres necesarios.**

He creado una instancia en el *cloud* de **OpenStack** que será la máquina que actuará como **servidor**, posee una dirección IP **172.22.200.174**.

Las dos páginas servidas por *Apache2* las he creado pero voy a omitir su explicación, pues ya tengo otras entradas en las que hablo expresamente de esto. Te dejo este enlace por si quieres saber algo más de [Apache2](https://javierpzh.github.io/tag/apache.html).

**Importante:** como estamos trabajando en el *cloud*, he tenido que abrir el puerto **53/UDP**, ya que es el puerto que se utiliza para recibir las peticiones de parte de los clientes.

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
nameserver 172.22.200.174
</pre>

Añadimos la línea `nameserver 172.22.200.174`, cuya dirección corresponde a la IP de la máquina servidor.

Hecho esto, podemos realizar una consulta a `www.iesgn.org`:

<pre>
javier@debian:~$ dig www.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30160
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		0	IN	A	172.22.200.174

;; Query time: 97 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:56:32 CET 2020
;; MSG SIZE  rcvd: 58
</pre>

Vemos como nos está respondiendo nuestro servidor DNS, ya que nos indica que la respuesta viene de la IP **172.22.200.174**.

Realizo una consulta a `departamentos.iesgn.org`:

<pre>
javier@debian:~$ dig departamentos.iesgn.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> departamentos.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32409
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;departamentos.iesgn.org.	IN	A

;; ANSWER SECTION:
departamentos.iesgn.org. 0	IN	A	172.22.200.174

;; Query time: 242 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:57:36 CET 2020
;; MSG SIZE  rcvd: 68
</pre>

Vemos como de nuevo nos está respondiendo nuestro servidor DNS.

Hago una consulta a `www.josedomingo.org`, la cual me debería responder ya que en el servidor hemos realizado la configuración adecuada para que pueda utilizar DNS externos en caso de que sea necesario:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18210
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 5, ADDITIONAL: 6

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: cd4b754d056f0763b14e40b65fd8b2fa0fe587d46fbb0cd0 (good)
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	900	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	365	IN	A	37.187.119.60

;; AUTHORITY SECTION:
josedomingo.org.	82635	IN	NS	ns1.cdmon.net.
josedomingo.org.	82635	IN	NS	ns5.cdmondns-01.com.
josedomingo.org.	82635	IN	NS	ns4.cdmondns-01.org.
josedomingo.org.	82635	IN	NS	ns2.cdmon.net.
josedomingo.org.	82635	IN	NS	ns3.cdmon.net.

;; ADDITIONAL SECTION:
ns1.cdmon.net.		160610	IN	A	35.189.106.232
ns2.cdmon.net.		160610	IN	A	35.195.57.29
ns3.cdmon.net.		160610	IN	A	35.157.47.125
ns4.cdmondns-01.org.	82635	IN	A	52.58.66.183
ns5.cdmondns-01.com.	160610	IN	A	52.59.146.62

;; Query time: 700 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:58:34 CET 2020
;; MSG SIZE  rcvd: 318
</pre>

Vemos que el tiempo de respuesta ha sido de **700 msec**, algo bastante elevado, aunque supongo que es porque estoy trabajando desde casa a través de la VPN.

Vamos a realizar de nuevo una consulta a `www.josedomingo.org`, la cual me debería responder más rápida que la anterior ya que este servidor funciona como **caché DNS**:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64502
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	846	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	311	IN	A	37.187.119.60

;; Query time: 81 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 13:59:27 CET 2020
;; MSG SIZE  rcvd: 99
</pre>

Vemos que esta vez el tiempo de respuesta ha sido de **81 msec**, muchísimo más reducido que la primera vez, lo que demuestra que este servidor funciona como *caché DNS*. Además, vuelvo a decir que estoy en casa, si estuviera en clase, seguramente el tiempo de respuesta hubiera sido de unos pocos *msec*.

Por último, vamos a comprobar la resolución inversa haciendo una consulta a la IP de la dirección `endor.josedomingo.org` que es la *37.187.119.60*:

<pre>
javier@debian:~$ dig -x 37.187.119.60

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> -x 37.187.119.60
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60847
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ab7414b8c67b8dae299df1475fd8b528f0540c2f00c10f05 (good)
;; QUESTION SECTION:
;60.119.187.37.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
60.119.187.37.in-addr.arpa. 86370 IN	PTR	ns330309.ip-37-187-119.eu.

;; AUTHORITY SECTION:
119.187.37.in-addr.arpa. 172763	IN	NS	ns104.ovh.net.
119.187.37.in-addr.arpa. 172763	IN	NS	dns104.ovh.net.

;; Query time: 230 msec
;; SERVER: 172.22.200.174#53(172.22.200.174)
;; WHEN: mar dic 15 14:07:52 CET 2020
;; MSG SIZE  rcvd: 170
</pre>

Vemos que nos ha respondido de nuevo nuestro servidor DNS, por lo que también podríamos realizar resoluciones inversas.


### Servidor bind9

**Desinstala el servidor *dnsmasq* del ejercicio anterior e instala un servidor DNS *bind9*. Las características del servidor DNS que queremos instalar son las siguientes:**

- **El servidor DNS se llama `pandora.iesgn.org` y por supuesto, va a ser el servidor con autoridad para la zona `iesgn.org`.**

- **Vamos a suponer que tenemos un servidor para recibir los correos que se llame `correo.iesgn.org` y que está en la dirección x.x.x.200 (esto es ficticio).**

- **Vamos a suponer que tenemos un servidor FTP que se llame `ftp.iesgn.org` y que está en x.x.x.201 (esto es ficticio).**

- **Además queremos nombrar a los clientes.**

- **También hay que nombrar a los *virtualhosts* de apache: `www.iesgn.org` y `departementos.iesgn.org`.**

- **Se tienen que configurar la zona de resolución inversa.**


#### Tarea 2: Realiza la instalación y configuración del servidor *bind9* con las características anteriormente señaladas. Entrega las zonas que has definido. Muestra al profesor su funcionamiento.**

Una vez hemos desinstalado el servidor **dnsmasq**, antes de instalar el servidor DNS **bind9**, vamos a realizar de nuevo una consulta a `www.josedomingo.org` para ver que servidor DNS nos responde ahora:

<pre>
javier@debian:~$ dig www.josedomingo.org

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54806
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	900	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	900	IN	A	37.187.119.60

;; Query time: 76 msec
;; SERVER: 212.166.132.110#53(212.166.132.110)
;; WHEN: mar dic 15 14:13:01 CET 2020
;; MSG SIZE  rcvd: 84
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

zone "200.22.172.in-addr.arpa" {
        type master;
        file "/var/cache/bind/db.200.22.172";
};
</pre>

Vamos a explicar las líneas que acabamos de añadir.

En primer lugar, hemos escrito una línea que hacer referencia a un archivo llamado `zones.rfc1918`, que es un fichero de configuración de las zonas privadas que queremos definir.

Los bloques definen las zonas de las que el servidor tiene autoridad, la **zona de resolución directa** `iesgn.org` con su correspondiente **zona de resolución inversa** `200.22.172.in-addr.arpa`, además vemos como hemos especificado que actúen como **maestro**.

Una vez explicado, tenemos que dirigirnos al fichero `/etc/bind/named.conf.options`, y aquí debemos introducir las siguientes líneas:

<pre>
recursion yes;
allow-recursion { any; };
listen-on { any; };
allow-transfer { none; };
</pre>

De manera, que el fichero `/etc/bind/named.conf.options` quedaría así:

<pre>
options {
        directory "/var/cache/bind";

        dnssec-validation auto;

        listen-on-v6 { any; };

        recursion yes;

        allow-recursion { any; };

        listen-on { any; };

        allow-transfer { none; };

};
</pre>

Ahora, vamos a configurar las zonas que definimos en el paso anterior. En mi caso copio el fichero `/etc/bind/db.empty` para utilizarlo como plantilla del nuevo archivo de configuración de esta **zona de resolución directa** `iesgn.org`.

<pre>
root@javierpzh:~# cp /etc/bind/db.empty /var/cache/bind/db.iesgn.org
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
