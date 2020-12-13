Title: Instalación y configuración inicial de OpenLDAP
Date: 2020/12/13
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.png
Tags: LDAP, OpenStack


#### Realiza la instalación y configuración básica de OpenLDAP en Freston utilizando como base el nombre DNS asignado.

#### Crea dos unidades organizativas, una para personas y otra para grupos.

Vamos a proceeder con la instalación de **LDAP**.

El servidor **OpenLDAP** está disponible en el paquete `slapd`. También nos conviene instalar el paquete `ldap-utils` que contiene utilidades adicionales:

<pre>
apt install slapd ldap-utils -y
</pre>

Durante la instalación, se nos abrirá esta ventana emergente donde nos pedirá que introduzcamos la contraseña de administrador de este nuevo **LDAP**:

<pre>
┌─────────────────────────┤ Configuring slapd ├──────────────────────────┐
│ Please enter the password for the admin entry in your LDAP directory.  │
│                                                                        │
│ Administrator password:                                                │
│                                                                        │
│ ______________________________________________________________________ │
│                                                                        │
│                                 <Ok>                                   │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
</pre>

Una vez hemos instalado estos paquetes, podemos pasar a llevar a cabo la configuración inicial del servidor.

Los archivos de configuración del servidor **LDAP** se almacenan en la carpeta `/etc/ldap/`. Pero en lugar de editar manualmente dichos archivos, es mejor ejecutar el asistente de configuración de `slapd`. Para ello debemos ejecutar el siguiente comando:

<pre>
dpkg-reconfigure slapd
</pre>

Lo primero que nos pregunta el asistente es si deseamos omitir la configuración del servidor LDAP:

<pre>
┌───────────────────────────────────┤ Configuring slapd ├───────────────────────────────────┐
│                                                                                           │
│ If you enable this option, no initial configuration or database will be created for you.  │
│                                                                                           │
│ Omit OpenLDAP server configuration?                                                       │
│                                                                                           │
│                          <Yes>                             <No>                           │
│                                                                                           │
└───────────────────────────────────────────────────────────────────────────────────────────┘
</pre>














.
