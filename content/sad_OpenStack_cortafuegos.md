Title: OpenStack: Cortafuegos
Date: 2021/01/19
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-seguridad.jpg
Tags: OpenStack, Cortafuegos, nftables

Vamos a construir un cortafuegos en dulcinea que nos permita controlar el tráfico de nuestra red. El cortafuegos que vamos a construir debe funcionar tras un reinicio.
Editar esta sección
Política por defecto

La política por defecto que vamos a configurar en nuestro cortafuegos será de tipo DROP.
Editar esta sección
NAT

    Configura de manera adecuada las reglas NAT para que todas las máquinas de nuestra red tenga acceso al exterior.
    Configura de manera adecuada todas las reglas NAT necesarias para que los servicios expuestos al exterior sean accesibles.

Editar esta sección
Reglas

Para cada configuración, hay que mostrar las reglas que se han configurado y una prueba de funcionamiento de la misma:
Editar esta sección
ping:

    Todas las máquinas de las dos redes pueden hacer ping entre ellas.
    Todas las máquinas pueden hacer ping a una máquina del exterior.
    Desde el exterior se puede hacer ping a dulcinea.
    A dulcinea se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT).

Editar esta sección
ssh

    Podemos acceder por ssh a todas las máquinas.
    Todas las máquinas pueden hacer ssh a máquinas del exterior.
    La máquina dulcinea tiene un servidor ssh escuchando por el puerto 22, pero al acceder desde el exterior habrá que conectar al puerto 2222.

Editar esta sección
dns

    El único dns que pueden usar los equipos de las dos redes es freston, no pueden utilizar un DNS externo.
    dulcinea puede usar cualquier servidor DNS.
    Tenemos que permitir consultas dns desde el exterior a freston, para que, por ejemplo, papion-dns pueda preguntar.

Editar esta sección
Base de datos

    A la base de datos de sancho sólo pueden acceder las máquinas de la DMZ.

Editar esta sección
Web

    Las páginas web de quijote (80, 443) pueden ser accedidas desde todas las máquinas de nuestra red y desde el exterior.

Editar esta sección
Más servicios

    Configura de manera adecuada el cortafuegos, para otros servicios que tengas instalado en tu red (ldap, correo, ...)






















.
