Title: Mapear URL a ubicaciones de un sistema de ficheros
Date: 2020/10/20
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: mapear, web

- **[Alias](http://httpd.apache.org/docs/2.4/mod/mod_alias.html#alias): Un alias me permite servir ficheros que no se encuentran en el `DocumentRoot`.**

- **[Options](http://httpd.apache.org/docs/2.4/mod/core.html#options): Determina para que sirven las siguientes opciones de funcionamiento:**

    - **All:** habilita todas las opciones, menos `MultiViews`. Es la opción por defecto si no se indica ninguna opción.

    - **FollowSymLinks:** sirve para seguir los enlaces simbólicos de un directorio.

    - **Indexes:** sirve por si el cliente solicita un directorio en el que no exista ninguno de los ficheros especificados en `DirectoryIndex`, el servidor ofrecerá un listado de los archivos del directorio.

    - **MultiViews:** permite mostrar una página distinta en función del idioma del navegador.

    - **SymLinksOwnerMatch:** sirve para que el servidor siga los enlaces simbólicos en los que el fichero o directorio final pertenezca al mismo usuario que el propio enlace.

    - **ExecCGI:** permite la ejecución de aplicaciones CGI en el directorio.


      **Determina como funciona si delante de las opciones pongo el signo + o -.**

      Si pones el signo **+** delante de una opción, habilitas su funcionamiento. Si pones el signo **-** la deshabilitas.

- **La directiva [Redirect](http://httpd.apache.org/docs/2.4/mod/mod_alias.html#redirect) nos permite crear redirecciones temporaless o permanentes.**

- **Con la directiva `ErrorDocument` se pueden crear [Respuestas de error personalizadas](http://httpd.apache.org/docs/2.4/custom-error.html). Todo esto se puede llevar a cabo en el fichero `/etc/apache2/conf-available/localized-error-pages.conf`.**


## Ejercicios

**Crea un nuevo host virtual que es accedido con el nombre `www.mapeo.com`, cuyo `DocumentRoot` sea `/srv/mapeo`.**

Antes de nada voy a decir que en mi caso voy a utilizar [Vagrant](https://www.vagrantup.com/) y como software de virtualización [VirtualBox](https://www.virtualbox.org/).

En esta máquina virtual, nos dirigimos al fichero de configuración de apache, `/etc/apache2/apache2.conf`, y debemos asegurarnos que tenemos descomentadas las siguientes líneas, que por defecto vienen comentadas:

<pre>
<\Directory /srv/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
<\/Directory>
</pre>

Esto indica que mostrará todos los ficheros de las páginas alojadas en la ruta `/srv/` y sus hijos.



**1. Cuando se entre a la dirección `www.mapeo.com`, se redireccionará automáticamente a `www.mapeo.com/principal`, donde se mostrará el mensaje de bienvenida.**

**2. En el directorio `principal` no se permite ver la lista de los ficheros, no se permite que se siga los enlaces simbólicos y no se permite negociación de contenido. Muestra al profesor el funcionamiento. ¿Qué configuración tienes que poner?**

**3. Si accedes a la página `www.mapeo.com/principal/documentos` se visualizarán los documentos que hay en `/home/usuario/doc`. Por lo tanto se permitirá el listado de fichero y el seguimiento de enlaces simbólicos siempre que el propietario del enlace y del fichero al que apunta sean el mismo usuario. Explica bien y pon una prueba de funcionamiento donde se vea bien el seguimiento de los enlaces simbólicos.**

**4. En todo el host virtual se debe redefinir los mensajes de error de objeto no encontrado y no permitido. Para el ello se crearan dos ficheros html dentro del directorio error. Entrega las modificaciones necesarias en la configuración y una comprobación del buen funcionamiento.**
