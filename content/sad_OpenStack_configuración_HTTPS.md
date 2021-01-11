Title: OpenStack: Configuración HTTPS
Date: 2021/01/11
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-seguridad.jpg
Tags: OpenStack, HTTPS

**En este *post* vamos a configurar de forma adecuada el protocolo HTTPS en nuestro servidor web para nuestra aplicaciones web. Para ello vamos a emitir un certificado *wildcard* en la entidad certificadora Gonzalo Nazareno.**

- **Explica los pasos fundamentales para la creación del certificado. Especificando los campos que has rellenado en el fichero CSR.**

Lo primero que debemos hacer es solicitar el certificado **wildcard**.

(Este certificado ya lo creé anteriormente para el uso del protocolo *LDAPs*, puedes ver el *post* [aquí](https://javierpzh.github.io/ldaps.html) y por ello el proceso lo llevo a cabo en la máquina *Freston*. La clave privada la he copiado a la máquina *Quijote*)

Para crear este certificado, vamos a crear una clave privada de **4096 bits**, para ello vamos a utilizar `openssl`. Vamos a guardar esta clave en el directorio `/etc/ssl/private/`. Para crear esta clave privada empleamos el siguiente comando:

<pre>
root@freston:~# openssl genrsa 4096 > /etc/ssl/private/freston.key
Generating RSA private key, 4096 bit long modulus (2 primes)
.........................................++++
...........................................................................................................................++++
e is 65537 (0x010001)
</pre>

Debemos cambiarle los permisos a la clave privada a **400**, así únicamente el propietario podrá leer el contenido. Para ello, haremos uso de la herramienta `chmod`:

<pre>
root@freston:/etc/ssl/private# ls -l
total 4
-rw-r--r-- 1 root root 3243 Dec 18 08:59 freston.key

root@freston:/etc/ssl/private# chmod 400 /etc/ssl/private/freston.key

root@freston:/etc/ssl/private# ls -l
total 4
-r-------- 1 root root 3243 Dec 18 08:59 freston.key
</pre>

Pero claro, también hay que pensar que el usuario de **LDAP** debe poder leer esta clave, así que, para ello, he decidido crear una **ACL** para que únicamente este usuario, llamado **openldap** tenga acceso a la clave privada. Para ello instalamos el paquete `acl`:

<pre>
apt install acl -y
</pre>

Y creamos la *ACL* adecuada:

<pre>
root@freston:# setfacl -m u:openldap:r-x /etc/ssl/private/

root@freston:# setfacl -m u:openldap:r-x /etc/ssl/private/freston.key
</pre>

Lo siguiente sería generar una solicitud de firma de certificado, es decir, un fichero **.csr**, que posteriormente enviaremos a la entidad del [Gonzalo Nazareno](https://blogsaverroes.juntadeandalucia.es/iesgonzalonazareno/) para que nos lo firmen.

Para generar nuestro archivo *.csr*:

<pre>
root@freston:~# openssl req -new -key /etc/ssl/private/freston.key -out /root/wildcard.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:ES
State or Province Name (full name) [Some-State]:Sevilla
Locality Name (eg, city) []:Dos Hermanas
Organization Name (eg, company) [Internet Widgits Pty Ltd]:IES Gonzalo Nazareno
Organizational Unit Name (eg, section) []:Informatica
Common Name (e.g. server FQDN or YOUR name) []:*.javierpzh.gonzalonazareno.org
Email Address []:javierperezhidalgo01@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

root@freston:~# ls
wildcard.csr
</pre>

Como **Freston** es una instancia del *cloud*, voy a pasarme este fichero `wildcard.csr` a mi máquina anfitriona para enviárselo a la entidad certificadora, que en este caso es el **Gonzalo Nazareno**.
Si quieres entender mejor la estructura del escenario donde estamos trabajando puedes echarle un vistazo a este *post*, [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html).

Por tanto, pasaré este archivo a mi equipo mediante `scp`.

Una vez tenemos el certificado firmado por la entidad certificadora, lo pasamos a *Freston*. También hemos tenido que descargar el certificado de la entidad *Gonzalo Nazareno*. Por tanto lo vamos a mover también a *Freston*.

<pre>
root@freston:~# ls
gonzalonazareno.crt  wildcard.crt  wildcard.csr
</pre>

Lógicamente, estos certificados no debemos dejarlos en esta directorio, por lo que, los vamos a mover a la ruta `/etc/ssl/certs`:

<pre>
root@freston:~# mv gonzalonazareno.crt /etc/ssl/certs/

root@freston:~# mv wildcard.crt /etc/ssl/certs/
</pre>

Es importante que ambos archivos, posean a **root** como usuario y grupo propietario, por tanto le cambio el propietario y el grupo:

<pre>
root@freston:/etc/ssl/certs# chown -R root:root wildcard.crt

root@freston:/etc/ssl/certs# chown -R root:root gonzalonazareno.crt
</pre>

Aquí podemos ver el resultado:

<pre>
root@freston:~# ls -l /etc/ssl/certs/ | grep gonzalo
-rw-r--r-- 1 root root   3634 Dec 18 09:34 gonzalonazareno.crt

root@freston:~# ls -l /etc/ssl/certs/ | grep wildcard
-rw-r--r-- 1 root root  10119 Dec 18 09:29 wildcard.crt
</pre>

- **Debes hacer una redirección para forzar el protocolo HTTPSs.**



- **Investiga la regla DNAT en el cortafuego para abrir el puerto 443.**



- **Instala el certificado del Gonzalo Nazareno en tu navegador para que se pueda verificar tu certificado.**
