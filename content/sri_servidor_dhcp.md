Title: Servidor DHCP
Date: 2020/10/15
Category: Servicios de Red e Internet

## Teoría

**Tarea 1: Lee el documento [Teoría: Servidor DHCP](https://fp.josedomingo.org/serviciosgs/u02/dhcp.html) y explica el funcionamiento del servidor DHCP resumido en este [gráfico](https://fp.josedomingo.org/serviciosgs/u02/img/dhcp.png).**

## DHCPv4

####Preparación del escenario

**Crea un escenario usando Vagrant que defina las siguientes máquinas:**

- **Servidor:** Tiene dos tarjetas de red: una pública y una privada que se conectan a la red local.
- **nodo_lan1:** Un cliente conectado a la red local.

#### Servidor DHCP

**Instala un servidor dhcp en el ordenador “servidor” que de servicio a los ordenadores de red local, teniendo en cuenta que el tiempo de concesión sea 12 horas y que la red local tiene el direccionamiento `192.168.100.0/24`.**

<pre>
apt-get install isc-dhcp-server
</pre>


/etc/default/isc-dhcp-server
"eth2"

/etc/dhcp/dhcpd.conf
subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.3 192.168.100.10;
  option domain-name-servers 8.8.8.8,8.8.4.4;
  option routers 192.168.100.1;
  option broadcast-address 192.168.100.255;
  default-lease-time 60;
  max-lease-time 43200;
}


**Tarea 2: Entrega el fichero `Vagrantfile` que define el escenario.**

He creado este fichero Vagrantfile para definir el escenario.

<pre>
\# -*- mode: ruby -*-
\# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :servidor do |servidor|
        servidor.vm.box="debian/buster64"
        servidor.vm.hostname="servidordhcp"
        servidor.vm.network :public_network, :bridge=>"wlo"
        servidor.vm.network :private_network, ip: "192.168.100.1", virtualbox__intnet: "red1"
  end

  config.vm.define :nodolan1 do |nodolan1|
        nodolan1.vm.box="debian/buster64"
        nodolan1.vm.hostname="nodolan1"
        nodolan1.vm.network :private_network, virtualbox__intnet: "red1", type: "dhcp"
  end

end
</pre>

**Tarea 3: Muestra el fichero de configuración del servidor, la lista de concesiones, la modificación en la configuración que has hecho en el cliente para que tome la configuración de forma automática y muestra la salida del comando `ip address`.**
**Tarea 4: Configura el servidor para que funcione como router y NAT, de esta forma los clientes tengan internet. Muestra las rutas por defecto del servidor y el cliente. Realiza una prueba de funcionamiento para comprobar que el cliente tiene acceso a internet (utiliza nombres, para comprobar que tiene resolución DNS).**
**Tarea 5: Realizar una captura, desde el servidor usando `tcpdump`, de los cuatro paquetes que corresponden a una concesión: `DISCOVER`, `OFFER`, `REQUEST`, `ACK`.**

#### Funcionamiento del DHCP

**Vamos a comprobar que ocurre con la configuración de los clientes en determinadas circunstancias, para ello vamos a poner un tiempo de concesión muy bajo.**

**Tarea 6: Los clientes toman una configuración, y a continuación apagamos el servidor dhcp. ¿qué ocurre con el cliente windows? ¿Y con el cliente linux?**
**Tarea 7: Los clientes toman una configuración, y a continuación cambiamos la configuración del servidor dhcp (por ejemplo el rango). ¿qué ocurriría con un cliente windows? ¿Y con el cliente linux?**

#### Reservas

**Crea una reserva para el que el cliente tome siempre la dirección `192.168.100.100`.**

**Tarea 8: Indica las modificaciones realizadas en los ficheros de configuración y entrega una comprobación de que el cliente ha tomado esa dirección.**

#### Uso de varios ámbitos

**Modifica el escenario Vagrant para añadir una nueva red local y un nuevo nodo:**

- **Servidor: En el servidor hay que crear una nueva interfaz.**
- **nodo_lan2: Un cliente conectado a la segunda red local.**

**Configura el servidor dhcp en el ordenador “servidor” para que de servicio a los ordenadores de la nueva red local, teniendo en cuenta que el tiempo de concesión sea 24 horas y que la red local tiene el direccionamiento 192.168.200.0/24.**

**Tarea 9: Entrega el nuevo fichero Vagrantfile que define el escenario.**



**Tarea 10: Explica las modificaciones que has hecho en los distintos ficheros de configuración. Entrega las comprobaciones necesarias de que los dos ámbitos están funcionando.**



**Tarea 11: Realiza las modificaciones necesarias para que los cliente de la segunda red local tengan acceso a internet. Entrega las comprobaciones necesarias.**
