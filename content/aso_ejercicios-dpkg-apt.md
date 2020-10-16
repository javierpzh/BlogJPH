Title: Ejercicios de dpkg/APT
Date: 2020/10/05
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-seguridad.jpg

En primer lugar prepara una máquina virtual con Debian buster, puedes hacerlo de la forma que prefieras o usando el fichero Vagrantfile que se proporciona.

La versión de debian buster a fecha de hoy, es la versión 10.6. Sobre una máquina de versión anterior realizar las siguientes acciones:

## Trabajo con apt, aptitude, dpkg

**1. Que acciones consigo al realizar apt update y apt upgrade. Explica detalladamente.**

Al realizar un `apt update` lo que se hace es actualizar los paquetes de los repositorios que tenemos guardados en nuestro archivo `sources.list`, por eso es recomendable realizar este comando cada vez que vayamos a instalar un nuevo paquete, y al realizar un `apt upgrade` estamos comprobando si existen actualizaciones de los paquetes que ya tenemos instalados en nuestra máquina, y si hay nuevas versiones, se actualizan.

**2. Lista la relación de paquetes que pueden ser actualizados. ¿Qué información puedes sacar a tenor de lo mostrado en el listado?**

Para listar todos los paquetes que disponen de versiones superiores a la instalada, podemos realizar un `apt list --upgradable` y nos saldrán todos los paquetes que no están en su versión más reciente.

**3. Indica la versión instalada, candidata así como la prioridad del paquete openssh-client.**

Para ver esta información yo utilizo el comando `apt policy openssh-client`.
La versión instalada y la candidata es la misma, 1:7.9p1-10+deb10u2. Tiene una prioridad 500 (standard).

**4. ¿Cómo puedes sacar información de un paquete oficial instalado o que no este instalado?**

Con el comando `apt policy (nombrepaquete)`.

**5. Saca toda la información que puedas del paquete openssh-client que tienes actualmente instalado en tu máquina.**

<pre>
root@buster:~# apt show openssh-client
Package: openssh-client
Version: 1:7.9p1-10+deb10u2
Priority: standard
Section: net
Source: openssh
Maintainer: Debian OpenSSH Maintainers <debian-ssh@lists.debian.org>
Installed-Size: 3,631 kB
Provides: rsh-client, ssh-client
Depends: adduser (>= 3.10), dpkg (>= 1.7.0), passwd, libc6 (>= 2.26), libedit2 (>= 2.11-20080614-0),  libgssapi-krb5-2 (>= 1.17), libselinux1 (>= 1.32), libssl1.1 (>= 1.1.1), zlib1g (>= 1:1.1.4)
Recommends: xauth
Suggests: keychain, libpam-ssh, monkeysphere, ssh-askpass
Conflicts: sftp
Replaces: ssh, ssh-krb5
Homepage: http://www.openssh.com/
Tag: implemented-in::c, interface::commandline, interface::shell,
network::client, protocol::sftp, protocol::ssh, role::program,
security::authentication, security::cryptography, uitoolkit::ncurses,
use::login, use::transmission, works-with::file
Download-Size: 782 kB
APT-Manual-Installed: yes
APT-Sources: http://deb.debian.org/debian buster/main amd64 Packages
Description: secure shell (SSH) client, for secure access to remote machines

N: There is 1 additional record. Please use the '-a' switch to see it
root@buster:~#
</pre>

**6. Saca toda la información que puedas del paquete openssh-client candidato a actualizar en tu máquina.**

<pre>
apt show -a openssh-client
</pre>

**7. Lista todo el contenido referente al paquete openssh-client actual de tu máquina. Utiliza para ello tanto dpkg como apt.**

Con apt:

<pre>
apt-file update
apt-file list openssh-client
</pre>

Con dpkg:

<pre>
dpkg -L openssh-client
</pre>

**8. Listar el contenido de un paquete sin la necesidad de instalarlo o descargarlo.**

Para ver el contenido de un paquete podemos emplear la utilidad `apt-file`, que no viene instalada por defecto en Debian, lo podemos instalar con `apt install apt-file`.
Y ahora para buscar el contenido, la sintáxis sería: `apt-file list (nombrepaquete)`.

**9. Simula la instalación del paquete openssh-client.**

Para simular la instalación de un paquete, por ejemplo de 'apache2', utilizamos el siguiente comando:

