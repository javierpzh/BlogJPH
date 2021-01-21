Title: OpenStack: Cortafuegos
Date: 2021/01/21
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
systemctl enable nftables.service
</pre>

Al igual que pasa con `iptables`, `nftables` también permite guardar las reglas en un fichero para que así las configuraciones perduren a pesar de los reinicios del sistema. Para hacer esto empleamos el siguiente comando:

<pre>
nft list ruleset > /etc/nftables.conf
</pre>

Explicado esto, podemos empezar con las configuraciones de nuestro cortafuegos.


## Política por defecto

La política por defecto que vamos a configurar en nuestro cortafuegos será de tipo **DROP**, pero como estoy conectado por SSH, no voy a aplicar esta política de primeras, ya que sino perdería la conexión. Por tanto, empezaremos con crear la tabla **FILTER**, las cadenas, y añadir la regla para el acceso por el puerto 22, que es el que utiliza SSH:

<pre>
nft add table ip FILTER
nft add chain ip FILTER INPUT { type filter hook input priority 0 \;}
nft add chain ip FILTER OUTPUT { type filter hook output priority 0 \; }
nft add chain ip FILTER FORWARD { type filter hook forward priority 0 \; }
</pre>

Añadimos las reglas para SSH:

<pre>
nft add rule ip FILTER INPUT iif eth0 tcp dport 22 counter accept
nft add rule ip FILTER OUTPUT ct state established,related counter accept
</pre>

nft add rule ip FILTER OUTPUT oif eth0 tcp dport 22 counter accept
nft add rule ip FILTER INPUT ct state established,related counter accept




En este punto, ya si podemos establecer la política por defecto a **DROP**, ya que poseemos la regla necesaria para tener acceso mediante SSH y no perderemos la conexión:

<pre>
nft add chain ip FILTER INPUT { type filter hook input priority 0 \; policy drop \;}
nft add chain ip FILTER OUTPUT { type filter hook output priority 0 \; policy drop \;}
nft add chain ip FILTER FORWARD { type filter hook forward priority 0 \; policy drop \;}
</pre>

Miramos la lista de reglas:

<pre>
root@dulcinea:~# nft list ruleset
table ip FILTER {
	chain INPUT {
		type filter hook input priority 0; policy drop;
		iif "eth0" tcp dport ssh counter packets 133 bytes 8241 accept
	}

	chain OUTPUT {
		type filter hook output priority 0; policy drop;
		ct state established,related counter packets 138 bytes 16980 accept
	}

	chain FORWARD {
		type filter hook forward priority 0; policy drop;
	}
}
</pre>

Perfecto, ya poseemos una política por defecto **DROP**.

## NAT

<pre>
nft add table NAT
nft add chain NAT PREROUTING { type nat hook prerouting priority 1 \; }
nft add chain NAT POSTROUTING { type nat hook postrouting priority 1 \; }
</pre>

- **Configura de manera adecuada las reglas NAT para que todas las máquinas de nuestra red tenga acceso al exterior.**

En mi caso, ya poseo esta serie de reglas, ya que fueron creadas en artículos anteriores, pero fueron creadas con `iptables`. Tranquilidad, esto no supone un problema, ya que las podemos convertir a `nftables` utilizando la herramienta `iptables-translate`.

*Reglas creadas hasta el momento:*

Para que las máquinas de la red interna posean conexión:

<pre>
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
</pre>

Para que las máquinas de la red DMZ posean conexión:

<pre>
iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eth0 -j MASQUERADE
</pre>

*Las convierto a reglas de `nftables`:*

<pre>
root@dulcinea:~# iptables-translate -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
nft add rule ip nat POSTROUTING oifname "eth0" ip saddr 10.0.1.0/24 counter masquerade

root@dulcinea:~# iptables-translate -t nat -A POSTROUTING -s 10.0.2.0/24 -o eth0 -j MASQUERADE
nft add rule ip nat POSTROUTING oifname "eth0" ip saddr 10.0.2.0/24 counter masquerade
</pre>

Listo, ya las tendríamos.

- **Configura de manera adecuada todas las reglas NAT necesarias para que los servicios expuestos al exterior sean accesibles.**

Al igual que en el caso anterior, ya me encuentro con que estas reglas fueron creadas anteriormente con `iptables`.

*Reglas creadas hasta el momento:*

Para que las peticiones del exterior lleguen al servidor DNS:

<pre>
iptables -t nat -A PREROUTING -p udp --dport 53 -i eth0 -j DNAT --to 10.0.1.6:53
</pre>

Para que las peticiones del exterior lleguen al servidor web al puerto 80:

<pre>
iptables -t nat -A PREROUTING -p tcp --dport 80 -i eth0 -j DNAT --to 10.0.2.6:80
</pre>

Para que las peticiones del exterior lleguen al servidor web al puerto 443:

<pre>
iptables -t nat -A PREROUTING -p tcp --dport 443 -i eth0 -j DNAT --to 10.0.2.6:443
</pre>

Para que las peticiones del exterior lleguen al servidor de correos:

<pre>
iptables -t nat -A PREROUTING -p tcp --dport 25 -i eth0 -j DNAT --to 10.0.1.6:25
</pre>

*Las convierto a reglas de `nftables`:*

<pre>
root@dulcinea:~# iptables-translate -t nat -A PREROUTING -p udp --dport 53 -i eth0 -j DNAT --to 10.0.1.6:53
nft add rule ip nat PREROUTING iifname "eth0" udp dport 53 counter dnat to 10.0.1.6:53

root@dulcinea:~# iptables-translate -t nat -A PREROUTING -p tcp --dport 80 -i eth0 -j DNAT --to 10.0.2.6:80
nft add rule ip nat PREROUTING iifname "eth0" tcp dport 80 counter dnat to 10.0.2.6:80

root@dulcinea:~# iptables-translate -t nat -A PREROUTING -p tcp --dport 443 -i eth0 -j DNAT --to 10.0.2.6:443
nft add rule ip nat PREROUTING iifname "eth0" tcp dport 443 counter dnat to 10.0.2.6:443

root@dulcinea:~# iptables-translate -t nat -A PREROUTING -p tcp --dport 25 -i eth0 -j DNAT --to 10.0.1.6:25
nft add rule ip nat PREROUTING iifname "eth0" tcp dport 25 counter dnat to 10.0.1.6:25
</pre>

Listo, ya las tendríamos.


## Reglas

Para cada configuración, hay que mostrar las reglas que se han configurado y una prueba de funcionamiento de la misma:

#### ping:

- **Todas las máquinas de las dos redes pueden hacer ping entre ellas.**



- **Todas las máquinas pueden hacer ping a una máquina del exterior.**



- **Desde el exterior se puede hacer ping a dulcinea.**



- **A dulcinea se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT).**


#### SSH

- **Podemos acceder por SSH a todas las máquinas.**



- **Todas las máquinas pueden hacer SSH a máquinas del exterior.**



- **La máquina *Dulcinea* tiene un servidor SSH escuchando por el puerto 22, pero al acceder desde el exterior habrá que conectar al puerto 2222.**


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
