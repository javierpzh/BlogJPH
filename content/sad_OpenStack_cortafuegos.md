Title: OpenStack: Cortafuegos
Date: 2021/01/31
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-seguridad.jpg
Tags: OpenStack, Cortafuegos, nftables

Vamos a construir un cortafuegos en **Dulcinea** que nos permita controlar el tráfico de nuestra red. El cortafuegos que vamos a construir debe funcionar tras un reinicio.

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

Comprendido esto, empezaremos por instalar el paquete `nftables`:

<pre>
apt install nftables -y
</pre>

Una vez instalado, debemos habilitarlo para que se inicie en cada arranque:

<pre>
systemctl start nftables.service
systemctl enable nftables.service
</pre>

Al igual que pasa con `iptables`, `nftables` también permite guardar las reglas en un fichero para que así las configuraciones perduren a pesar de los reinicios del sistema. Para hacer esto empleamos el siguiente comando:

<pre>
nft list ruleset > /etc/nftables.conf
</pre>

Explicado esto, podemos empezar con las configuraciones de nuestro cortafuegos.


## Política por defecto

La política por defecto que vamos a configurar en nuestro cortafuegos será de tipo **DROP**, pero como estoy conectado por SSH, no voy a aplicar esta política de primeras, ya que sino perdería la conexión. Por tanto, empezaremos con añadir la regla para el acceso por el puerto 22, que es el que utiliza SSH:

Añadimos las reglas para SSH para poder acceder a *Dulcinea*:

<pre>
nft add rule inet filter input ip saddr 172.22.0.0/15 iifname "eth0" tcp dport 22 ct state new,established counter accept

nft add rule inet filter output ip daddr 172.22.0.0/15 oifname "eth0" tcp sport 22 ct state established counter accept
</pre>

En este punto, ya si podemos establecer la política por defecto a **DROP**, ya que poseemos la regla necesaria para tener acceso mediante SSH y no perderemos la conexión:

<pre>
nft add chain inet filter input { policy drop \;}

nft add chain inet filter output { policy drop \;}

nft add chain inet filter forward { policy drop \;}
</pre>

Miramos la lista de reglas:

<pre>
root@dulcinea:~# nft list ruleset
table inet filter {
	chain input {
		type filter hook input priority 0; policy drop;
		ip saddr 172.22.0.0/15 iifname "eth0" tcp dport ssh ct state established,new counter packets 65 bytes 4664 accept
	}

	chain forward {
		type filter hook forward priority 0; policy drop;
	}

	chain output {
		type filter hook output priority 0; policy drop;
		ip daddr 172.22.0.0/15 oifname "eth0" tcp sport ssh ct state established counter packets 37 bytes 8804 accept
	}
}
</pre>

Perfecto, ya poseemos una política por defecto **DROP**.


## NAT

Comenzaremos por crear una tabla llamada **NAT** y añadimos las siguientes cadenas:

<pre>
nft add table nat

nft add chain nat postrouting { type nat hook postrouting priority 100 \; }

nft add chain nat prerouting { type nat hook prerouting priority 0 \; }
</pre>

- **Configura de manera adecuada las reglas NAT para que todas las máquinas de nuestra red tenga acceso al exterior.**

Creamos las siguientes reglas:

<pre>
nft add rule ip nat postrouting oifname "eth0" ip saddr 10.0.1.0/24 counter snat to 10.0.0.8

nft add rule ip nat postrouting oifname "eth0" ip saddr 10.0.2.0/24 counter snat to 10.0.0.8
</pre>

Listo, ya las tendríamos.

- **Configura de manera adecuada todas las reglas NAT necesarias para que los servicios expuestos al exterior sean accesibles.**

Creamos las siguientes reglas:

<pre>
nft add rule ip nat prerouting iifname "eth0" udp dport 53 counter dnat to 10.0.1.6

nft add rule ip nat prerouting iifname "eth0" tcp dport 80 counter dnat to 10.0.2.6

nft add rule ip nat prerouting iifname "eth0" tcp dport 443 counter dnat to 10.0.2.6
</pre>

La primera hace referencia al servidor DNS ubicado en *Freston*, y las dos siguientes al servidor web ubicado en *Quijote*.

Listo, ya las tendríamos.


## Reglas

Para cada configuración, hay que mostrar las reglas que se han configurado y una prueba de funcionamiento de la misma.

#### SSH

- **Podemos acceder por SSH a todas las máquinas.**

Parte de este apartado lo vimos al principio del artículo, al crear las reglas necesarias para permitir el acceso por SSH a *Dulcinea*. Ahora haremos lo mismo pero para permitir el acceso mediante SSH a las máquinas de la red interna y de la DMZ.

Reglas para las máquinas de la red interna:

<pre>
nft add rule inet filter input ip saddr 10.0.1.0/24 iifname "eth1" tcp sport 22 ct state established counter accept

nft add rule inet filter output ip daddr 10.0.1.0/24 oifname "eth1" tcp dport 22 ct state new, established counter accept
</pre>

Reglas para las máquinas de la red DMZ:

<pre>
nft add rule inet filter output ip daddr 10.0.2.0/24 oifname "eth2" tcp dport 22 ct state new,established counter accept

nft add rule inet filter input ip saddr 10.0.2.0/24 iifname "eth2" tcp sport 22 ct state established counter accept
</pre>

Vamos a probar su funcionamiento:

