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

En mi caso, voy a llevar a cabo la instalación de *Nagios* en la máquina **Quijote**, es decir, que ésta será el servidor principal. Hay que recordar que *Quijote* consta de un sistemas *CentOS 8*.

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

Para descargar *Nagios* nos dirigiremos a su [sitio web](https://github.com/NagiosEnterprises/nagioscore/releases) y copiaremos el enlace del archivo `.tar.gz`, para posteriormente descargarlo en nuestro sistema mediante la herramienta `wget`. En mi caso, cuando estoy escribiendo este *post*, la última versión disponible es la 4.4.6. Puedes descargarlo desde [aquí](images/aso_monitorización_con_Nagios/nagios-4.4.6.zip)

<pre>
wget https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.6/nagios-4.4.6.tar.gz
</pre>

Una vez descargado, lo descomprimimos:

<pre>
tar xf nagios-4.4.6.tar.gz
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

archivos de configuración de *Nagios*:

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

## Configuración en los clientes






































.
