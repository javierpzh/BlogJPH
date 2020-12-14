Title: Instalación y configuración inicial de OpenLDAP
Date: 2020/12/14
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
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
│                                 <\Ok\>                                 │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
</pre>

Una vez hemos instalado estos paquetes, podemos pasar a llevar a cabo la configuración inicial del servidor.

Los archivos de configuración del servidor **LDAP** se almacenan en la carpeta `/etc/ldap/`. Pero en lugar de editar manualmente dichos archivos, es mejor ejecutar el asistente de configuración de `slapd`. Para ello debemos ejecutar el siguiente comando:

<pre>
dpkg-reconfigure slapd
</pre>

Se nos abrirá un asistente y en primer lugar nos preguntara si deseamos omitir la configuración del *servidor LDAP*:

<pre>
┌───────────────────────────────────┤ Configuring slapd ├───────────────────────────────────┐
│                                                                                           │
│ If you enable this option, no initial configuration or database will be created for you.  │
│                                                                                           │
│ Omit OpenLDAP server configuration?                                                       │
│                                                                                           │
│                          <\Yes\>                             <\No\>                       │
│                                                                                           │
└───────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

Respondemos que no, ya que precisamente lo que queremos es configurar el *servidor LDAP*.

Ahora, es el momento de especificar el nombre de dominio **DNS**:

<pre>
┌───────────────────────────────────┤ Configuring slapd ├────────────────────────────────────┐
│ The DNS domain name is used to construct the base DN of the LDAP directory. For example,   │
│ 'foo.example.org' will create the directory with 'dc=foo, dc=example, dc=org' as base DN.  │
│                                                                                            │
│ DNS domain name:                                                                           │
│                                                                                            │
│ javierpzh.gonzalonazareno.org_____________________________________________________________ │
│                                                                                            │
│                                           <\Ok\>                                           │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

Nombre de la Organización. En mi caso, establezco el mismo:

<pre>
┌──────────────────────────────────┤ Configuring slapd ├───────────────────────────────────┐
│ Please enter the name of the organization to use in the base DN of your LDAP directory.  │
│                                                                                          │
│ Organization name:                                                                       │
│                                                                                          │
│ javierpzh.gonzalonazareno.org___________________________________________________________ │
│                                                                                          │
│                                          <\Ok\>                                          │
│                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

En este punto, nos pedirá que introduzcamos una contraseña.

Acto seguido, tendremos que indicar que tipo de motor de base de datos vamos a utilizar. Yo selecciono el valor por defecto **MDB**:

<pre>
┌───────────────────────────────────────┤ Configuring slapd ├───────────────────────────────────────┐
│ HDB and BDB use similar storage formats, but HDB adds support for subtree renames. Both support   │
│ the same configuration options.                                                                   │
│                                                                                                   │
│ The MDB backend is recommended. MDB uses a new storage format and requires less configuration     │
│ than BDB or HDB.                                                                                  │
│                                                                                                   │
│ In any case, you should review the resulting database configuration for your needs. See           │
│ /usr/share/doc/slapd/README.Debian.gz for more details.                                           │
│                                                                                                   │
│ Database backend to use:                                                                          │
│                                                                                                   │
│                                               BDB                                                 │
│                                               HDB                                                 │
│                                               MDB                                                 │
│                                                                                                   │
│                                                                                                   │
│                                              <\Ok\>                                               │
│                                                                                                   │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

La respuesta de este apartado afectará cuando desinstalemos el paquete `slapd`, ya que si marcamos que sí, al hacer un `apt remove --purge slapd` se eliminará también la base de datos asociada al *servidor LDAP*.

<pre>
┌─────────────────────┤ Configuring slapd ├─────────────────────┐
│                                                               │
│                                                               │
│                                                               │
│ Do you want the database to be removed when slapd is purged?  │
│                                                               │
│                <\Yes\>                   <\No\>               │
│                                                               │
└───────────────────────────────────────────────────────────────┘
</pre>

Yo respondo que sí.

Vamos con la última pregunta. Nos informa que en el directorio `/var/lib/ldap` existe la configuración previa de la que se ha creado anteriormente, y nos da la opción de remover esa configuración y sustituila por esta nueva.

<pre>
┌──────────────────────────────────────┤ Configuring slapd ├───────────────────────────────────────┐
│                                                                                                  │
│ There are still files in /var/lib/ldap which will probably break the configuration process. If   │
│ you enable this option, the maintainer scripts will move the old database files out of the way   │
│ before creating a new database.                                                                  │
│                                                                                                  │
│ Move old database?                                                                               │
│                                                                                                  │
│                            <\Yes\>                               <\No\>                          │
│                                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
</pre>

En mi caso, respondo que sí.

Y ya, vemos como se cierra el asistente y habría terminado el proceso de configuración inicial de *LDAP*:

<pre>
root@freston:~# dpkg-reconfigure slapd
  Backing up /etc/ldap/slapd.d in /var/backups/slapd-2.4.47+dfsg-3+deb10u4... done.
  Moving old database directory to /var/backups:
  - directory unknown... done.
  Creating initial configuration... done.
  Creating LDAP directory... done.

root@freston:~#
</pre>

Si hacemos uso del comando `slapcat` nos mostraría un volcado en bruto de los objetos que tiene ahora mismo el *servidor LDAP*:

<pre>
root@freston:~# slapcat
dn: dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: javierpzh.gonzalonazareno.org
dc: javierpzh
structuralObjectClass: organization
entryUUID: caecef7c-d189-103a-852d-3549c02d4651
creatorsName: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
createTimestamp: 20201213122346Z
entryCSN: 20201213122346.946704Z#000000#000#000000
modifiersName: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
modifyTimestamp: 20201213122346Z

dn: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: e1NTSEF9QnlCSVZIVmh2WW43dUFqWnJoN1NOVThKc2MxWXVmSkY=
structuralObjectClass: organizationalRole
entryUUID: caf34c14-d189-103a-852e-3549c02d4651
creatorsName: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
createTimestamp: 20201213122346Z
entryCSN: 20201213122346.988494Z#000000#000#000000
modifiersName: cn=admin,dc=javierpzh,dc=gonzalonazareno,dc=org
modifyTimestamp: 20201213122346Z
</pre>