<pre>
debian@dulcinea:~$ ssh freston
Linux freston 4.19.0-13-cloud-amd64 #1 SMP Debian 4.19.160-2 (2020-11-28) x86_64
...
Last login: Sun Jan 31 19:12:18 2021 from 10.0.1.11
debian@freston:~$

--------------------------------------------------------------------------------

debian@dulcinea:~$ ssh ubuntu@sancho
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-64-generic x86_64)
...
Last login: Fri Jan 29 08:45:37 2021 from 10.0.1.11
ubuntu@sancho:~$

--------------------------------------------------------------------------------

debian@dulcinea:~$ ssh centos@quijote
Last login: Fri Jan 29 10:08:13 2021 from 10.0.2.10
[centos@quijote ~]$
</pre>

Listo, ya las tendríamos.

- **Todas las máquinas pueden hacer SSH a máquinas del exterior.**

Creamos las siguientes reglas.

Reglas para *Dulcinea*:

<pre>
nft add rule inet filter output oifname "eth0" tcp dport 22 ct state new,established counter accept

nft add rule inet filter input iifname "eth0" tcp sport 22 ct state established counter accept
</pre>

Reglas para las máquinas de la red interna:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" oifname "eth0" tcp dport 22 ct state new,established counter accept

nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth0" oifname "eth1" tcp sport 22 ct state established counter accept
</pre>

Reglas para las máquinas de la red DMZ:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" oifname "eth0" tcp dport 22 ct state new,established counter accept

nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth0" oifname "eth2" tcp sport 22 ct state established counter accept
</pre>

Vamos a probar su funcionamiento intentando acceder mediante SSH a la máquina de *OVH*, ya que aunque no poseamos acceso mediante el par de clave pública-privada, dicha máquina tiene habilitado el acceso mediante contraseña:

<pre>
root@dulcinea:~# ssh debian@51.210.105.17
The authenticity of host '51.210.105.17 (51.210.105.17)' can't be established.
ECDSA key fingerprint is SHA256:LDFXW0tFS0C4p8BBQTjDdyObkSnQmMTUZgfiVnCn9zk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '51.210.105.17' (ECDSA) to the list of known hosts.
debian@51.210.105.17's password:
...
Last login: Sun Jan 31 20:32:56 2021 from 217.216.68.244
debian@vpsjavierpzh:~$

--------------------------------------------------------------------------------

debian@freston:~$ ssh debian@51.210.105.17
The authenticity of host '51.210.105.17 (51.210.105.17)' can't be established.
ECDSA key fingerprint is SHA256:LDFXW0tFS0C4p8BBQTjDdyObkSnQmMTUZgfiVnCn9zk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '51.210.105.17' (ECDSA) to the list of known hosts.
debian@51.210.105.17's password:
...
Last login: Sun Jan 31 20:33:39 2021 from 80.59.1.152
debian@vpsjavierpzh:~$

--------------------------------------------------------------------------------

[centos@quijote ~]$ ssh debian@51.210.105.17
The authenticity of host '51.210.105.17 (51.210.105.17)' can't be established.
ECDSA key fingerprint is SHA256:LDFXW0tFS0C4p8BBQTjDdyObkSnQmMTUZgfiVnCn9zk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '51.210.105.17' (ECDSA) to the list of known hosts.
debian@51.210.105.17's password:
...
Last login: Sun Jan 31 20:34:48 2021 from 80.59.1.152
debian@vpsjavierpzh:~$
</pre>

Listo, ya las tendríamos.


#### ping

- **Todas las máquinas de las dos redes pueden hacer *ping* entre ellas.**

Para permitir que todas las máquinas puedan hacer *ping* entre sí, debemos añadir las siguientes reglas que he ordenado de la siguiente manera para que quede más claro. En todos los bloques el orden es el siguiente, la primera regla permite el inicio de la conexión, es decir la petición, y la segunda la respuesta por parte del otro cliente.

*Dulcinea* a la red interna:

<pre>
nft add rule inet filter output ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-request counter accept

nft add rule inet filter input ip saddr 10.0.1.0/24 iifname "eth1" icmp type echo-reply counter accept
</pre>

*Dulcinea* a la red DMZ:

<pre>
nft add rule inet filter output ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-request counter accept

nft add rule inet filter input ip saddr 10.0.2.0/24 iifname "eth2" icmp type echo-reply counter accept
</pre>

Máquinas de la red interna a la red DMZ:

<pre>
nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-request counter accept

nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-reply counter accept
</pre>

Máquinas de la red DMZ a la red interna:

<pre>
nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-request counter accept

nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-reply counter accept
</pre>

En teoría ya tendríamos












Listo, ya las tendríamos.

- **Todas las máquinas pueden hacer ping a una máquina del exterior.**



- **Desde el exterior se puede hacer ping a dulcinea.**



- **A dulcinea se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT).**




#### DNS

- **El único DNS que pueden usar los equipos de las dos redes es *Freston*, no pueden utilizar un DNS externo.**



- **Dulcinea puede usar cualquier servidor DNS.**



- **Tenemos que permitir consultas DNS desde el exterior a *Freston*, para que, por ejemplo, papion-dns pueda preguntar.**


#### Base de datos

- **A la base de datos de sancho sólo pueden acceder las máquinas de la DMZ.**


#### Web

- **Las páginas web de *Quijote* (80, 443) pueden ser accedidas desde todas las máquinas de nuestra red y desde el exterior.**


#### Más servicios

- **Configura de manera adecuada el cortafuegos, para otros servicios que tengas instalado en tu red (ldap, correo, ...)**

.
