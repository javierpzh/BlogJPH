Title: Configurar LDAP en alta disponibilidad
Date: 2020/12/21
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: LDAP, OpenStack

#### Vamos a instalar un servidor LDAP en Sancho que va a actuar como servidor secundario o de respaldo del servidor LDAP instalado en Freston, para ello habrá que seleccionar un modo de funcionamiento y configurar la sincronización entre ambos directorios, para que los cambios que se realicen en uno de ellos se reflejen en el otro.

#### - Selecciona el método más adecuado para configurar un servidor LDAP secundario, viendo y/o probando las opciones posibles.
#### - Explica claramente las características, ventajas y limitaciones del método seleccionado
#### - Realiza las configuraciones adecuadas en el directorio cn=config
#### - Como prueba de funcionamiento, prepara un pequeño fichero ldif, que se insertará en el directorio en la corrección y se verificará que se ha sincronizado.

Si quieres saber como instalar un servidor **LDAP**, puedes consultar [este post](https://javierpzh.github.io/instalacion-y-configuracion-inicial-de-openldap.html).

Si quieres saber como configurar un servidor **LDAPs**, puedes consultar [este post](https://javierpzh.github.io/ldaps.html).

Vamos a configurar **Sancho** como servidor **LDAP** secundario de **Freston**, pero antes de realizar la configuración, voy a explicar brevemente los tipos de métodos que podemos elegir para configurar un servidor *LDAP* de respaldo, y por qué el que he seleccionado es el más adecuado para este caso.

Bien, primeramente, si ya tenemos instalado un servidor *LDAP* que nos ofrece servicio, ¿para qué instalar otro? Pues es muy sencillo, esto nos hará tener una segunda máquina que nos siga ofreciendo el servicio de *LDAP* en caso de que en la primera máquina ocurriera algún fallo, evitando así perder el servicio durante el tiempo que nos lleve arreglar este fallo. Esto obviamente, en un caso de alta disponibilidad, es muy importante como ya os podéis imaginar.

¿Y como trabajarán estos dos servidores conjuntamente? Pues también es muy simple. Se trata de ir replicando los datos y las informaciones del servidor principal, al secundario, de manera que siempre estén sincronizados.

Una vez tenemos la idea de para que nos serviría este servidor de respaldo, voy a pasar a explicar 































.
