Title: Monitorización con Nagios
Date: 2021/02/08
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: OpenStack, Nagios

Utiliza una de las instancias de OpenStack y realiza una de las partes que elijas entre las siguientes sobre el servidor de OVH, dulcinea, sancho, quijote y frestón:

- Métricas: recolección, gestión centralizada, filtrado o selección de los parámetros relevantes y representación gráfica que permita controlar la evolución temporal de parámetros esenciales de todos los servidores.

- Monitorización: Configuración de un sistema de monitorización que controle servidores y servicios en tiempo real y envíe alertas por uso excesivo de recursos (memoria, disco raíz, etc.) y disponibilidad de los servicios. Alertas por correo, telegram, etc.

- Gestión de logs: Implementa un sistema que centralice los logs de todos los servidores y que filtre los registros con prioridad error, critical, alert o emergency. Representa gráficamente los datos relevantes extraídos de los logs o configura el envío por correo al administrador de los logs relevantes (una opción o ambas).

Detalla en la documentación claramente las características de la implementación elegida, así como la forma de poder verificarla (envía si es necesario usuario y contraseña por correo a los profesores, para el panel web si lo hubiera, p.ej.).

--------------------------------------------------------------------------------

**Nagios** es un sistema de monitorización de redes ampliamente utilizado, que vigila los equipos y los servicios que se especifiquen, alertando cuando el comportamiento de los mismos no sea el deseado.

Cuenta con una extensa, sólida y organizada comunidad de soporte que ofrece de modo gratuito *addons* y *plugins* para extender sus funcionalidades a través de **Nagios Exchange**, información de fondo y ayuda a través de **Nagios Community** e información técnica a través de **Nagios Wiki**.

## Características principales

- Monitorización de servicios de red como: SMTP, POP3, HTTP, SNMP, ...

- Monitorización de los recursos del sistema hardware como: carga de CPU, uso de los discos, RAM, estado de los puertos, ...

- Independencia de sistemas operativos

- Posibilidad de monitorización remota mediante túneles SSL cifrados o SSH

- Posibilidad de programar *plugins* específicos para nuevos sistemas

- Chequeo de servicios paralizados

- Notificaciones cuando ocurren problemas en servicios o *hosts*, así como cuando son resueltos

- Posibilidad de definir manejadores de eventos que se ejecuten al ocurrir un evento de un servicio o *host* (acciones pro-activas)

- Soporte para implementar *hosts* de monitores redundantes

- Visualización del estado de la red en tiempo real a través de su interfaz web, con la posibilidad de generar informes y gráficas de comportamiento de los sistemas monitorizados, y visualización del listado de notificaciones enviadas, historial de problemas, archivos de registros, ...

Las alertas que genera pueden ser recibidas por correo electrónico y mensajes SMS, entre otros.

Así luce el panel web de *Nagios*:

![.](images/aso_monitorización_con_Nagios/nagios.png)


## Instalación

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

