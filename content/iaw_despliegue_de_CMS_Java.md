Title: Despliegue de CMS Java
Date: 2020/12/14
Category: Implantación de Aplicaciones Web
Header_Cover: theme/images/banner-aplicacionesweb.jpg
Tags: CMS, Java

**En esta práctica vamos a desplegar un [CMS escrito en Java](https://java-source.net/open-source/content-managment-systems). Puedes escoger la aplicación que vas a desplegar de CMS escritos en Java o de [Aplicaciones Java en Bitnami](https://bitnami.com/tag/java).**

#### Indica la aplicación escogida y su funcionalidad

He decidido escoger el **CMS escrito en Java**, llamado **Guacamole**.

*Apache Guacamole* es una herramienta libre que nos permite conectarnos remotamente a un servidor mediante el navegador web sin necesidad de usar un cliente.

Gracias a HTML5, una vez tengamos instalado y configurado *Apache Guacamole*, tan solo tenemos que conectarnos mediante el navegador web para empezar a trabajar remotamente.


#### Escribe una guía de los pasos fundamentales para realizar la instalación

1. Instalar *tomcat 9*.

2. Comprobar el accso al puerto 8080.

3. Buscar un archivo `.war` y almacenarlo en la ruta `/var/lib/tomcat9/webapp`.

4. Acceder a la aplicación.

5. Configurar el fichero `/etc/tomcat9/server.xml` para activar el conector `ajp`.

6. Buscar información sobre el **proxy.ajp** en **Apache2** y realizar la configuración necesaria.

A continuación vamos a realizar la instalación de *tomcat 9* y de la aplicación en sí.

Antes de nada, necesitaremos un equipo donde trabajar. Yo voy a instalar una máquina virtual, y para ello, voy a utilizar *Vagrant*. He creado este *Vagrantfile*:

<pre>
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"

  config.vm.network "private_network", ip: "192.168.200.20"

end
</pre>

Una vez estamos en nuestro equipo de trabajo, en primer lugar, debemos instalar **Tomcat**, en mi caso, voy a instalar la versión *9*

*Tomcat* requiere que **Java** esté instalado en el servidor para poder ejecutar cualquier código de aplicación web *Java*.

<pre>
apt install default-jdk -y
</pre>

Instalado *Java*, ya podemos proceder a instalar *Tomcat*. Para ello:

<pre>
apt install tomcat9 -y
</pre>

Para comprobar el funcionamiento de una forma más visual, podemos conectarnos desde un navegador web mediante la dirección IP de la máquina especificando el puerto **8080**:

![.](images/iaw_despliegue_de_CMS_Java/tomcat8080.png)

Vemos que está funcionando correctamente.

En este punto, ya podemos descargar el fichero `.war`.

¿Alguien se pregunta qué es un fichero `.war`?

Un fichero `.war` es una aplicación web que permite a *Tomcat* acceder a su utilización. El fichero `.war` tiene que ser descomprimido para ser leído.
























#### ¿Has necesitado instalar alguna librería? ¿Has necesitado instalar un conector de una base de datos?

.

#### Entrega una captura de pantalla donde se vea la aplicación funcionando

.

#### Realiza la configuración necesaria en Apache2 y tomcat (utilizando el protocolo AJP) para que la aplicación sea servida por el servidor web

.

#### Entrega una captura de pantalla donde se vea la aplicación funcionando servida por Apache2

.
