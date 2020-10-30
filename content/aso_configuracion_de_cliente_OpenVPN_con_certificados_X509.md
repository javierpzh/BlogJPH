Title: Configuración de cliente OpenVPN con certificados X.509
Date: 2020/10/30
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: OpenVPN, VPN

## Configuración de cliente OpenVPN con certificados X.509

### Descripción

**Para poder acceder a la red local desde el exterior, existe una red privada configurada con OpenVPN que utiliza certificados x509 para autenticar los usuarios y el servidor.**

- **Genera una clave privada RSA 4096**
- **Genera una solicitud de firma de certificado (fichero CSR) y súbelo a gestiona**
- **Descarga el certificado firmado cuando esté disponible**
- **Instala y configura apropiadamente el cliente openvpn y muestra los registros (logs) del sistema que demuestren que se ha establecido una conexión.**
- **Cuando hayas establecido la conexión VPN tendrás acceso a la red 172.22.0.0/16 a través de un túnel SSL. Compruébalo haciendo ping a 172.22.0.1**


<pre>
root@debian:~# openssl genrsa 4096 > /etc/ssl/private/msi-debian-javierperezhidalgo.key
Generating RSA private key, 4096 bit long modulus (2 primes)
................................................................................++++
.................++++
e is 65537 (0x010001)

root@debian:~# openssl req -new -key /etc/ssl/private/msi-debian-javierperezhidalgo.key -out /root/msi-debian-javierperezhidalgo.csr
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
Common Name (e.g. server FQDN or YOUR name) []:msi-debian-javierperezhidalgo
Email Address []:javierperezhidalgo01@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

root@debian:~# ls
msi-debian-javierperezhidalgo.csr

root@debian:~# cp msi-debian-javierperezhidalgo.csr ../
bin/            home/           lib64/          proc/           sys/            vmlinuz.old
boot/           initrd.img      libx32/         root/           tmp/            
.cache/         initrd.img.old  media/          run/            usr/            
dev/            lib/            mnt/            sbin/           var/            
etc/            lib32/          opt/            srv/            vmlinuz         

root@debian:~# mv msi-debian-javierperezhidalgo.csr ../home/javier/

root@debian:~# mv ../home/javier/msi-debian-javierperezhidalgo.csr ./

root@debian:~# ls
msi-debian-javierperezhidalgo.csr

root@debian:~# mv ../home/javier/Descargas/msi-debian-javierperezhidalgo.crt ./

root@debian:~# ls
msi-debian-javierperezhidalgo.crt  msi-debian-javierperezhidalgo.csr

root@debian:~# mv msi-debian-javierperezhidalgo.crt /etc/openvpn/

root@debian:~# mv msi-debian-javierperezhidalgo.csr /etc/ssl/certs/


</pre>