He hecho más tareas sobre este escenario, las puedes encontrar todas [aquí](https://javierpzh.github.io/tag/openstack.html).

Explicado esto, vamos a proceder con la instalación de nuestro sistema de monitorización.

En mi caso, voy a llevar a cabo la instalación de **Nagios Core** en la máquina **Quijote**, es decir, que ésta será el servidor principal. Hay que recordar que *Quijote* consta de un sistemas *CentOS 8*.

He decidido escoger como servidor este equipo principalmente porque *Nagios* necesita un servidor web para poder acceder a su panel de administración web, y esto es algo que me interesa ya que, es en esta máquina donde se encuentra instalado el servidor web de mi escenario. No queda solo ahí, ya que nuestro servidor web, en mi caso, *Apache*, tiene que ser capaz de ejecutar código PHP. Si no dispones de estos requisitos, puedes visitar el tercer artículo *indexado* anteriormente, donde llevo a cabo la instalación de estos requisitos.

Para seguir con la instalación necesitamos tener instalados los siguientes paquetes.

En *Debian/Ubuntu*:

<pre>
apt install gcc make unzip wget
</pre>

En *CentOS*:

<pre>
dnf install gcc make unzip wget
</pre>

Hecha la introducción, es el momento de empezar con la propia instalación en sí.

Para descargar *Nagios Core* nos dirigiremos a su [sitio web](https://github.com/NagiosEnterprises/nagioscore/releases) y copiaremos el enlace del archivo `.tar.gz`, para posteriormente descargarlo en nuestro sistema mediante la herramienta `wget`. En mi caso, cuando estoy escribiendo este *post*, la última versión disponible es la 4.4.6. Puedes descargarlo desde [aquí](images/aso_monitorización_con_Nagios/nagios-4.4.6.zip).

<pre>
wget https://javierpzh.github.io/images/aso_monitorizaci%C3%B3n_con_Nagios/nagios-4.4.6.zip
</pre>

Una vez descargado, lo descomprimimos:

<pre>
unzip nagios-4.4.6.zip
</pre>

Accedemos a la carpeta y llevaremos a cabo la instalación mediantes los siguientes comandos. El primero para configurar la instalación y el segundo para compilar los *plugins*:

<pre>
[root@quijote nagios-4.4.6]# ./configure
...

[root@quijote nagios-4.4.6]# make all
</pre>

La instalación de *Nagios* está repartida en una serie de objetos distintos, que veremos a continuación.

Comenzaremos creando el usuario y el grupo que utilizará el servicio *Nagios* en nuestro sistema:

<pre>
make install-groups-users
</pre>

Seguimos con la instalación de los archivos de *Nagios*:

<pre>
make install
</pre>

Ahora pasaremos con los archivos de configuración necesarias para nuestro futuro panel de administración web:

<pre>
make install-webconf
</pre>

Instalamos los archivos de configuración de *Nagios*:

<pre>
make install-config
</pre>

Instalamos los *scripts* del servicio:

<pre>
make install-init
</pre>

Instalamos y habilitamos el servicio de *Nagios*:

<pre>
make install-daemoninit
</pre>

Configuramos el directorio para comandos externos:

<pre>
make install-commandmode
</pre>

Para poder acceder a *Nagios*, debemos crear el usuario administrador, en mi caso, **nagiosadmin**:

<pre>
[root@quijote ~]# htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
New password:
Re-type new password:
Adding password for user nagiosadmin
</pre>

Introducida la contraseña, habremos terminado.

Llegó el turno de activar el módulo CGI de *Apache*.

En *Debian/Ubuntu*:

<pre>
a2enmod cgi

systemctl restart apache2
</pre>

En *CentOS*:

<pre>
dnf install perl perl-CGI

systemctl restart httpd
</pre>

Nos aseguramos que el módulo CGI se encuentre cargado en *Apache*:

<pre>
[root@quijote ~]# apachectl -t -D DUMP_MODULES | grep 'cgi'
 proxy_fcgi_module (shared)
 proxy_scgi_module (shared)
 cgid_module (shared)
</pre>

Si nos dirigimos a nuestra dirección web */nagios*, según esté configurado en nuestro servidor web, en mi caso `www.javierpzh.gonzalonazareno.org/nagios` nos aparecerá esta ventana:

![.](images/aso_monitorización_con_Nagios/nagiosautentificacion.png)

Si introducimos el usuario y la contraseña que hemos creado anteriormente:

![.](images/aso_monitorización_con_Nagios/nagiospanel1.png)

Vemos como podemos acceder al panel de administración de *Nagios*, por lo que habríamos finalizado la instalación de *Nagios* en nuestro sistema.

## Instalación en los clientes

Ya tenemos instalado *Nagios* en el servidor y ya estamos monitorizando los servicios que se encuentran en él, pero además de los servicios de esa máquina, queremos monitorizar los servicios de las máquinas **Dulcinea**, **Sancho**, **Freston** y nuestra *VPS*, la máquina de **OVH**.

Para ello debemos llevar a cabo la instalación de **Nagios NRPE**. Descargaremos *Nagios NRPE* tanto en la parte del servidor, como en los clientes, ya que el mismo paquete contiene, tanto el servicio *Nagios NRPE* para las máquinas remotas, como el *plugin NRPE* para el servidor *Nagios Core*. En mi caso, mostraré tan solo la instalación en *Dulcinea*, ya que en las demás máquinas el proceso es idéntico. Hay que decir, que es necesario tener instalado el paquete `libssl-dev`.

La descarga la llevaremos a cabo desde su [sitio web](https://github.com/NagiosEnterprises/nrpe/releases). Al igual que antes, dejo [aquí](images/aso_monitorización_con_Nagios/nrpe-4.0.3.zip) la última versión disponible a día de hoy, que es la 4.0.3.

<pre>
wget https://javierpzh.github.io/images/aso_monitorizaci%C3%B3n_con_Nagios/nrpe-4.0.3.zip
</pre>

Una vez descargado, lo descomprimimos:

<pre>
unzip nrpe-4.0.3.zip
</pre>

El proceso es similar al anterior. Empezaremos por configurar la compilación:

<pre>
root@dulcinea:~/nrpe-4.0.3#./configure
</pre>

Y compilamos:

<pre>
root@dulcinea:~/nrpe-4.0.3#make nrpe
</pre>

Terminada la compilación instalamos los binarios, archivos de configuración, *scripts*, ... :

<pre>
root@dulcinea:~/nrpe-4.0.3#make install-groups-users install-daemon install-config install-init
</pre>

Con esto habríamos terminado la instalación de *Nagios NRPE* y para finalizar, iniciaremos su servicio y lo habilitaremos en cada arranque:

<pre>
systemctl start nrpe && systemctl enable nrpe
</pre>

Listo.


## Configuración en el servidor del plugin NRPE

Es el momento de instalar el *plugin NRPE* en nuestro servidor *Quijote*, por lo que empezaremos descomprimiendo el paquete que descargamos anteriormente. Si aún no lo has descargado te dejo este comando por aquí:

<pre>
wget https://javierpzh.github.io/images/aso_monitorizaci%C3%B3n_con_Nagios/nrpe-4.0.3.zip
</pre>

Una vez descargado, lo descomprimimos:

<pre>
unzip nrpe-4.0.3.zip
</pre>

Configuramos la compilación:

<pre>
[root@quijote nrpe-4.0.3]# ./configure
</pre>

En este caso, a diferencia de las máquinas clientes, vamos a compilar el *plugin* en lugar del servicio:

<pre>
[root@quijote nrpe-4.0.3]# make check_nrpe
</pre>

Realizamos la instalación:

<pre>
[root@quijote nrpe-4.0.3]# make install-plugin
</pre>

Una vez terminada la instalación, vamos a 

<pre>

</pre>






















Por último, como nuestro servidor *Nagios Core* se encuentra en un sistema *CentOS*, recordaremos que nos encontramos con su *firewall* por defecto. Por tanto, tendremos que añadir una regla para que el servidor *Nagios Core* pueda conectar al servicio *Nagios NRPE*:

<pre>
firewall-cmd --permanent --add-service=nrpe
</pre>

Recargamos la configuración del *firewall* para aplicar los cambios:

<pre>
firewall-cmd --reload
</pre>









## Configuración en los clientes

Es el momento de llevar a cabo la configuración en la parte de los clientes.

Para configurar el servicio *Nagios NRPE* editaremos su archivo de configuración principal, el llamado `nrpe.cfg`, que se encuentra en el directorio `/usr/local/nagios/etc/`. En él, buscaremos la directiva `allowed_hosts`, que indica los servidores *Nagios Core* que podrán conectarse con el servicio, y añadiremos la dirección IP de nuestro servidor *Quijote*. De manera que quedaría de la siguiente manera:

En *Dulcinea*, *Sancho* y *Freston*:

<pre>
allowed_hosts=127.0.0.1,::1,10.0.2.6
</pre>

En la máquina de *OVH*:

<pre>

</pre>

Hecha esta modificación, tendremos que reiniciar el servicio para que se apliquen los cambios:

<pre>
systemctl restart nrpe
</pre>












































.
