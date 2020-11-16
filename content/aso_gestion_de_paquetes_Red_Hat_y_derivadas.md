Title: Gestión de paquetes - Red Hat y derivadas
Date: 2020/11/16
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: Red Hat, CentOS, gestion, paquetes

## Gestión de paquetes

**1. Modifica la configuración de red de DHCP a estática.**

Para realizar esta modificación debemos editar el fichero `/etc/sysconfig/network-scripts/ifcfg-eth0`, y establecer este bloque en él:

<pre>
BOOTPROTO=static
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
IPADDR=X.X.X.X
NETMASK=X.X.X.X
GATEWAY=X.X.X.X
DNS1=X.X.X.X
DNS2=X.X.X.X
DNSX=X.X.X.X
</pre>

**2. Actualiza el sistema a las versiones más recientes de los paquetes instalados.**



**3. Instala los repositorios adicionales EPEL y CentOSPlus.**



**4. Instala el paquete que proporciona el programa dig, explicando los pasos que has dado para encontrarlo.**



**5. Explica qué comando utilizarías para ver la información del paquete kernel instalado.**



**6. Instala el repositorio adicional "elrepo" e instala el último núcleo disponible del mismo (5.9.X).**



**7. Busca las versiones disponibles para instalar del núcleo linux e instala la más nueva.**



**8. Muestra el contenido del paquete del último núcleo instalado.**
