Title: LDAPs
Date: 2020/12/09
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: LDAP, OpenStack

#### Configura el servidor LDAP de Freston para que utilice el protocolo ldaps:// a la vez que el ldap:// utilizando el certificado x509 de la práctica de HTTPS o solicitando el correspondiente a través de gestiona. Realiza las modificaciones adecuadas en el cliente LDAP de Freston para que todas las consultas se realicen por defecto utilizando ldaps://

Si quieres saber como instalar un servidor **LDAP**, puedes consultar [este post](https://javierpzh.github.io/instalacion-y-configuracion-inicial-de-openldap.html).

Si queremos configurar **Freston** para que utilice el protocolo `ldaps://` y que así la información viaje cifrada y de manera segura, lo primero que debemos hacer es solicitar el certificado **wildcard**.

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

Como **freston** es una instancia del *cloud*, voy a pasarme este fichero `wildcard.csr` a mi máquina anfitriona para enviárselo a la entidad certificadora, que en este caso es el **Gonzalo Nazareno**.
Si quieres entender mejor la estructura del escenario donde estamos trabajando puedes echarle un vistazo a este *post*, [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html).

Por tanto, pasaré este archivo a mi equipo mediante `scp`.

Una vez tenemos el certificado firmado por la entidad certificadora, lo pasamos a **freston**. También hemos tenido que descargar el certificado de la entidad *Gonzalo Nazareno*. Por tanto lo vamos a mover también a *freston*.

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

Ya tenemos todos los certificados almacenados correctamente y con los usuarios/grupos/permisos adecuados.

Es la primera vez que estoy utilizando *LDAP*, y me ha sorprendido mucho la manera en la que se realiza su configuración, ya que no vamos a llevar a cabo las modificaciones en unos ficheros de configuración como es lo habitual, sino que vamos a crear un fichero `.ldif`, como los que creamos para introducir objetos. Esto se debe a que, de esta manera, podremos manipular la configuración sin tener que reiniciar el servicio, por tanto, nunca dejaría de funcionar.

Creamos el fichero `.ldif` e introducimos las siguientes líneas:

<pre>
dn: cn=config

changetype: modify

replace: olcTLSCACertificateFile olcTLSCACertificateFile: /etc/ssl/certs/gonzalonazareno.crt

replace: olcTLSCertificateKeyFile olcTLSCertificateKeyFile: /etc/ssl/private/freston.key

replace: olcTLSCertificateFile olcTLSCertificateFile: /etc/ssl/certs/wildcard.crt
</pre>

Una vez creado, vamos a hacer uso del siguiente comando para aplicar los cambios y modificar la configuración:

<pre>
root@freston:~# ldapmodify -Y EXTERNAL -H ldapi:/// -f configuracion.ldif

SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"
</pre>

Vale, una vez hemos importado el fichero *.ldif* destinado a la configuración, nos quedaría hacer una modificación en el fichero `/etc/default/slapd`, ya que por defecto, el protocolo `ldaps://` no viene habilitado. Para habilitarlo, debemos buscar la línea **SLAPD_SERVICES** y añadir el valor **ldaps://**, de manera que quedaría así:

<pre>
SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"
</pre>

Reiniciamos el servidor **LDAP** para aplicar los cambios:

<pre>
systemctl restart slapd.service
</pre>

Es hora de pasar a la parte del **cliente**. En mi caso será en la misma máquina pero haré la configuración que debería hacerse en una situación más normal, en la que el cliente se encuentre en otro equipo.

El certificado que hemos almacenado en la ruta `/etc/ssl/certs/` para el servidor, en el lado del cliente, no debería almacenarse ahí, sino que sería más recomendable hacerlo en la ruta `/usr/local/share/ca-certificates/`. Este directorio está creado para almacenar en él los certificados que creemos nosotros de manera local. Por tanto voy a copiar el archivo `gonzalonazareno.crt` a esta ruta:

<pre>
cp /etc/ssl/certs/gonzalonazareno.crt /usr/local/share/ca-certificates/
</pre>

Una vez lo hemos copiado, haremos uso del siguiente comando. Lo que haremos con este comando, será crear un enlace simbólico a la ruta `/etc/ssl/certs/` y con esto crearemos la nueva entrada necesaria para que el cliente haga uso de **ldaps://** confiando en la autoridad certificadora.

<pre>
update-ca-certificates
</pre>

Por último, debemos realizar una modificación en el fichero de configuración `/etc/ldap/ldap.conf`. Hay que descomentar el apartado llamado **URI**. Quedaría así:

<pre>
URI     ldaps://localhost
</pre>

Esto hará, que el cliente utilice de manera predeterminada el protocolo **ldaps://**.



<pre>

</pre>

















.