<pre>
root@buster:~# apt -s install apache2
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
apache2-bin apache2-data apache2-utils libapr1 libaprutil1 libaprutil1-dbd-sqlite3
libaprutil1-ldap libbrotli1 libcurl4 libjansson4 liblua5.2-0 ssl-cert
Suggested packages:
apache2-doc apache2-suexec-pristine | apache2-suexec-custom www-browser openssl-blacklist
The following NEW packages will be installed:
apache2 apache2-bin apache2-data apache2-utils libapr1 libaprutil1 libaprutil1-dbd-sqlite3
libaprutil1-ldap libbrotli1 libcurl4 libjansson4 liblua5.2-0 ssl-cert
0 upgraded, 13 newly installed, 0 to remove and 0 not upgraded.
Inst libapr1 (1.6.5-1+b1 Debian:10.6/stable [amd64])
Inst libaprutil1 (1.6.1-4 Debian:10.6/stable [amd64])
Inst libaprutil1-dbd-sqlite3 (1.6.1-4 Debian:10.6/stable [amd64])
Inst libaprutil1-ldap (1.6.1-4 Debian:10.6/stable [amd64])
Inst libbrotli1 (1.0.7-2 Debian:10.6/stable [amd64])
Inst libcurl4 (7.64.0-4+deb10u1 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Inst libjansson4 (2.12-1 Debian:10.6/stable [amd64])
Inst liblua5.2-0 (5.2.4-1.1+b2 Debian:10.6/stable [amd64])
Inst apache2-bin (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Inst apache2-data (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [all])
Inst apache2-utils (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Inst apache2 (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Inst ssl-cert (1.0.39 Debian:10.6/stable [all])
Conf libapr1 (1.6.5-1+b1 Debian:10.6/stable [amd64])
Conf libaprutil1 (1.6.1-4 Debian:10.6/stable [amd64])
Conf libaprutil1-dbd-sqlite3 (1.6.1-4 Debian:10.6/stable [amd64])
Conf libaprutil1-ldap (1.6.1-4 Debian:10.6/stable [amd64])
Conf libbrotli1 (1.0.7-2 Debian:10.6/stable [amd64])
Conf libcurl4 (7.64.0-4+deb10u1 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Conf libjansson4 (2.12-1 Debian:10.6/stable [amd64])
Conf liblua5.2-0 (5.2.4-1.1+b2 Debian:10.6/stable [amd64])
Conf apache2-bin (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Conf apache2-data (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [all])
Conf apache2-utils (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Conf apache2 (2.4.38-3+deb10u4 Debian:10.6/stable, Debian-Security:10/stable [amd64])
Conf ssl-cert (1.0.39 Debian:10.6/stable [all])
root@buster:~# apt policy apache2
apache2:
  Installed: (none)
  Candidate: 2.4.38-3+deb10u4
  Version table:
    2.4.38-3+deb10u4 500
      500 http://deb.debian.org/debian buster/main amd64 Packages
      500 http://security.debian.org/debian-security buster/updates/main amd64 Packages
root@buster:~#
</pre>

Vemos que parece que ha instalado el paquete, pero en realidad no lo hace. Si os fijáis, si después lo comprobamos, no está instalado.

**10. ¿Qué comando te informa de los posibles bugs que presente un determinado paquete?**

<pre>
apt-listbugs list (nombrepaquete) -s all
</pre>

**11. Después de realizar un apt update && apt upgrade. Si quisieras actualizar únicamente los paquetes que tienen de cadena openssh. ¿Qué procedimiento seguirías? Realiza esta acción, con las estructuras repetitivas que te ofrece bash, así como con el comando xargs.**

Para ver las actualizaciones de un paquete específico:

<pre>
apt list --upgradable | grep (nombrepaquete)
</pre>

**12. ¿Cómo encontrarías qué paquetes dependen de un paquete específico?**

<pre>
apt depends (nombrepaquete)
</pre>

**13. Como procederías para encontrar el paquete al que pertenece un determinado archivo.**

Lo podemos encontrar con la utilidad `apt-file` que hemos instalado anteriormente. La sintáxis sería: `apt-file search (rutadelarchivo)`.

**14. ¿Que procedimientos emplearías para eliminar y liberar la cache en cuanto a descargas de paquetería?**

Debian dispone de comandos que nos permiten limpiar la caché de los paquetes que descargamos:

<pre>
apt autoclean
</pre>

También nos permite desinstalar los paquetes/dependencias que detecta que ya no son necesarios:

<pre>
apt autoremove
</pre>

**15. Realiza la instalación del servidor de bases de datos MariaDB pasando previamente los valores de los parámetros de configuración como variables de entorno.**



**16. Reconfigura el paquete locales de tu equipo, añadiendo una localización que no exista previamente. Comprueba a modificar las variables de entorno correspondientes para que la sesión del usuario utilice otra localización.**



**17. Interrumpe la configuración de un paquete y explica los pasos a dar para continuar la instalación.**



**18. Explica la instrucción que utilizarías para hacer una actualización completa de todos los paquetes de tu sistema de manera completamente no interactiva.**



**19. Bloquea la actualización de determinados paquetes.**




## Trabajo con ficheros .deb

**1. Descarga un paquete sin instalarlo, es decir, descarga el fichero .deb correspondiente. Indica diferentes formas de hacerlo.**



**2. ¿Cómo puedes ver el contenido, que no extraerlo, de lo que se instalará en el sistema de un paquete deb?**



**3. Sobre el fichero .deb descargado, utiliza el comando ar. ar permite extraer el contenido de una paquete deb. Indica el procedimiento para visualizar con ar el contenido del paquete deb. Con el paquete que has descargado y utilizando el comando ar, descomprime el paquete. ¿Qué información dispones después de la extracción?. Indica la finalidad de lo extraído.**



**4. Indica el procedimiento para descomprimir lo extraído por ar del punto anterior. ¿Qué información contiene?**




## Trabajo con repositorios

**1. Añade a tu fichero sources.list los repositorios de backports y sid.**



**2. ¿Cómo añades la posibilidad de descargar paquetería de la arquitectura i386 en tu sistema. ¿Que comando has empleado?. Lista arquitecturas no nativas. ¿Cómo procederías para desechar la posibilidad de descargar paquetería de la arquitectura i386?**



**3. Si quisieras descargar un paquete, ¿cómo puedes saber todas las versiones disponible de dicho paquete?**



**4. Indica el procedimiento para descargar un paquete del repositorio stable.**



**5. Indica el procedimiento para descargar un paquete del repositorio de backports.**



**6. Indica el procedimiento para descargar un paquete del repositorio de sid.**



**7. Indica el procedimiento para descargar un paquete de arquitectura i386.**




## Trabajo con directorios

**1. Que cometidos tienen:**

**/var/lib/apt/lists/**

**/var/lib/dpkg/available**

**/var/lib/dpkg/status**

**/var/cache/apt/archives/**
