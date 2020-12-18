Title: LDAPs
Date: 2020/12/17
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: LDAP, OpenStack

#### Configura el servidor LDAP de Freston para que utilice el protocolo ldaps:// a la vez que el ldap:// utilizando el certificado x509 de la práctica de HTTPS o solicitando el correspondiente a través de gestiona. Realiza las modificaciones adecuadas en el cliente LDAP de Freston para que todas las consultas se realicen por defecto utilizando ldaps://

Lo primero que debemos hacer es solicitar el certificado **wildcard**.

Para crear este certificado, vamos a crear una clave privada de **4096 bits**, para ello vamos a utilizar `openssl`. Vamos a guardar esta clave en el directorio `/etc/ssl/private/`. Para crear esta clave privada empleamos el siguiente comando:

<pre>
root@freston:~# openssl genrsa 4096 > /etc/ssl/private/freston.key
Generating RSA private key, 4096 bit long modulus (2 primes)
.........................................++++
...........................................................................................................................++++
e is 65537 (0x010001)

root@freston:~# ls /etc/ssl/private/
freston.key
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

Una vez los tenemos aquí, los vamos a mover a la ruta `/etc/ssl/certs`:

<pre>
root@freston:~# mv gonzalonazareno.crt /etc/ssl/certs/

root@freston:~# mv wildcard.crt /etc/ssl/certs/
</pre>



















Reiniciamos el servidor **LDAP** para aplicar los cambios:

<pre>
systemctl restart slapd.service
</pre>



















.
